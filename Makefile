.PHONY : debian arch world

debian :
	${MAKE} -f tests/Makefile world-debian

arch :
	${MAKE} -f tests/Makefile world-archlinux

world :
	${MAKE} -f tests/Makefile world-docker
