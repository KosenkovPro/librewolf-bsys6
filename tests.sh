#!/usr/bin/env bash
args=$*
rm -f tests-log.txt
script -q -e -O tests-log.txt -c "time make -f tests/Makefile $args"
