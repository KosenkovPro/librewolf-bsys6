#!/usr/bin/env bash
set -eu

$BSYS6/utils/require_command.sh awk gpg

if [ -n "${SIGNING_KEY:-}" ] && [ -z "${SIGNING_KEY_FPR:-}" ]; then
  echo "-> Setting up gpg signing using provided private key," >&2
  export SIGNING_KEY_FPR="$(echo -e "$SIGNING_KEY" | gpg --with-colons --import-options show-only --import --fingerprint | awk -F: '$1 == "fpr" {print $10;}' | head -n 1)"
  echo "   fingerprint is '$SIGNING_KEY_FPR'" >&2
  echo -e "$SIGNING_KEY" | gpg --import
  # dpkg-sig refuses to sign with a key that gpg does not trust. The key of the
  # build belongs to the build itself, so it is trusted completely.
  echo "${SIGNING_KEY_FPR}:6:" | gpg --import-ownertrust
  cat >>~/.rpmmacros <<EOF
%_signature gpg
%_gpg_name  ${SIGNING_KEY_FPR}
EOF
fi
