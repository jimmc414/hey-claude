#!/usr/bin/env bash
# Hey Claude Installation Script

set -euo pipefail

# Colors
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
BLUE="\033[34m"
RESET="\033[0m"

# Installation paths
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="heyclaude"
SYMLINK_NAME="hc"
CONFIG_DIR="$HOME/.config/heyclaude"

echo -e "${BLUE}Hey Claude Installation${RESET}"
echo "========================"
echo

# Check if running with appropriate permissions
if [[ ! -w "$INSTALL_DIR" ]]; then
    echo -e "${YELLOW}Note: Installation to $INSTALL_DIR requires sudo${RESET}"
    NEED_SUDO=true
else
    NEED_SUDO=false
fi

# Check for Claude CLI
echo -n "Checking for Claude CLI... "
if command -v claude &>/dev/null; then
    echo -e "${GREEN}✓ Found$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo '')${RESET}"
else
    echo -e "${RED}✗ Not found${RESET}"
    echo
    echo "Hey Claude requires the official Claude CLI tool."
    echo "Please install it first:"
    echo
    echo -e "${YELLOW}npm install -g @anthropic-ai/claude${RESET}"
    echo
    echo "After installing Claude CLI, run this installer again."
    exit 1
fi

# Check for clipboard tools
echo -n "Checking for clipboard tools... "
CLIPBOARD_FOUND=false
for tool in xclip xsel wl-paste pbpaste; do
    if command -v "$tool" &>/dev/null; then
        echo -e "${GREEN}✓ Found $tool${RESET}"
        CLIPBOARD_FOUND=true
        break
    fi
done

if [[ "$CLIPBOARD_FOUND" == false ]]; then
    echo -e "${RED}✗ None found${RESET}"
    echo
    echo "Please install a clipboard tool:"
    echo "  Ubuntu/Debian: sudo apt install xclip"
    echo "  Fedora: sudo dnf install xclip"
    echo "  Arch: sudo pacman -S xclip"
    echo "  macOS: pbpaste is built-in"
    exit 1
fi

# Install the script
echo
echo "Installing Hey Claude..."

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Copy script to installation directory
if [[ "$NEED_SUDO" == true ]]; then
    sudo cp "$PROJECT_ROOT/heyclaude" "$INSTALL_DIR/$SCRIPT_NAME"
    sudo chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
    
    # Create symlink
    sudo ln -sf "$INSTALL_DIR/$SCRIPT_NAME" "$INSTALL_DIR/$SYMLINK_NAME"
else
    cp "$PROJECT_ROOT/heyclaude" "$INSTALL_DIR/$SCRIPT_NAME"
    chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
    
    # Create symlink
    ln -sf "$INSTALL_DIR/$SCRIPT_NAME" "$INSTALL_DIR/$SYMLINK_NAME"
fi

echo -e "${GREEN}✓ Installed to $INSTALL_DIR/$SCRIPT_NAME${RESET}"
echo -e "${GREEN}✓ Created symlink 'hc' for quick access${RESET}"

# Create config directory
mkdir -p "$CONFIG_DIR"
echo -e "${GREEN}✓ Created config directory at $CONFIG_DIR${RESET}"

# Create sample config if it doesn't exist
if [[ ! -f "$CONFIG_DIR/config" ]]; then
    cat > "$CONFIG_DIR/config.sample" << 'EOF'
# Hey Claude Configuration
# Uncomment and modify values as needed

# Terminal settings
#terminal=auto              # or specific: alacritty, kitty, gnome-terminal
#terminal_size=80x24       # columns x rows
#terminal_position=center  # center, top, mouse

# Behavior
#max_clipboard_size=10240  # bytes
#stream_response=true

# Colors (ANSI escape codes)
#color_system=\033[90m     # Dim gray
#color_response=\033[97m   # Bright white
#color_prompt=\033[94m     # Light blue
#color_error=\033[91m      # Light red
#color_voice=\033[95m      # Light purple
EOF
    echo -e "${GREEN}✓ Created sample config at $CONFIG_DIR/config.sample${RESET}"
fi

echo
echo -e "${BLUE}Installation complete!${RESET}"
echo
echo "Usage:"
echo "  heyclaude    - Run Hey Claude"
echo "  hc           - Short alias"
echo
echo "Quick start:"
echo "  1. Copy some text to your clipboard"
echo "  2. Run 'hc' in terminal"
echo "  3. Claude will respond to your clipboard content"
echo "  4. Press SPACE to continue or ESC to exit"
echo
echo "Operators (optional):"
echo "  brief: explain this     - Get a concise response"
echo "  list: summarize this    - Get a bullet list"
echo "  code only: fix this     - Get just code, no explanation"
echo
echo "To set up a system hotkey (e.g., Super+Shift+C):"
echo "  - Use your desktop environment's keyboard settings"
echo "  - Set the command to: $INSTALL_DIR/$SCRIPT_NAME"
echo
echo -e "${GREEN}Enjoy using Hey Claude!${RESET}"