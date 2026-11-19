#!/bin/sh
# Print what changed in the JLS grammar between two editions.
#
#   scripts/grammar-diff.sh 21 25
#
# `+` a production added, `-` one removed, `~` one changed with the alternatives it lost and gained.

set -eu
. "$(dirname "$0")/common.sh"

[ $# -eq 2 ] || { echo "Usage: $0 OLD_EDITION NEW_EDITION" >&2; exit 2; }
export GCOV_OLD="$1" GCOV_NEW="$2" GCOV_FAST_JAVA=none

fresh_image
run_pharo "$ROOT/scripts/load.st" "$ROOT/scripts/grammar-diff.st"
