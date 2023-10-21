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

```
IMPORTANT!

# TARGET - The target platform (available: linux windows macos)
# ARCH   - The target architecture (available: x86_64 arm64 i686)

bsys6 also responds to a `./env.sh` file with values for the above parameters.
```
