#!/usr/bin/env bash
set -euo pipefail

source "$BSYS6/source.sh"

sdk_link_name="MacOSX.sdk"
catalog_script="$SOURCE/build/macosx/catalog.py"

log() {
  echo "$@" >&2
}

mach_build_python() {
  "$SOURCE/mach" --no-interactive python --virtualenv build "$@"
}

resolve_sdk_package_info() {
  local candidate_file
  local product_line
  local product_id
  local package_line
  local package_id
  local package_url
  local package_contents
  local candidate_path
  local candidate_sdk_name
  local candidate_sdk_version
  local product_count=0
  local package_count=0

  candidate_file="$(mktemp --tmpdir librewolf-macos-sdk-candidates.XXXXXX)"
  trap 'rm -f "$candidate_file"' RETURN

  log "Querying Apple SDK product list"
  while IFS= read -r product_line; do
    product_id="${product_line%% *}"
    if [[ ! "$product_id" =~ ^[0-9]{3}-[0-9]{5}$ ]]; then
      log "-> Skipping non-product catalog line: $product_line"
      continue
    fi

    product_count=$((product_count + 1))
    log "Checking SDK product $product_id"

    while IFS= read -r package_line; do
      package_id="${package_line%% *}"
      package_url="${package_line#* }"
      if [[ -z "$package_id" || "$package_url" == "$package_line" ]]; then
        continue
      fi

      case "$package_id" in
      *SDK* | *macOS_SDK*)
        package_count=$((package_count + 1))
        log "Inspecting package $package_id from product $product_id"
        package_contents="$(mach_build_python "$catalog_script" "$product_id/$package_id")"

        while IFS= read -r candidate_path; do
          [[ "$candidate_path" == Library/Developer/CommandLineTools/SDKs/MacOSX*.sdk ]] || continue

          candidate_sdk_name="${candidate_path##*/}"
          candidate_sdk_version="${candidate_sdk_name#MacOSX}"
          candidate_sdk_version="${candidate_sdk_version%.sdk}"
          printf '%s\t%s\t%s\n' "$candidate_sdk_version" "$candidate_path" "$package_url" >>"$candidate_file"
        done <<<"$package_contents"
        ;;
      esac
    done < <(mach_build_python "$catalog_script" "$product_id")
  done < <(mach_build_python "$catalog_script" --filter SDK)

  if [ -s "$candidate_file" ]; then
    read -r _ candidate_path package_url < <(sort -t $'\t' -k1,1V "$candidate_file" | tail -n 1)
    log "Selected newest available SDK $candidate_path"
    printf '%s\t%s\n' "$candidate_path" "$package_url"
    return 0
  fi

  log "Searched $product_count SDK products and $package_count SDK packages without finding any macOS SDK"

  return 1
}

log "Resolving macos sdk package url"
if ! read -r resolved_sdk_prefix sdk_package_url < <(resolve_sdk_package_info); then
  echo "Could not find a macOS SDK package in Apple's software update catalog" >&2
  exit 1
fi

sdk_package_file="$(mktemp --tmpdir librewolf-macos-sdk.XXXXXX.pkg)"
trap 'rm -f "$sdk_package_file"' EXIT

log "Downloading macos sdk package"
curl --fail --location --output "$sdk_package_file" "$sdk_package_url"
sdk_package_sha512="$(sha512sum "$sdk_package_file" | awk '{print $1}')"

resolved_sdk_name="${resolved_sdk_prefix##*/}"
resolved_sdk_dir="$MOZBUILD/$resolved_sdk_name"
sdk_link_path="$MOZBUILD/$sdk_link_name"

log "-> Fetching macos sdk"
mach_build_python \
  "$SOURCE/taskcluster/scripts/misc/unpack-sdk.py" \
  "file://$sdk_package_file" \
  "$sdk_package_sha512" \
  "$resolved_sdk_prefix" \
  "$resolved_sdk_dir"

log "Linking macos sdk"
ln -sfn "$resolved_sdk_name" "$sdk_link_path"
