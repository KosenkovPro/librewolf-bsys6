#
# Bsys6 batch commands collection, this
# is ment for internal use only.
#

#  TARGET  - The target platform (available: linux windows macos; currently: linux)
#  ARCH    - The target architecture (available: x86_64 arm64 i686; currently: x86_64)

PHONY_TARGETS = help currently local build world world-linux world-macos world-windows clean clobber source update bootstrap  world-archlinux world-debian world-docker



.PHONY : $(PHONY_TARGETS)

help :
	@echo "Use: make $(PHONY_TARGETS)"
	@echo ""
	@echo "  currently     - show current bsys6 build settings."
	@echo "  build         - For my detected / set system, run a full local build."
	@echo "                  so, ''TARGET=macos ARCH=arm64 make build'' builds for that."
	@echo ""
	@echo "  world         - Build all architectures on all systems. (7 builds)"
	@echo ""
	@echo "  world-linux   - Build for linux (3 builds: x86_64 arm64 i686)"
	@echo "  world-macos   - Build for macos (2 builds: x86_64 arm64)"
	@echo "  world-windows - Build for windows (2 builds: x86_64 i686)"
	@echo ""
	@echo " clean, clobber, source, update, bootstrap, - proxy ./bsys6 commands, see './bsys6 help'."
	@echo ""




world : world-linux world-macos world-windows


world-linux :
	( t=linux; a=x86_64; TARGET=$$t ARCH=$$a ${MAKE} -f tests/Makefile build && TARGET=$$t ARCH=$$a ./bsys6 deb && TARGET=$$t ARCH=$$a ./bsys6 rpm )
	( t=linux; a=arm64;  TARGET=$$t ARCH=$$a ${MAKE} -f tests/Makefile build && TARGET=$$t ARCH=$$a ./bsys6 deb && TARGET=$$t ARCH=$$a ./bsys6 rpm )
	( t=linux; a=i686;   TARGET=$$t ARCH=$$a ${MAKE} -f tests/Makefile build && TARGET=$$t ARCH=$$a ./bsys6 deb && TARGET=$$t ARCH=$$a ./bsys6 rpm )

world-macos :
	( t=macos; a=x86_64; TARGET=$$t ARCH=$$a ${MAKE} -f tests/Makefile build )
	( t=macos; a=arm64;  TARGET=$$t ARCH=$$a ${MAKE} -f tests/Makefile build )

world-windows :
	( t=windows; a=x86_64; TARGET=$$t ARCH=$$a ${MAKE} -f tests/Makefile build && TARGET=$$t ARCH=$$a ./bsys6 setup msix portable nupkg )
	( t=windows; a=i686;   TARGET=$$t ARCH=$$a ${MAKE} -f tests/Makefile build && TARGET=$$t ARCH=$$a ./bsys6 setup msix portable nupkg )




#
# proxy bsys6 commands:
#


clean :
	./bsys6 clean

clobber :
	-./bsys6 clobber

source :
	./bsys6 source

update :
	./bsys6 update

bootstrap :
	./bsys6 bootstrap




# trivial subcommands
currently :
	./bsys6 help | grep currently


build :
	${MAKE} -f tests/Makefile currently

	./bsys6 clean
	./bsys6 bootstrap
	./bsys6 prepare
	./bsys6 package



#
# world-docker is probably the worst thing I can do
# to my quad core, a total of 2*7=14 builds of LW.
#

world-docker : world-archlinux world-debian


world-archlinux :

	docker run -it --rm -v "$$(pwd):/cwd:rw" -w /cwd archlinux /bin/sh -c tests/world-archlinux.sh

world-debian :

	docker run -it --rm -v "$$(pwd):/cwd:rw" -w /cwd debian /bin/sh -c tests/world-debian.sh
