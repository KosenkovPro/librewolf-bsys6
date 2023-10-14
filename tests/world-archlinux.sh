# world-archlinux.sh

pacman -Syu
pacman -S --noconfirm make jq python3 python-pip

cd /cwd
make -f tests/Makefile.docker world

