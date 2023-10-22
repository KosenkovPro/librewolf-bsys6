#!/usr/bin/env bash
args=$*
rm -f tests/tests-log.txt
script -q -m advanced -e -O tests/tests-log.txt -c "time make -f tests/Makefile $args"
