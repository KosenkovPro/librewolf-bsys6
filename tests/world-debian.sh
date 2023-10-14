# world-debian.sh

apt-get -y update
apt-get -y upgrade

apt-get -y install make curl jq

cd /cwd
make world

