#!/usr/bin/env bash
set -eu

source $BSYS6/exports/version.sh
source $BSYS6/exports/require_target.sh windows
source $BSYS6/exports/require_artifact.sh setup
source $BSYS6/utils/require_choco.sh

echo "-> Building .nupkg" >&2
echo "v$VERSION -> v$CHOCO_VERSION"
tmpdir=$(mktemp -d)
echo "tmpdir is $tmpdir"
mkdir -p "$tmpdir/tools"
if [ "$FORGE_TYPE" == "github" ]; then
  # The installer is an asset of the release, there is no download bucket.
  source $BSYS6/exports/forge.sh
  export CHOCO_FILE="$(forge_asset_url "$FORGE_REPO_NAME" "$FULL_VERSION" "$(basename "$SETUP")")"
else
  export CHOCO_FILE="https://dl.librewolf.net/librewolf/$FULL_VERSION/$(basename "$SETUP")"
fi
export CHOCO_CHECKSUM="$(cat "$SETUP_SHA256")"
envsubst '$CHOCO_VERSION' \
  <"$BSYS6/../assets/choco/librewolf.nuspec.in" \
  >$tmpdir/librewolf.nuspec
envsubst '$CHOCO_FILE $CHOCO_CHECKSUM' \
  <"$BSYS6/../assets/choco/tools/chocolateyinstall.ps1.in" \
  >$tmpdir/tools/chocolateyinstall.ps1
cp "$BSYS6/../assets/choco/tools/chocolateyuninstall.ps1" "$tmpdir/tools"
(cd "$tmpdir" && "$MOZBUILD/chocolatey/choco" pack)

source $BSYS6/exports/move_artifact.sh "NUPKG" "$tmpdir" ".*\.nupkg"

rm -rf "$tmpdir"
