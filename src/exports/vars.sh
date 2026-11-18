#!/usr/bin/env bash
set -e

if [ -f "$BSYS6/../env.sh" ]; then
  source $BSYS6/../env.sh
fi

if [ -z "$BSYS6" ]; then
  export BSYS6="$(dirname "$(readlink -f "$0/..")")"
fi

if [ -z "${ARCH:-}" ]; then
  export ARCH="x86_64"
fi

if [ -z "${MOZBUILD:-}" ]; then
  export MOZBUILD="$HOME/.mozbuild"
fi

if [ -z "${WORKDIR:-}" ]; then
  export WORKDIR="$HOME/.local/share/bsys6/work"
fi
mkdir -p "$WORKDIR"

export AVAILABLE_TARGETS="linux windows macos dind release"
export AVAILABLE_ARCHS="x86_64 arm64"
export AVAILABLE_ARTIFACTS="SOURCE PACKAGE MSIX SETUP PORTABLE NUPKG DEB RPM WINUPDATER"

if ! $BSYS6/utils/list_contains.sh "$AVAILABLE_ARCHS" "$ARCH"; then
  echo "Unsupported architecture $ARCH"
  exit 1
fi

# The forge backend: "forgejo" (the default) or "github".
if [ -z "${FORGE_TYPE:-}" ]; then
  export FORGE_TYPE="forgejo"
fi

if [ "$FORGE_TYPE" == "github" ]; then
  # GitHub is not a forgejo instance: the API lives on api.github.com and the
  # web interface on github.com. There is no package registry for personal
  # accounts, the release assets are used instead.
  if [ -z "${FORGE_URL:-}" ]; then
    export FORGE_URL="https://github.com"
  fi
  if [ -z "${FORGE_API_URL:-}" ]; then
    export FORGE_API_URL="https://api.github.com"
  fi
  if [ -z "${FORGE_REPO_OWNER:-}" ]; then
    export FORGE_REPO_OWNER="${GITHUB_REPOSITORY_OWNER:-KosenkovPro}"
  fi
  if [ -z "${FORGE_REPO:-}" ]; then
    export FORGE_REPO="${GITHUB_REPOSITORY:-}"
    export FORGE_REPO="${FORGE_REPO#*/}"
    if [ -z "$FORGE_REPO" ]; then
      export FORGE_REPO="librewolf-bsys6"
    fi
    export FORGE_REPO="$FORGE_REPO_OWNER/$FORGE_REPO"
  fi
  # The repository that holds the LibreWolf sources.
  if [ -z "${SOURCE_REPO:-}" ]; then
    export SOURCE_REPO="librewolf-source"
  fi
else
  if [ -z "${FORGE_URL:-}" ]; then
    export FORGE_URL="https://librewolf.dev"
  fi
  if [ -z "${FORGE_API_URL:-}" ]; then
    export FORGE_API_URL="$FORGE_URL/api/v1"
  fi
  if [ -z "${FORGE_REPO_OWNER:-}" ]; then
    export FORGE_REPO_OWNER="librewolf"
  fi
  if [ -z "${FORGE_REPO:-}" ]; then
    export FORGE_REPO="librewolf/bsys6"
  fi
  # The repository that holds the LibreWolf sources.
  if [ -z "${SOURCE_REPO:-}" ]; then
    export SOURCE_REPO="source"
  fi
fi

# The upstream forge, used as a fallback for the repositories that are not
# mirrored into this fork (winupdater, vc_redist, ...).
if [ -z "${UPSTREAM_FORGE_URL:-}" ]; then
  export UPSTREAM_FORGE_URL="https://librewolf.dev"
fi

if [ -z "${UPSTREAM_REPO_OWNER:-}" ]; then
  export UPSTREAM_REPO_OWNER="librewolf"
fi

# The name of the source repository in the upstream forge. This fork uses a
# different name for it.
if [ -z "${UPSTREAM_SOURCE_REPO:-}" ]; then
  export UPSTREAM_SOURCE_REPO="source"
fi

# The Visual C++ redistributable. It is not mirrored into this fork, so it is
# always taken from the upstream forge.
if [ -z "${VC_REDIST_URL:-}" ]; then
  if [ "$FORGE_TYPE" == "github" ]; then
    export VC_REDIST_URL="$UPSTREAM_FORGE_URL/$UPSTREAM_REPO_OWNER/vc_redist/releases/download/latest"
  else
    export VC_REDIST_URL="$FORGE_URL/$FORGE_REPO_OWNER/vc_redist/releases/download/latest"
  fi
fi

# Optional mirror forge
if [ -z "${MIRROR_FORGE_URL:-}" ]; then
  export MIRROR_FORGE_URL="https://codeberg.org"
fi

if [ -z "${MIRROR_FORGE_REPO_OWNER:-}" ]; then
  export MIRROR_FORGE_REPO_OWNER="librewolf"
fi

if [ -z "${MIRROR_FORGE_REPO:-}" ]; then
  export MIRROR_FORGE_REPO="librewolf/bsys6"
fi
