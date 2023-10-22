#### Testing Supported build platforms:

This testing folder is about building the bsys6 artifacts locally.

The supported platforms are:

* Debian
* Arch Linux
* Fedora (work in progress)

The following environment variables specify what to build for:

* TARGET = The target platform (linux windows macos)
* ARCH = The target architecture (x86_64 arm64 i686)

#### How to build for your local machine:
```
./tests/tests.sh
```

#### How to target a specific OS/cpu:
```
TARGET=windows ARCH=x86_64 ./tests/tests.sh
```
#### How to build all artifacts:
```
./tests/tests.sh world
```
#### How to get command help:
```
./tests/tests.sh help
```
#### Please read this help first before testing.

##

To start fresh with your own LibreWolf, find a good folder for it, and:
```
mkdir librewolf
cd librewolf

# repositories to clone:
git clone https://codeberg.org/librewolf/source.git
git clone https://codeberg.org/librewolf/bsys6.git
```
Build the latest source dir:
```
cd source
git pull
make dir
cd ..
```
#### At this point you can patch the source dir further to your liking.

And to build:
```
cd bsys6
git pull

export VERSION=$(cat ../source/version)
export RELEASE=$(cat ../source/release)
export SOURCEDIR=$(pwd)/../source/librewolf-$VERSION-$RELEASE
export TARGET=windows
export ARCH=x86_64

./tests/tests.sh
```
Then you can just continue to run `tests.sh` to build, or you use `./bsys6` directly using all the commands it supports. 

Run `./bsys6` without parameters to get the commandline help. bsys6 also responds to a `./env.sh` file with values for the above parameters.
