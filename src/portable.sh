#!/usr/bin/bash
set -eu

source $BSYS6/exports/require_target.sh windows
source $BSYS6/exports/require_artifact.sh package
$BSYS6/utils/require_command.sh "jq" "zip" "unzip" "wget"

echo "-> Building portable zip" >&2
tmpdir="$(mktemp -d)"

cd $tmpdir
mkdir -p librewolf-$VERSION/Profiles/Default
mkdir -p librewolf-$VERSION/LibreWolf

cd librewolf-$VERSION/LibreWolf
unzip -q $PACKAGE
mv librewolf/* .
rmdir librewolf
# https://gitlab.com/librewolf-community/browser/windows/-/issues/244
case "$ARCH" in
x86_64) VC_REDIST_URL="https://gitlab.com/librewolf-community/browser/windows/uploads/7106b776dc663d985bb88eabeb4c5d7d/vc_redist.x64-extracted.zip" ;;
i686) VC_REDIST_URL="https://gitlab.com/librewolf-community/browser/bsys6/uploads/c4f4203ba35a344f28de28c525951e40/vc_redist_x32.zip" ;;
*) echo "Notice: No Visual C++ Redistributable available for architecture '$ARCH', excluding the dlls from the windows portable" ;;
esac
if [ -n "${VC_REDIST_URL:-}" ]; then
  wget -q -O ./vc_redist.zip "$VC_REDIST_URL"
  unzip -q vc_redist.zip
  rm vc_redist.zip
fi
cd ..

# ahk-tools by @ltGuillaume
$BSYS6/utils/download_codeberg.sh "ltguillaume/librewolf-winupdater" 'LibreWolf-WinUpdater.*\\.zip' "LibreWolf-WinUpdater.zip"
$BSYS6/utils/download_codeberg.sh "ltguillaume/librewolf-portable" 'LibreWolf-Portable.*\\.zip' "LibreWolf-Portable.zip"
unzip LibreWolf-WinUpdater.zip
unzip LibreWolf-Portable.zip
rm LibreWolf-WinUpdater.zip LibreWolf-Portable.zip

# extra files from the zip files
rm *.url

# make the final zip
cd $tmpdir
zip -r9 librewolf-$VERSION.en-US.win64-portable.zip librewolf-$VERSION

source $BSYS6/exports/move_artifact.sh "PORTABLE" "$tmpdir" "librewolf-.*\.zip"
