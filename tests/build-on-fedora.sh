# build-on-fedora.sh

dnf -y update
dnf -y install gcc-c++ make curl jq python3 python3-devel python3-pip wget bzip2 dpkg

./tests/fix-rust72.sh

cd /cwd
make -f tests/Makefile world
