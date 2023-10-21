## bsys6/tests ReadMe file

This testing folder is about building the bsys6 artifacts locally. You'll need `make`.

* `make -f tests/Makefile` is the command to build librewolf on your local machine. If you use one of the supported build distro's, this should provide you with a nice locally built LibreWolf package.

* `make -f tests/Makefile world-docker` will build the 7 builds thrice using temporary docker images, for: debian, archlinux, fedora.
