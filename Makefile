all :
	${MAKE} -f tests/Makefile world-debian

world :
	${MAKE} -f test/Makefile world-docker
