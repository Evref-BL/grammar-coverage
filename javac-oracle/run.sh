#!/bin/sh
# Starts the javac oracle. JAVA_HOME picks the JDK, the first argument the port (0: any free port).
JAVA="${JAVA_HOME:+$JAVA_HOME/bin/}java"
exec "$JAVA" --add-exports jdk.compiler/com.sun.tools.javac.tree=ALL-UNNAMED \
	"$(dirname "$0")/JavacOracle.java" "${1:-0}"
