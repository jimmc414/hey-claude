# Hey Claude 🚀

An ultralight, instant-access command-line interface that creates a frictionless bridge between your clipboard and Claude. Copy → Invoke → Response → Continue or Exit.

## Features

- **Zero Configuration**: Works immediately after installation
- **Clipboard-First**: Uses system clipboard as primary input
- **Instant Access**: Launch via command (`hc`) or system hotkey
- **Structured Output**: Control response format with operators
- **Streaming Responses**: See Claude's response in real-time
- **Simple Interaction**: Single-key continuation (SPACE/ESC)

## Prerequisites

1. **Claude CLI** (required):
   ```bash
   npm install -g @anthropic-ai/claude
   ```
   Then run `claude login` to authenticate.

2. **Clipboard Tool** (one of):
   - Linux: `xclip`, `xsel`, or `wl-clipboard`
   - macOS: `pbpaste` (built-in)

## Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/hey-claude.git
cd hey-claude

# Run the installer
./scripts/install.sh
```

The installer will:
- Check for required dependencies
- Install the script to `/usr/local/bin/heyclaude`
- Create a symlink `hc` for quick access
- Set up configuration directory

## Usage

### Basic Usage

1. **Copy text to clipboard** (Ctrl+C)
2. **Run Hey Claude**:
   ```bash
   hc
   ```
3. **Read Claude's response**
4. **Continue or exit**:
   - Press `SPACE` to continue the conversation
   - Press `ESC` to exit

### Using Operators

Control Claude's response format by prefixing your clipboard content with operators:

#### Length Control
- `brief:` - 1-2 sentence response
- `short:` - Single paragraph
- `medium:` - 2-3 paragraphs (default)
- `detailed:` - Comprehensive response
- `max 50 words:` - Word limit

#### Format Control
- `list:` - Bullet point format
- `steps:` - Numbered steps
- `tldr:` - Summary first, then details
- `table:` - Tabular format
- `json:` - JSON structure

#### Code-Specific
- `code only:` - Just code, no explanation
- `commented:` - Code with inline comments
- `diff:` - Show changes in diff format

#### Examples

Copy this to clipboard:
```
brief: explain async/await in Python
```

Copy this to clipboard:
```
list: benefits of static typing
```

Copy this to clipboard:
```
code only: fix: TypeError: cannot read property 'x' of undefined
```

### Setting Up Hotkeys

To launch Hey Claude with a keyboard shortcut (e.g., Super+Shift+C):

#### GNOME/Ubuntu
1. Open Settings → Keyboard → Shortcuts
2. Add custom shortcut
3. Name: "Hey Claude"
4. Command: `/usr/local/bin/heyclaude`
5. Set your preferred key combination

#### KDE Plasma
1. System Settings → Shortcuts → Custom Shortcuts
2. Edit → New → Global Shortcut → Command/URL
3. Set trigger and action to `/usr/local/bin/heyclaude`

#### Using xbindkeys (Universal)
1. Install xbindkeys: `sudo apt install xbindkeys`
2. Add to `~/.xbindkeysrc`:
   ```
   "heyclaude"
     Mod4+Shift+c
   ```
3. Run `xbindkeys`

## Configuration

Hey Claude works with zero configuration, but you can customize it via `~/.config/heyclaude/config`:

```bash
# Terminal settings
terminal_size=80x24
terminal_position=center

# Behavior
max_clipboard_size=10240

# Colors (ANSI codes)
color_system=\033[90m
color_response=\033[97m
color_prompt=\033[94m
```

## Examples

### Quick Code Review
1. Copy a function from your editor
2. Add `brief: review:` at the start
3. Run `hc`
4. Get a concise code review

### Error Debugging
1. Copy an error message
2. Prefix with `fix:`
3. Run `hc`
4. Get targeted solutions

### Learning Mode
1. Copy confusing documentation
2. Add `eli5:` (explain like I'm five)
3. Run `hc`
4. Get simple explanation

## Troubleshooting

### "Claude CLI not installed"
Install the official Claude CLI:
```bash
npm install -g @anthropic-ai/claude
claude login
```

### "No clipboard tool found"
Install a clipboard tool:
```bash
# Ubuntu/Debian
sudo apt install xclip

# Fedora
sudo dnf install xclip

# Arch
sudo pacman -S xclip
```

### "Failed to read clipboard"
Make sure you've copied something to the clipboard before running Hey Claude.

## Architecture

Hey Claude is designed as a single, self-contained bash script that:
- Detects available system tools
- Reads and processes clipboard content
- Enhances prompts based on operators
- Streams responses from Claude CLI
- Manages conversation continuity

## Project Metrics

📊 **Code**: 663 lines total
- `heyclaude` - 462 lines (main script)
- `install.sh` - 141 lines (installer)
- `tests/test_operators.sh` - 60 lines (test suite)

📚 **Documentation**: 4,467 lines total
- `implementation.md` - 691 lines (implementation guide)
- `requirements.md` - 554 lines (detailed specifications)
- `test_plan.md` - 534 lines (comprehensive test scenarios)
- `architecture.md` - 529 lines (system design)
- `sequence_diagram.md` - 419 lines (interaction flows)
- `call_graph.md` - 373 lines (function relationships)
- `ux_design.md` - 363 lines (user experience design)
- `data_flow_diagram.md` - 308 lines (data transformations)
- `EXECUTION_FLOW.md` - 228 lines (runtime behavior)
- `README.md` - 227 lines (user guide)
- `TEST_RESULTS.md` - 127 lines (test outcomes)
- `IMPLEMENTATION_SUMMARY.md` - 114 lines (project overview)

**Ratio**: 6.7:1 documentation to code

The main script is under 500 lines while implementing all core features.

## Contributing

Hey Claude is intentionally kept simple. When contributing:
- Maintain the single-file architecture
- Preserve zero-configuration functionality
- Keep the codebase under 500 lines
- Ensure backward compatibility


Built on top of the official [Claude CLI](https://www.anthropic.com/claude-cli) by Anthropic.