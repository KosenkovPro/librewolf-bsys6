# build-on-fedora.sh

dnf -y update
dnf -y install gcc-c++ make curl jq python3 python3-devel python3-pip wget bzip2 dpkg util-linux rpm-build

#  $BSYS6/utils/dependencies.sh "binutils-aarch64-linux-gnu" "aarch64-linux-gnu-binutils"
dnf -y install binutils-aarch64-linux-gnu

./tests/fix-rust72.sh

cd /cwd
make -f tests/Makefile world-linux
