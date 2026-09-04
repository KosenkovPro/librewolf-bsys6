#!/usr/bin/env bash
set -eu

source $BSYS6/exports/target.sh
source $BSYS6/exports/require_build.sh

echo "-> Packaging locales (output hidden)" >&2
cat "$SOURCE/browser/locales/shipped-locales" | xargs "$SOURCE/mach" package-multi-locale --locales >/dev/null 2>/dev/null
echo "-> Finished packaging locales" >&2

if [ "$TARGET" == "windows" ]; then
  source $BSYS6/exports/move_artifact.sh "PACKAGE" "$SOURCE/obj-$MOZ_TARGET/dist" "librewolf-.*\.zip"
elif [ "$TARGET" == "macos" ]; then
  for dmg in "$SOURCE/obj-$MOZ_TARGET/dist/"librewolf-*.dmg; do
    tmpdir="$(mktemp -d)"
    (cd "$SOURCE" && ./mach python -m mozbuild.action.unpack_dmg "$dmg" "$tmpdir/dmg" >/dev/null)
    app="$(ls -d "$tmpdir"/dmg/*.app)"
    $BSYS6/utils/generate_mar.sh "$app"
    source $BSYS6/exports/move_artifact.sh "UPDATE" "." ".*\.mar"
  done
  source $BSYS6/exports/move_artifact.sh "PACKAGE" "$SOURCE/obj-$MOZ_TARGET/dist" "librewolf-.*\.dmg"
else
  source $BSYS6/exports/move_artifact.sh "PACKAGE" "$SOURCE/obj-$MOZ_TARGET/dist" "librewolf-.*\.tar\.xz"
fi
