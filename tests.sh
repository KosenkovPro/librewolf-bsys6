#!/usr/bin/env bash
args=$*
rm -f tests-log.txt
script -q -m advanced -e -O tests-log.txt -c "time make -f tests/Makefile $args"
