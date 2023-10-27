# build-on-fedora.sh

## linux or all

dnf -y update
dnf -y install gcc-c++ make curl jq python3 python3-devel python3-pip wget bzip2 dpkg util-linux rpm-build rsync bzip2-devel

# fix rust 1.73 problem by going back to 72
./tests/fix-rust72.sh

## macos

#  $BSYS6/utils/dependencies.sh "binutils-aarch64-linux-gnu" "aarch64-linux-gnu-binutils"
dnf -y install binutils-aarch64-linux-gnu

# fix dmg .so bug
# https://github.com/zestdocs/zest/issues/12
ln -s /usr/lib64/libbz2.so.1 /usr/lib64/libbz2.so.1.0

## windows



## invoke the huge docker build
cd /cwd
make -f tests/Makefile world-windows
