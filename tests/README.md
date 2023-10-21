#### Testing Supported build platforms:

The supported platforms are:

* Debian
* Arch Linux
* Fedora (work in progress)

#### How to build for your local machine:
```
./tests.sh
```

#### How to target a specific OS/cpu:
```
TARGET=macos ARCH=arm64 ./tests.sh
```
#### How to get command help:
```
./tests.sh help
```
#### Please read this help first before testing.

##



This testing folder is about building the bsys6 artifacts locally. You'll need `make`.

* `make -f tests/Makefile` is the command to build librewolf on your local machine. If you use one of the supported build distro's, this should provide you with a nice locally built LibreWolf package.

* `make -f tests/Makefile world-docker` will build the 7 builds thrice using temporary docker images, for: debian, archlinux, fedora.

```
###
### IMPORTANT :
###
###  TARGET  - The target platform (available: linux windows macos; currently: linux)
###  ARCH    - The target architecture (available: x86_64 arm64 i686; currently: x86_64)
###
### bsys6 also responds to a `./env.sh` file with values for the above parameters.
###
```
