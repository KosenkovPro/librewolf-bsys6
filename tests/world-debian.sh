# world-debian.sh

apt-get -y update
apt-get -y upgrade
apt-get -y install build-essential curl jq make python3 python3-dev python3-pip wget








# bug: firefox-118.0.1 not building
#      https://forums.gentoo.org/viewtopic-p-8804547.html?sid=7faad46021bc44acd6ad8493bb132d2a
echo ""
echo ""
echo " INSTALLING RUST!!!!!"
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
echo " DONE INSTALLING RUST!!!!!"
echo ""
cd /cwd







cd /cwd
make -f tests/Makefile world


