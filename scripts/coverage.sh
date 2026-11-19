#!/bin/sh
# Test FAST-Java against the grammar of JLS editions, in a fresh Moose image.
#
#   scripts/coverage.sh 8 17 21 25
#
# The reports go to $GCOV_OUT (default: reports/ in this repository), one directory per edition.
# GCOV_FAST_JAVA picks the FAST-Java to load (default: its v4 branch on GitHub); see scripts/load.st,
# scripts/coverage.st and scripts/common.sh for the other settings.

set -eu
. "$(dirname "$0")/common.sh"

export GCOV_EDITIONS="${*:-25}"
export GCOV_OUT="${GCOV_OUT:-$ROOT/reports}"

start_oracle
fresh_image
run_pharo "$ROOT/scripts/load.st" "$ROOT/scripts/coverage.st"
for edition in $GCOV_EDITIONS; do
	echo "SE $edition: $GCOV_OUT/se$edition/summary.md"
done
