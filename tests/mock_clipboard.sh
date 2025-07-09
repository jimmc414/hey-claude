#!/bin/bash
# Mock clipboard for testing Hey Claude

CLIPBOARD_FILE="/tmp/mock_clipboard.txt"

case "$1" in
    -selection)
        if [[ "$2" == "clipboard" && "$3" == "-o" ]]; then
            # Read mode
            if [[ -f "$CLIPBOARD_FILE" ]]; then
                cat "$CLIPBOARD_FILE"
            else
                echo ""
            fi
        elif [[ "$2" == "clipboard" && "$3" == "-i" ]]; then
            # Write mode
            cat > "$CLIPBOARD_FILE"
        fi
        ;;
    *)
        # Default read mode for simple call
        if [[ -f "$CLIPBOARD_FILE" ]]; then
            cat "$CLIPBOARD_FILE"
        else
            echo ""
        fi
        ;;
esac