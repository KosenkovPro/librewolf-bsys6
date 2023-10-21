# world-archlinux.sh

pacman -Syu --noconfirm
pacman -S --noconfirm make jq python3 python-pip sudo gcc

./tests/fix-rust72.sh

cd /cwd
make -f tests/Makefile world

