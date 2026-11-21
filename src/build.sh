#!/usr/bin/env bash
set -eu

source $BSYS6/exports/target.sh
source $BSYS6/exports/version.sh

source "$BSYS6/source.sh"

echo "-> Running 'mach build'" >&2
# We need to be in the $SOURCE directory, otherwise the path could be too long for
# the Microsoft (R) Macro Assembler.
# The JOBS variable limits the number of parallel compilations. The rust code
# of the release build is compiled with link time optimization, the compiler
# needs a lot of memory for it.
if [ "${VERBOSE:-}" == "true" ]; then
  (cd $SOURCE && ./mach build -v ${JOBS:+-j "$JOBS"})
else
  (cd $SOURCE && ./mach build ${JOBS:+-j "$JOBS"})
fi
