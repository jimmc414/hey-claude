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

# Provide a mock gnome-terminal whose arguments contain spaces to ensure the
# array-based TERMINAL_CMD launches correctly.
GNOME_LOG="$TMP_DIR/gnome.log"
cat <<'EOF' >"$TMP_DIR/gnome-terminal"
#!/usr/bin/env bash
printf '%s\n' "$@" >"$GNOME_LOG"
EOF
chmod +x "$TMP_DIR/gnome-terminal"

GNOME_STDOUT="$TMP_DIR/gnome.out"
GNOME_STDERR="$TMP_DIR/gnome.err"
PATH="$TMP_DIR:/usr/bin:/bin" bash "$PROJECT_ROOT/heyclaude" \
    </dev/null >"$GNOME_STDOUT" 2>"$GNOME_STDERR"

if [[ ! -s "$GNOME_LOG" ]]; then
    echo "Expected mock gnome-terminal to record invocation" >&2
    exit 1
fi

mapfile -t GNOME_ARGS <"$GNOME_LOG"
if [[ "${GNOME_ARGS[1]}" != "--title" ]] || [[ "${GNOME_ARGS[2]}" != "Hey Claude" ]]; then
    echo "gnome-terminal arguments were not passed as discrete array elements" >&2
    printf 'Captured args:\n'
    printf '  %s\n' "${GNOME_ARGS[@]}"
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
