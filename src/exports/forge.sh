#!/usr/bin/env bash
set -eu

# Backend abstraction for the forge that hosts the sources, the releases and
# the build artifacts.
#
# forgejo (default)
#   A Forgejo/Gitea instance. Upstream LibreWolf uses https://librewolf.dev.
#   * releases:  $FORGE_URL/api/v1/repos/<owner>/<repo>/releases
#   * packages:  $FORGE_URL/api/packages/<owner>/generic/...
#   * artifacts: an S3 bucket
#
# github
#   GitHub. The release and its assets are used for everything, personal
#   accounts have no package registry and there is no S3 bucket.
#   * releases:  https://api.github.com/repos/<owner>/<repo>/releases
#   * artifacts: the assets of the release
#
# The backend is selected with $FORGE_TYPE, see exports/vars.sh.

source "$BSYS6/exports/vars.sh"

# Both backends expose the same /repos/<owner>/<repo>/... routes, only the
# prefix of the API base URL differs.
forge_api_base() {
  if [ "$FORGE_TYPE" = "github" ]; then
    echo "$FORGE_API_URL"
  else
    echo "$FORGE_URL/api/v1"
  fi
}

forge_auth_header() {
  if [ "$FORGE_TYPE" = "github" ]; then
    echo "Authorization: Bearer $1"
  else
    echo "Authorization: token $1"
  fi
}

# forge_api_get <path> [token]
# Without a token the request is anonymous, the api of github answers that
# with a low limit. $FORGE_TOKEN is used when it is set.
forge_api_get() {
  token="${2:-${FORGE_TOKEN:-}}"
  if [ -n "$token" ]; then
    curl -fsSL -H "$(forge_auth_header "$token")" -H "Accept: application/json" "$(forge_api_base)$1"
  else
    curl -fsSL -H "Accept: application/json" "$(forge_api_base)$1"
  fi
}

# forge_upstream_repo_name <repo>
# The name of a repository in the upstream forge. This fork uses a different
# name for the source repository.
forge_upstream_repo_name() {
  if [ "$1" == "$SOURCE_REPO" ]; then
    echo "$UPSTREAM_SOURCE_REPO"
  else
    echo "$1"
  fi
}

# forge_latest_release_tag <repo>
# The latest release tag of a repository, without the owner.
forge_latest_release_tag() {
  tag="$(forge_api_get "/repos/$FORGE_REPO_OWNER/$1/releases/latest" | jq -r '.tag_name // empty' || echo "")"
  if [ -z "$tag" ] && [ "$FORGE_TYPE" = "github" ]; then
    # The repository was not mirrored into this fork, ask the upstream forge.
    upstream_repo="$(forge_upstream_repo_name "$1")"
    tag="$(curl -fsSL -H "Accept: application/json" \
      "$UPSTREAM_FORGE_URL/api/v1/repos/$UPSTREAM_REPO_OWNER/$upstream_repo/releases/latest" |
      jq -r '.tag_name // empty' || echo "")"
  fi
  echo "$tag" | sed 's/^v//'
}

# forge_latest_tag <repo>
# The latest tag of a repository, without the owner.
# The tags are sorted by version, the order of the API is not reliable: it
# follows the creation of the refs, so a repository that got all its tags
# pushed at once does not answer with the newest version.
forge_latest_tag() {
  page=1
  tags=""

  while [ "$page" -le 20 ]; do
    result="$(forge_api_get "/repos/$FORGE_REPO_OWNER/$1/tags?per_page=100&page=$page" | jq -r '.[].name // empty' || true)"
    if [ -z "$result" ]; then
      break
    fi
    tags="$tags$result"$'\n'

    count="$(printf '%s\n' "$result" | grep -c . || true)"
    if [ "$count" -lt 100 ]; then
      break
    fi
    page=$((page + 1))
  done

  printf '%s' "$tags" | sed 's/^v//' |
    grep -E '^[0-9]+(\.[0-9]+)*(-[0-9]+)?$' | sort -V | tail -n 1
}

# forge_release_exists <owner/repo> <tag>
# Returns 0 when the release exists, non-zero otherwise.
forge_release_exists() {
  curl -fs -o /dev/null -H "Accept: application/json" \
    "$(forge_api_base)/repos/$1/releases/tags/$2"
}

# forge_asset_url <repo> <tag> <asset>
# The public download URL of a release asset.
forge_asset_url() {
  echo "$FORGE_URL/$FORGE_REPO_OWNER/$1/releases/download/$2/$3"
}

# forge_source_url <version>
# The URL of the LibreWolf source tarball for a version.
forge_source_url() {
  if [ "$FORGE_TYPE" = "github" ]; then
    forge_asset_url "$SOURCE_REPO" "$1" "librewolf-$1.source.tar.gz"
  else
    echo "$FORGE_URL/api/packages/$FORGE_REPO_OWNER/generic/librewolf-source/$1/librewolf-$1.source.tar.gz"
  fi
}
