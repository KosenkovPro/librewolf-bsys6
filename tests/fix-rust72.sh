#
# Note: This bug is present in the current build: 118.0.2, and also in 118.0.1
#
# reference:
# bug: firefox-118.0.1 not building
#      https://forums.gentoo.org/viewtopic-p-8804547.html?sid=7faad46021bc44acd6ad8493bb132d2a
#
# hope this goes away soon

echo ""
echo ""
echo ""

cd /
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > tmp.sh && chmod +x tmp.sh && ./tmp.sh -y && rm -f tmp.sh
export PATH=$PATH:/root/.cargo/bin
rustup install 1.72.0
rustup uninstall 1.73.0
rustup override set 1.72.0
rustc --version

echo ""
echo ""
echo ""
