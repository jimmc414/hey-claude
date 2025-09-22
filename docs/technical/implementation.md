# Hey Claude - Implementation Guide

## Overview

This document guides the implementation of Hey Claude as a single bash script that creates a frictionless interface between clipboard content and Claude. The implementation prioritizes clarity over cleverness, directness over abstraction.

**Implementation Philosophy**: Write code that a tired developer can understand at 3 AM.

## Prerequisites

### Developer Knowledge
- Bash scripting (intermediate level)
- Unix process model
- Basic terminal escape sequences
- Shell command piping and redirection

### Development Environment
- Any Linux/macOS system
- Text editor
- Terminal for testing
- Node.js and npm (for Claude CLI)

### Required Dependencies
- **Claude CLI**: The official Claude command-line interface
  ```
  npm install -g @anthropic-ai/claude
  ```
  - Verify with: `claude --version`
  - Set up API key: `claude login` (handled by Claude CLI)
  - Hey Claude uses: `claude -p` and `claude -c` commands

### System Dependencies
- Clipboard tool (xclip/xsel/wl-paste/pbpaste)
- Terminal emulator
- Optional: Audio tools for voice features

## Implementation Structure

### File Organization
```
heyclaude
├── Single bash script file
├── No subdirectories
├── No auxiliary files
└── Self-contained implementation
```

### Script Sections (In Order)

1. **Shebang and Script Header**
   - Use `#!/usr/bin/env bash` for portability
   - Brief comment explaining purpose
   - Version identifier comment

2. **Configuration Defaults**
   - Define all default values as variables
   - Use CAPS for constants
   - Group related settings

3. **Utility Functions**
   - Error display function
   - Cleanup function
   - Animation functions

4. **Detection Functions**
   - Find clipboard tool
   - Find terminal emulator
   - Check for Claude CLI
   - Check for voice tools

5. **Input Functions**
   - Read clipboard
   - Capture voice
   - Merge inputs

6. **Display Functions**
   - Show status
   - Stream response
   - Show prompt

7. **Main Logic**
   - Parse invocation method
   - Execute flow
   - Handle continuation

8. **Script Entry Point**
   - Set up signal handlers
   - Run main logic
   - Ensure cleanup

## Detailed Implementation Steps

### Step 1: Script Setup

#### 1.1 Header and Safety
Start with safety settings that catch errors early:
- Set bash error flags (`set -euo pipefail`)
- But selectively disable for tool detection
- Define script version and name

#### 1.2 Configuration Structure
Create a configuration section with clear defaults:
```
# All configuration in one place
# Terminal settings
DEFAULT_TERMINAL_SIZE="80x24"
DEFAULT_TERMINAL_POSITION="center"

# Colors (using tput for portability)
COLOR_SYSTEM="\033[90m"     # Dim gray
COLOR_RESPONSE="\033[97m"   # Bright white
COLOR_PROMPT="\033[94m"     # Light blue
COLOR_ERROR="\033[91m"      # Light red
COLOR_VOICE="\033[95m"      # Light purple
COLOR_RESET="\033[0m"       # Reset

# Behavior
MAX_CLIPBOARD_SIZE=10240
VOICE_MAX_DURATION=30
```

#### 1.3 Global State
Define minimal global variables:
- CLIPBOARD_TOOL (detected)
- TERMINAL_CMD (detected)
- HAS_VOICE (detected)
- CONTINUATION_MODE (runtime state)

### Step 2: Utility Functions

#### 2.1 Error Display
Create a function that shows errors consistently:
- Takes error message as parameter
- Prepends with ⚠️ symbol
- Uses error color
- Writes to stderr
- Optionally exits with code

#### 2.2 Cleanup Handler
Create cleanup function for graceful exit:
- Reset terminal colors
- Kill any child processes
- Clear any temporary files (if created)
- Show exit message if interrupted

#### 2.3 Animation Functions
Create simple animation for status:
- Rotating spinner: ◐ ◓ ◑ ◒
- Updates in-place using carriage return
- Stops cleanly when done

### Step 3: Detection Functions

#### 3.1 Clipboard Tool Detection
Function to find available clipboard tool:
```
Logic:
1. Check each tool in order (xclip, xsel, wl-paste, pbpaste)
2. Use 'command -v' to test availability
3. Set global CLIPBOARD_TOOL variable
4. Return success if found, failure if none
```

#### 3.2 Terminal Detection
Function to find terminal emulator:
```
Logic:
1. If TERMINAL env var set, use it
2. Otherwise try common terminals in order
3. Build command array with size and title flags (no embedded quoting)
4. Set global TERMINAL_CMD array variable
```

#### 3.3 Claude CLI Detection
Simple check for Claude:
```
Logic:
1. Use 'command -v claude'
2. If not found, show installation instructions
3. Exit with error code
```

#### 3.4 Voice Tool Detection
Optional voice tool check:
```
Logic:
1. Check for audio capture (parecord/arecord)
2. Check for transcription (system/whisper)
3. Set HAS_VOICE flag
4. Don't fail if missing (optional feature)
```

### Step 4: Configuration Loading

#### 4.1 Config File Location
- Check `~/.config/heyclaude/config`
- Create directory if config exists but dir doesn't
- Don't create config if it doesn't exist

#### 4.2 Config Parsing
Simple line-by-line parsing:
```
Logic:
1. Read file line by line
2. Skip comments and empty lines
3. Split on '=' character
4. Override defaults with config values
5. No validation - trust user
```

### Step 5: Input Handling

#### 5.1 Clipboard Reading
Function to read clipboard content:
```
Logic:
1. Use detected CLIPBOARD_TOOL
2. Capture output and exit code
3. Check if empty
4. Check size against limit
5. Return content or error
```

#### 5.2 Operator Extraction
Function to find and extract operators:
```
Logic:
1. Look for operator patterns at start of input
2. Valid operators end with colon
3. Support chained operators (brief: list:)
4. Extract operators into array
5. Remove operators from content
6. Return operators and clean content
```

Operator patterns to detect:
- Length: brief, short, medium, detailed, essay, max N words/lines
- Format: list, steps, tldr, outline, table, json, yaml, markdown
- Code: code only, commented, diff, terminal
- Compound: multiple operators separated by spaces

#### 5.3 Voice Capture
Function to record audio:
```
Logic:
1. Show listening indicator
2. Start audio capture subprocess
3. Handle duration/silence limits
4. Stop on key release or timeout
5. Pass audio to transcription
```

#### 5.4 Voice Transcription
Function to convert speech to text:
```
Logic:
1. Try system speech-to-text first
2. Fall back to whisper.cpp
3. Show transcription result
4. Allow cancel window
5. Return transcribed text
```

#### 5.5 Input Merging
Function to combine voice and clipboard:
```
Logic:
1. Extract operators from voice text
2. Extract operators from clipboard
3. Merge operator lists (voice takes precedence)
4. Parse voice text for keywords
5. Apply keyword logic:
   - "just voice" → ignore clipboard
   - "instead X" → replace clipboard with X
   - "explain/fix/etc" → set mode + combine
6. Format final prompt with operators
```

#### 5.6 Prompt Building
Function to build enhanced Claude prompt:
```
Logic:
1. Take operators array and content
2. Build instruction prefix based on operators:
   - Length operators → "Provide a brief response"
   - Format operators → "Format as a bullet list"
   - Multiple operators → Combine intelligently
3. Add user content after instructions
4. Ensure natural language flow
5. Return complete prompt for Claude
```

Example transformations:
- "brief:" → "Please be concise, limiting your response to 1-2 sentences."
- "list:" → "Format your response as a bullet point list."
- "brief: list:" → "Provide a concise bullet point list (1-2 points)."
- "max 50 words:" → "Limit your response to 50 words."
- "code only:" → "Respond with only code, no explanations."

### Step 6: Display Functions

#### 6.1 Status Display
Show current status to user:
```
Logic:
1. Clear current line
2. Show appropriate indicator
3. Use colors for different states
4. Keep messages short
5. Update in-place when possible
```

#### 6.2 Response Streaming
Stream Claude's response:
```
Logic:
1. Read from Claude process pipe
2. Display character by character
3. Handle ANSI codes properly
4. Maintain proper line wrapping
5. Detect when response complete
```

#### 6.3 Prompt Display
Show continuation prompt:
```
Logic:
1. Clear line and show prompt
2. Set terminal to raw mode
3. Read single character
4. Restore terminal mode
5. Return user choice
```

### Step 7: Main Flow Implementation

#### 7.1 Flow Controller
Main function that orchestrates the flow:
```
Logic:
1. Perform all detections
2. Load configuration
3. Read clipboard
4. Handle voice if triggered
5. Prepare Claude command
6. Execute and stream
7. Handle continuation loop
```

#### 7.2 Claude Execution
Function to run Claude:
```
Logic:
1. Build command array with enhanced prompt
2. Escape content properly
3. Execute: claude -p "[enhanced_prompt_with_operators]"
4. Stream stdout to display
5. Capture exit code
6. Handle any Claude CLI errors
```

Important Claude CLI notes:
- The CLI handles all authentication
- Network errors come from Claude CLI
- Response streaming is native to CLI
- Conversation context managed by CLI

#### 7.3 Continuation Loop
Handle the continue/exit flow:
```
Logic:
1. Show prompt after response
2. Read user input
3. If continue: run "claude -c"
4. If exit: clean up and exit
5. Loop until exit
```

Note: Operators only apply to initial prompt, not continuations

### Step 8: Invocation Handling

#### 8.1 Command Line Mode
When run from terminal:
```
Logic:
1. Check if already in terminal
2. If yes, run directly
3. If no, launch in new terminal
```

#### 8.2 Hotkey Mode
When triggered by hotkey:
```
Logic:
1. Always launch in new terminal
2. Use detected terminal command
3. Position window appropriately
4. Focus new window
```

#### 8.3 Voice Mode Detection
Determine if voice was triggered:
```
Logic:
1. Check command line arguments
2. Check environment variables
3. Check parent process name
4. Set voice flag accordingly
```

### Step 9: Error Handling Patterns

#### 9.1 Tool Missing Errors
When required tools aren't found:
- Show what's missing
- Explain why it's needed
- Provide installation command
- Use consistent format

#### 9.2 Runtime Errors
When things fail during execution:
- Catch command failures
- Show actual error from tool
- Suggest solutions
- Exit gracefully

#### 9.3 User Interruption
When user hits Ctrl+C:
- Catch SIGINT signal
- Run cleanup function
- Show brief message
- Exit cleanly

### Step 10: Signal and Cleanup Handling

#### 10.1 Signal Traps
Set up signal handlers:
```
Logic:
1. Trap EXIT for cleanup
2. Trap INT for user interruption
3. Trap TERM for system termination
4. Ensure cleanup runs once
```

#### 10.2 Process Group Management
Ensure child processes are cleaned:
```
Logic:
1. Run in new process group
2. Kill entire group on exit
3. Wait for children to exit
4. Force kill if needed
```

### Step 11: Performance Optimizations

#### 11.1 Startup Speed
Keep startup fast:
- No loops in detection
- Check most likely tools first
- Cache nothing between runs
- Minimal subprocess spawning

#### 11.2 Response Streaming
Keep response smooth:
- Read in small chunks
- Flush output immediately
- No buffering
- Handle backpressure

### Step 12: Testing Approach

#### 12.1 Manual Test Cases
Test these scenarios:
1. Empty clipboard
2. Large clipboard (>10KB)
3. Special characters in clipboard
4. Code with backticks
5. Unicode/emoji content
6. Rapid Ctrl+C during response
7. Network disconnection
8. Missing Claude CLI
9. Voice without clipboard
10. All keyword combinations

Operator-specific tests:
11. Single operator: "brief: explain this"
12. Chained operators: "brief: list: summarize"
13. Numeric operator: "max 50 words: explain"
14. Code operator: "code only: fix this"
15. Invalid operator: "notreal: content"
16. Operator with colon in content
17. Case variations: "BRIEF:" vs "brief:"
18. Operators in voice input
19. Conflicting operators: "brief: detailed:"
20. Operators with special characters

#### 12.2 Terminal Compatibility
Test on different terminals:
- gnome-terminal
- xterm
- alacritty
- kitty
- Inside tmux/screen

#### 12.3 Platform Testing
Test on different systems:
- Ubuntu/Debian
- Fedora
- Arch
- macOS
- WSL (if applicable)

## Implementation Best Practices

### Code Style
1. **Use long options** for clarity (`--clipboard` not `-c`)
2. **Quote all variables** to handle spaces
3. **Use `[[ ]]` for tests** (more robust than `[`)
4. **Comment why, not what** 
5. **Keep functions under 20 lines**

### Error Handling
1. **Check every external command**
2. **Provide actionable error messages**
3. **Fail fast with clear explanation**
4. **Never silently swallow errors**
5. **Always clean up on exit**

### User Experience
1. **Show progress immediately**
2. **Keep messages short**
3. **Use visual indicators**
4. **Respond to input instantly**
5. **Make errors helpful**

### Security
1. **Escape all user input**
2. **Use arrays for commands** (avoid string splitting)
3. **Don't log sensitive content**
4. **Clear variables containing secrets**
5. **Run with minimal privileges**

## Common Pitfalls to Avoid

### 1. Over-Engineering
- Don't add configuration for everything
- Don't create abstractions for single uses
- Don't optimize prematurely
- Don't add features "just in case"

### 2. Shell Scripting Gotchas
- Forgetting to quote variables
- Using string concatenation for commands
- Not handling spaces in paths
- Assuming tool output format
- Race conditions with subprocesses

### 3. Terminal Issues
- Not resetting colors on exit
- Breaking when piped
- Assuming terminal size
- Not handling missing tty
- Cursor positioning errors

### 4. User Experience Mistakes
- Too many prompts
- Unclear error messages
- Slow startup
- No feedback during operations
- Required configuration

### 5. Claude CLI Integration Mistakes
- Trying to parse Claude's responses (don't - just stream)
- Implementing API calls directly (use Claude CLI)
- Handling authentication (Claude CLI does this)
- Managing conversation state (Claude CLI does this)
- Assuming specific output format from Claude

### 6. Operator Processing Mistakes
- Over-complicating operator syntax
- Not removing operators from user content
- Breaking on edge cases (colons in content)
- Making operators required vs optional
- Creating too many operator combinations
- Not testing operator precedence

## Implementation Checklist

Before considering implementation complete:

- [ ] Single file under 500 lines
- [ ] Starts in under 100ms
- [ ] Works with zero configuration
- [ ] Clear error messages with solutions
- [ ] Handles Ctrl+C gracefully
- [ ] No leftover processes
- [ ] No temporary files
- [ ] Works on all target platforms
- [ ] Voice features degrade gracefully
- [ ] Code is readable without comments

## Operator Quick Reference

### Length Control Operators
| Operator | Prompt Addition | Example |
|----------|----------------|---------|
| brief: | "Provide a brief response (1-2 sentences)" | brief: explain git rebase |
| short: | "Keep your response to one paragraph" | short: summarize article |
| medium: | "Provide a 2-3 paragraph response" | medium: explain concept |
| detailed: | "Provide a comprehensive response" | detailed: analyze code |
| essay: | "Provide a long-form response" | essay: discuss philosophy |
| max N words: | "Limit your response to N words" | max 50 words: explain |
| max N lines: | "Limit your response to N lines" | max 5 lines: summarize |

### Format Control Operators
| Operator | Prompt Addition | Example |
|----------|----------------|---------|
| list: | "Format as a bullet point list" | list: benefits of |
| steps: | "Format as numbered steps" | steps: how to install |
| tldr: | "Start with a TL;DR summary" | tldr: explain paper |
| outline: | "Format as hierarchical outline" | outline: project structure |
| table: | "Format as a table" | table: compare options |
| json: | "Format as JSON" | json: extract data |
| yaml: | "Format as YAML" | yaml: config example |
| markdown: | "Use rich markdown formatting" | markdown: document this |

### Code-Specific Operators
| Operator | Prompt Addition | Example |
|----------|----------------|---------|
| code only: | "Respond with only code, no explanations" | code only: fix bug |
| commented: | "Include helpful inline comments" | commented: implement function |
| diff: | "Show as a diff/patch" | diff: improve code |
| terminal: | "Format for copy-paste to terminal" | terminal: install commands |

### Combination Examples
- `brief: list:` → Concise bullet points
- `max 100 words: tldr:` → Short summary with word limit
- `code only: fix:` → Just the corrected code
- `brief: json:` → Minimal JSON response

## Final Implementation Notes

### The Prime Directive
Every line of code should serve the user, not the developer. If you're adding complexity to make the code "better" architecturally, stop and reconsider.

### Debugging Tips
1. Add `set -x` temporarily to see execution
2. Use `logger` to debug when not in terminal
3. Test with `bash -n` for syntax errors
4. Run with `time` to check performance
5. Use `strace` to see system calls

### Example Implementation Flow

Here's how a real request flows through the system:

```
User Action: Copies error message, types "brief: fix:" at start
↓
Clipboard Content: "brief: fix: TypeError: cannot read property 'x' of undefined"
↓
Operator Extraction: 
  - Operators: ["brief", "fix"]
  - Clean content: "TypeError: cannot read property 'x' of undefined"
↓
Prompt Building:
  - "Please provide a brief response (1-2 sentences) focused on fixing the issue."
  - "User request: TypeError: cannot read property 'x' of undefined"
↓
Claude CLI Command:
  claude -p "Please provide a brief response (1-2 sentences) focused on fixing the issue.
  User request: TypeError: cannot read property 'x' of undefined"
↓
Claude Response: "Check if the object exists before accessing property 'x' using 
optional chaining (?.) or a guard clause."
```

This shows how operators enhance the request without complicating the interface.

### Future-Proofing
- Keep Claude command interface minimal
- Don't depend on specific output formats
- Version check Claude CLI if needed
- Make new features opt-in
- Maintain backward compatibility

---

*Implementation Mantra: If it takes more than 10 seconds to understand a function, it's too complex. Rewrite it.*