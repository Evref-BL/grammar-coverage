#!/bin/sh
# Shared by the scripts: a fresh Moose image, the javac oracle, and a headless Pharo run.
#
# GCOV_BUILD          where images, the JLS cache and logs go (default: build/ in this repository)
# GCOV_MOOSE_ZIP_URL  the Moose image to start from (default: Moose 13, development)
# GCOV_PHARO_VM       the Pharo executable (default: the Pharo Launcher's 130-x64 VM)
# GCOV_ORACLE_PORT    the port of the javac oracle (default: 47811)
# JAVA_HOME           the JDK of the javac oracle; its javac must know the newest release asked

set -eu

ROOT=$(cd "$(dirname "$0")/.." && pwd)
BUILD=${GCOV_BUILD:-$ROOT/build}
MOOSE_ZIP_URL=${GCOV_MOOSE_ZIP_URL:-https://github.com/moosetechnology/Moose/releases/download/continuous/Moose13-development-Pharo64-13.zip}
PHARO_VM=${GCOV_PHARO_VM:-$HOME/Documents/Pharo/vms/130-x64/Pharo.app/Contents/MacOS/Pharo}
ORACLE_PORT=${GCOV_ORACLE_PORT:-47811}
export GCOV_ROOT="$ROOT"
export GCOV_JLS_CACHE="${GCOV_JLS_CACHE:-$BUILD/jls-cache}"
export GCOV_ORACLE_URL="http://127.0.0.1:$ORACLE_PORT"

# Unzip a fresh copy of the Moose image into $BUILD/image and set IMAGE to its .image file.
fresh_image() {
	mkdir -p "$BUILD"
	[ -f "$BUILD/moose.zip" ] || curl -fsSL -o "$BUILD/moose.zip" "$MOOSE_ZIP_URL"
	rm -rf "${BUILD:?}/image"
	mkdir -p "$BUILD/image"
	unzip -q "$BUILD/moose.zip" -d "$BUILD/image"
	IMAGE=$(find "$BUILD/image" -name '*.image' | head -n 1)
	[ -n "$IMAGE" ] || { echo "No image in $MOOSE_ZIP_URL" >&2; exit 1; }
}

# Start the javac oracle unless one already answers on the port; stop it on exit if started here.
start_oracle() {
	if curl -fs "$GCOV_ORACLE_URL/version" >/dev/null 2>&1; then
		echo "javac oracle already running: $(curl -fs "$GCOV_ORACLE_URL/version")"
		return
	fi
	mkdir -p "$BUILD"
	"$ROOT/javac-oracle/run.sh" "$ORACLE_PORT" >"$BUILD/oracle.log" 2>&1 &
	ORACLE_PID=$!
	trap 'curl -fs "$GCOV_ORACLE_URL/quit" >/dev/null 2>&1 || kill "$ORACLE_PID" 2>/dev/null || true' EXIT
	tries=0
	until curl -fs "$GCOV_ORACLE_URL/version" >/dev/null 2>&1; do
		tries=$((tries + 1))
		[ "$tries" -le 60 ] || { echo "The javac oracle did not start; see $BUILD/oracle.log" >&2; exit 1; }
		sleep 1
	done
	echo "javac oracle: $(curl -fs "$GCOV_ORACLE_URL/version")"
}

# Run Smalltalk scripts headless in $IMAGE, then quit.
run_pharo() {
	"$PHARO_VM" --headless "$IMAGE" st --quit "$@"
}
