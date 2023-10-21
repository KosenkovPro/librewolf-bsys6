#!/usr/bin/env bash
args=$*
rm -f bsys6-tests-build-log.txt
script -q -e -O bsys6-tests-build-log.txt -c "time make -f tests/Makefile $args"
