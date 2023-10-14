# world-debian.sh

apt-get -y update
apt-get -y upgrade

apt-get -y install make

cd /cwd
make world

