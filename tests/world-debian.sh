# world-debian.sh

apt-get -y update
apt-get -y upgrade
apt-get -y install build-essential curl jq make python3 python3-dev python3-pip wget

./tests/fix-rust72.sh

cd /cwd
make -f tests/Makefile world
