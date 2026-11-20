#!/bin/sh
# Check FAST-Java on every Java file of a corpus, in a fresh Moose image, with the checks of a
# coverage run. Sample projects show what real code combines, which a grammar does not.
#
#   GCOV_CORPUS=/path/to/sources GCOV_RELEASE=25 scripts/census.sh census.tsv
#
# One line per file: its path in the corpus, then `pass`, `refused` when javac refuses it, or the
# check that failed and its message. GCOV_FAST_JAVA picks the FAST-Java to load, as for
# coverage.sh. Concurrent runs each need their own GCOV_BUILD and GCOV_ORACLE_PORT.

set -eu
. "$(dirname "$0")/common.sh"

[ $# -eq 1 ] || { echo "Usage: GCOV_CORPUS=DIR GCOV_RELEASE=N $0 OUT.tsv" >&2; exit 2; }
case "$1" in
	/*) GCOV_CENSUS_OUT="$1" ;;
	*) GCOV_CENSUS_OUT="$PWD/$1" ;;
esac
export GCOV_CENSUS_OUT
export GCOV_CORPUS="$(cd "$GCOV_CORPUS" && pwd)"

start_oracle
fresh_image
run_pharo "$ROOT/scripts/load.st" "$ROOT/scripts/census.st"
