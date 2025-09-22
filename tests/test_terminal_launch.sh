#!/usr/bin/env bash
# Verify Hey Claude's terminal detection and entrypoint logic.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

# When a TERMINAL command is provided, the script should exec into it instead
# of running main. We use /bin/cat to capture the exec path output.
EXEC_OUTPUT="$TMP_DIR/exec.out"
TERMINAL=/bin/cat PATH="/usr/bin:/bin" bash "$PROJECT_ROOT/heyclaude" \
    </dev/null >"$EXEC_OUTPUT" 2>&1

if ! grep -q "# Hey Claude - Ultralight CLI for Claude" "$EXEC_OUTPUT"; then
    echo "Expected exec path to stream script contents via /bin/cat" >&2
    exit 1
fi

# Without a TTY and no detected terminal, the script should fail with a
# friendly error message instead of invoking main.
ERROR_STDOUT="$TMP_DIR/error.out"
ERROR_STDERR="$TMP_DIR/error.err"
if PATH="/usr/bin:/bin" bash "$PROJECT_ROOT/heyclaude" \
    </dev/null >"$ERROR_STDOUT" 2>"$ERROR_STDERR"; then
    echo "Expected Hey Claude to exit with error when no terminal is available" >&2
    exit 1
fi

if ! grep -q "Unable to locate a terminal emulator" "$ERROR_STDERR"; then
    echo "Missing friendly error message when no terminal is found" >&2
    exit 1
fi

echo "Terminal detection tests passed."
