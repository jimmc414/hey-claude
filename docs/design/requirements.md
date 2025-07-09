# Hey Claude - Complete Requirements

## Overview

**Hey Claude** is an ultralight, instant-access command-line interface that creates a frictionless bridge between your clipboard and Claude. It uses the system clipboard as its primary input method and the official Claude CLI tool as its AI backend.

**Core Philosophy**: The clipboard is the interface. Copy → Invoke → Response → Continue or Exit.

**Key Dependency**: Hey Claude requires the official Claude CLI tool (`npm install -g @anthropic-ai/claude`) which handles all API communication, authentication, and conversation management. Hey Claude focuses purely on making the CLI experience frictionless.

## Functional Requirements

### 1. Program Identity
- **1.1** Program name: `heyclaude`
- **1.2** Command alias: `hc` (for speed)
- **1.3** Display name in terminal: "Hey Claude"

### 2. Invocation Methods

#### 2.1 Command Line
- **2.1.1** Primary command: `heyclaude`
- **2.1.2** Short alias: `hc`
- **2.1.3** Must work from any directory
- **2.1.4** No command-line arguments needed for basic operation

#### 2.2 System Hotkey
- **2.2.1** Default: `Super+Shift+C` (configurable)
- **2.2.2** Global binding - works from any application
- **2.2.3** Implemented via system's hotkey daemon (e.g., xbindkeys)
- **2.2.4** Must focus/raise terminal when triggered

#### 2.3 Voice Activation (Future Enhancement)
- **2.3.1** Wake phrase: "Hey Claude"
- **2.3.2** Requires system voice recognition integration
- **2.3.3** Optional notification sound on activation

### 2.4 Claude CLI Dependency

#### 2.4.1 Required Claude CLI
- **2.4.1.1** Hey Claude requires the official Claude CLI tool
- **2.4.1.2** Installation: `npm install -g @anthropic-ai/claude`
- **2.4.1.3** The CLI provides two commands we use:
  - `claude -p "<prompt>"` - Initial prompt
  - `claude -c` - Continue conversation
- **2.4.1.4** Hey Claude is a wrapper that makes the CLI frictionless
- **2.4.1.5** Version requirement: Latest stable Claude CLI

### 2.5 Voice Input Enhancement

#### 2.5.1 Voice Capture Modes
- **2.5.1.1** Hold-to-talk: Hold hotkey while speaking
- **2.5.1.2** Push-to-talk: Press hotkey, speak, press again to stop
- **2.5.1.3** Auto-detect: Stop recording after 2 seconds of silence
- **2.5.1.4** Maximum recording: 30 seconds

#### 2.5.2 Voice + Clipboard Combination
- **2.5.2.1** Default mode: Voice provides context for clipboard content
  ```
  Format: "<voice_text>. Content: <clipboard_text>"
  Example: "Explain this Python code. Content: [clipboard code]"
  ```
- **2.5.2.2** Voice-only mode: Triggered by keyword "just voice"
- **2.5.2.3** Override mode: Voice replaces clipboard if it starts with "instead"

#### 2.5.3 Voice Keywords for Actions
- **2.5.3.1** Mode keywords (must be first word):
  - "**explain**" → Detailed explanation mode
  - "**summarize**" → Concise summary mode
  - "**fix**" → Debug/correction mode (for code)
  - "**improve**" → Enhancement suggestions
  - "**translate**" → Translation mode (auto-detect target)
  - "**eli5**" → Explain like I'm five mode
  
- **2.5.3.2** Special keywords:
  - "**just voice**" → Ignore clipboard, use voice only
  - "**instead** [content]" → Replace clipboard with voice content
  - "**with** [language]" → Specify programming language or human language
  - "**as** [format]" → Request specific output format (markdown, json, etc.)

### 2.6 Structured Output Operators

#### 2.6.1 Length Control Operators
- **2.6.1.1** Prefix operators in clipboard or voice:
  - "**brief:**" → 1-2 sentence response
  - "**short:**" → 1 paragraph response  
  - "**medium:**" → 2-3 paragraph response (default)
  - "**detailed:**" → Comprehensive response
  - "**essay:**" → Long-form response

- **2.6.1.2** Numeric constraints:
  - "**max 50 words:**" → Word limit
  - "**max 5 lines:**" → Line limit
  - "**max 2 paragraphs:**" → Paragraph limit

#### 2.6.2 Format Control Operators
- **2.6.2.1** Structure operators:
  - "**list:**" → Bullet point format
  - "**steps:**" → Numbered steps
  - "**tldr:**" → Summary first, then details
  - "**outline:**" → Hierarchical outline
  - "**table:**" → Tabular format
  - "**json:**" → JSON structure
  - "**yaml:**" → YAML structure
  - "**markdown:**" → Rich markdown

- **2.6.2.2** Code-specific operators:
  - "**code only:**" → Just the code, no explanation
  - "**commented:**" → Code with inline comments
  - "**diff:**" → Show changes in diff format
  - "**terminal:**" → Commands ready to copy/paste

#### 2.6.3 Operator Combination
- **2.6.3.1** Multiple operators allowed:
  ```
  "brief: list: explain this error"
  "max 100 words: tldr: summarize article"
  "code only: fix: python import error"
  ```
- **2.6.3.2** Operators processed left-to-right
- **2.6.3.3** Conflicting operators: rightmost wins
- **2.6.3.4** Work in both clipboard and voice

#### 2.6.4 Smart Operator Detection
- **2.6.4.1** Operators must end with colon
- **2.6.4.2** Case-insensitive matching
- **2.6.4.3** Must be at start of input
- **2.6.4.4** Extracted before sending to Claude
- **2.6.4.5** Operator hints included in prompt

#### 2.5.4 Voice Transcription
- **2.5.4.1** Use system speech-to-text (if available)
- **2.5.4.2** Fallback to whisper.cpp for local transcription
- **2.5.4.3** Show transcription in real-time: "🎤 Heard: [transcribed text]"
- **2.5.4.4** Allow 1-second window to cancel if mistranscribed (ESC key)

### 3. Core Flow

#### 3.1 Startup Sequence
```
1. Check clipboard for content
2. If empty → Show: "📋 Nothing in clipboard. Copy some text first!" → Exit
3. If content exists → Check for voice input
4. If voice active → Show: "🎤 Listening..." → Capture → Transcribe
5. Combine inputs based on mode
6. Show status: "◐ Claude is thinking..."
7. Execute: claude -p "<combined_input>"
8. Stream response in real-time
9. Show continuation prompt
```

#### 3.2 Clipboard Handling
- **3.2.1** Support multiple clipboard tools (try in order):
  - `xclip -selection clipboard -o`
  - `xsel --clipboard --output`
  - `wl-paste` (for Wayland)
  - `pbpaste` (for macOS compatibility)
- **3.2.2** Properly escape special characters (quotes, newlines, etc.)
- **3.2.3** Preserve formatting for code blocks
- **3.2.4** Handle Unicode/UTF-8 properly
- **3.2.5** Max clipboard size: 10KB (configurable)

#### 3.3 Response Display
- **3.3.1** Stream Claude's response character-by-character as received
- **3.3.2** Preserve ANSI color codes and formatting
- **3.3.3** Auto-scroll to follow new content
- **3.3.4** Clear visual separation between status messages and response

#### 3.4 Continuation Interface
- **3.4.1** After response completes, show: `[SPACE to continue / ESC to exit]`
- **3.4.2** Single keypress detection (no Enter required)
- **3.4.3** Accepted inputs:
  - SPACE or 'c' → Continue conversation
  - ESC or 'q' → Exit
  - Any other key → Re-show prompt
- **3.4.4** If continuing, execute: `claude -c`
- **3.4.5** After continuation, return to prompt (infinite loop until exit)

### 4. Terminal Behavior

#### 4.1 Window Management
- **4.1.1** Default size: 80 columns × 24 rows
- **4.1.2** Default position: Center of primary monitor
- **4.1.3** Always open in new terminal window
- **4.1.4** Auto-raise and focus on launch
- **4.1.5** Return focus to previous window on exit

#### 4.2 Terminal Compatibility
- **4.2.1** Support multiple terminal emulators (auto-detect):
  - gnome-terminal
  - konsole
  - xterm
  - alacritty
  - kitty
  - terminator
- **4.2.2** Fallback to system default terminal
- **4.2.3** Use consistent window class: "HeyClaudeTerminal"

### 5. Visual Design

#### 5.1 Color Scheme
- **5.1.1** System messages: Dim gray (#666666)
- **5.1.2** Claude responses: Clear white (#FFFFFF)
- **5.1.3** Prompt text: Soft blue (#5DADE2)
- **5.1.4** Error messages: Soft red (#E74C3C)
- **5.1.5** Thinking indicator: Animated cyan (#00CED1)

#### 5.2 Typography
- **5.2.1** Clear spacing between elements
- **5.2.2** Empty line before and after prompts
- **5.2.3** Indent Claude's response by 2 spaces
- **5.2.4** Use Unicode characters for visual elements:
  - Thinking: ◐ ◓ ◑ ◒ (rotating)
  - Clipboard: 📋
  - Error: ⚠️
  - Voice active: 🎤
  - Voice processing: 🎵 ♪ ♫ (animated)

#### 5.3 Voice Mode Indicators
- **5.3.1** Recording: "🎤 Listening..." (pulsing red)
- **5.3.2** Processing: "🎵 Processing voice..." (animated notes)
- **5.3.3** Transcription: "🎤 Heard: [text]" (purple text)
- **5.3.4** Mode indicator: Show keyword effect
  ```
  🎤 Mode: EXPLAIN
  📋 Context: [first 50 chars of clipboard...]
  ```

### 6. Error Handling

#### 6.1 Missing Dependencies
- **6.1.1** Claude CLI not found:
  ```
  ⚠️  Claude CLI not installed
      Run: npm install -g @anthropic-ai/claude
      Or visit: anthropic.com/claude-cli
  ```
- **6.1.2** No clipboard tool:
  ```
  ⚠️  No clipboard tool found
      Install one of: xclip, xsel, wl-clipboard
      Ubuntu/Debian: sudo apt install xclip
  ```

#### 6.2 Runtime Errors
- **6.2.1** Empty clipboard (see 3.1)
- **6.2.2** Network failure:
  ```
  ⚠️  Can't reach Claude. Check your connection.
  ```
- **6.2.3** Claude command failure: Show actual error, then exit

#### 6.3 Graceful Interruption
- **6.3.1** Handle Ctrl+C cleanly
- **6.3.2** Show: "Interrupted. Goodbye!" before exit
- **6.3.3** Proper cleanup of terminal state

### 7. Configuration

#### 7.1 Config File
- **7.1.1** Location: `~/.config/heyclaude/config`
- **7.1.2** Format: Simple key=value pairs
- **7.1.3** Auto-create with defaults on first run

#### 7.2 Configurable Options
```bash
# Terminal settings
terminal=auto              # or specific: alacritty, kitty, gnome-terminal
terminal_size=80x24       # columns x rows
terminal_position=center  # center, top, mouse
terminal_transparency=0.95

# Hotkey
hotkey=Super+Shift+C
voice_hotkey=Super+Shift+V    # For voice input mode

# Voice settings
voice_enabled=true
voice_mode=push_to_talk      # hold_to_talk, push_to_talk, auto_detect
voice_max_duration=30        # seconds
voice_silence_threshold=2    # seconds for auto_detect
voice_transcription=system   # system, whisper, none
voice_show_transcription=true
voice_cancel_window=1        # seconds to cancel after transcription

# Behavior
max_clipboard_size=10240  # bytes
auto_exit_on_empty=true
show_clipboard_preview=false
stream_response=true

# Appearance
color_system=#666666
color_response=#FFFFFF
color_prompt=#5DADE2
color_error=#E74C3C
color_voice=#9B59B6      # Purple for voice indicators
```

### 8. Installation

#### 8.1 Script Location
- **8.1.1** Install to: `/usr/local/bin/heyclaude`
- **8.1.2** Create symlink: `/usr/local/bin/hc` → `heyclaude`
- **8.1.3** Set permissions: `chmod +x`

#### 8.2 Desktop Integration
- **8.2.1** Create desktop entry for application launchers
- **8.2.2** Register hotkey with system
- **8.2.3** Optional: Add to system startup (for hotkey daemon)

### 9. Performance Requirements

#### 9.1 Speed
- **9.1.1** Time to visible window: < 100ms
- **9.1.2** Time to start streaming: < 500ms
- **9.1.3** Minimal CPU usage when idle

#### 9.2 Resource Usage
- **9.2.1** Memory footprint: < 50MB
- **9.2.2** No background processes when not active
- **9.2.3** Clean process termination

### 10. Security Considerations

#### 10.1 Clipboard Safety
- **10.1.1** Never log clipboard contents
- **10.1.2** Clear sensitive environment variables
- **10.1.3** Don't store clipboard history

#### 10.2 Command Injection
- **10.2.1** Properly escape all shell metacharacters
- **10.2.2** Use array-based command execution where possible
- **10.2.3** Validate clipboard size before processing

## Non-Functional Requirements

### 11. User Experience Principles

#### 11.1 Instant Gratification
- Zero configuration required for basic use
- Works immediately after installation
- No learning curve - intuitive from first use

#### 11.2 Minimal Cognitive Load
- No menus, no options during use
- Single-key interactions only
- Clear, concise messaging

#### 11.3 Seamless Integration
- Feels like part of the OS
- Doesn't interrupt workflow
- Fast enough to not break concentration

#### 11.4 Voice Enhancement Philosophy
- **Optional, not required**: Voice adds power without complexity
- **Natural keywords**: Keywords match how people naturally speak
- **Smart defaults**: System guesses intent from natural speech
- **Zero training**: No need to memorize commands
- **Fallback friendly**: Everything works without voice

#### 11.5 Progressive Enhancement
- **Level 0**: Clipboard only (original simplicity)
- **Level 1**: Voice for context ("explain this")
- **Level 2**: Keywords for common actions
- **Level 3**: Complex voice commands (future)

### 12. Platform Support

#### 12.1 Operating Systems
- **Primary**: Linux (X11 and Wayland)
- **Secondary**: macOS (with pbpaste)
- **Future**: WSL2 on Windows

#### 12.2 Shell Requirements
- Bash 4.0+
- POSIX compliance where possible
- No exotic dependencies

#### 12.3 Voice Dependencies (Optional)
- **System speech-to-text**: 
  - Linux: PulseAudio + speech-dispatcher
  - macOS: Built-in dictation API
- **Alternative**: whisper.cpp for local transcription
- **Audio capture**: arecord (ALSA) or parecord (PulseAudio)
- **All voice features degrade gracefully if missing**

## Implementation Notes

### 13. Code Structure
```bash
heyclaude
├── Main script (single file)
├── No external dependencies except:
│   ├── clipboard tool (xclip/xsel/wl-paste)
│   ├── claude CLI
│   └── standard Unix tools (grep, sed, etc.)
└── Self-contained configuration handling
```

### 14. Testing Scenarios
- Empty clipboard
- Large clipboard content (>10KB)
- Special characters in clipboard
- Multiple line content
- Code snippets with formatting
- Unicode/emoji content
- Rapid repeated invocations
- Network interruption mid-stream
- Terminal resize during response

## Future Enhancements (Out of Scope for MVP)

### 15. Advanced Features
- **15.1** Voice input for follow-up questions
- **15.2** Response to clipboard (put answer back)
- **15.3** Smart clipboard monitoring (auto-detect questions)
- **15.4** Notification mode (response as system notification)
- **15.5** Inline overlay mode (floating response window)
- **15.6** Image support in clipboard
- **15.7** Multiple conversation threads
- **15.8** Search through previous conversations
- **15.9** Export conversation to markdown
- **15.10** Plugin system for custom actions

## Success Metrics

### 16. Measuring Elegance
- Time from thought to response: < 5 seconds
- Number of user actions required: 2 (copy, invoke) or 1 (voice-only)
- Configuration options actually changed by users: < 10%
- User reports of "it just works": > 90%
- Voice adoption rate: > 60% once discovered
- Keyword usage accuracy: > 80% on first try

## Example User Journey

```
1. User reads article about Python asyncio
2. Highlights confusing paragraph
3. Presses Ctrl+C to copy
4. Presses Super+Shift+C
5. Terminal appears with "◐ Claude is thinking..."
6. Response streams: "This paragraph is explaining..."
7. User reads response
8. Presses SPACE
9. Terminal shows "◐ Claude is thinking..."
10. User types follow-up via claude -c interface
11. Presses ESC when satisfied
12. Back to article, total time: 45 seconds
```

### Voice-Enhanced Journey Examples

#### Example 1: Explain Code with Voice
```
1. User copies complex regex from StackOverflow
2. Holds Super+Shift+V (voice hotkey)
3. Says: "explain this regex step by step"
4. Releases key
5. Terminal shows: "🎤 Heard: explain this regex step by step"
6. Claude explains the regex pattern in detail
7. Total time: 20 seconds
```

#### Example 2: Quick Fix with Keyword
```
1. User copies error message from terminal
2. Presses Super+Shift+V
3. Says: "fix python import error"
4. Terminal recognizes "fix" keyword → enters debug mode
5. Claude provides targeted solution
6. User presses SPACE to ask follow-up
```

#### Example 3: Translation with Context
```
1. User copies paragraph in French
2. Holds Super+Shift+V
3. Says: "translate with technical context"
4. Claude translates with attention to technical terms
5. Voice made the request more precise
```

#### Example 4: Voice-Only Query
```
1. User presses Super+Shift+V (no clipboard content needed)
2. Says: "just voice how do I exit vim"
3. "just voice" keyword → ignores clipboard check
4. Claude provides the answer
5. No copy-paste needed for simple questions
```

#### Example 5: Length-Controlled Response
```
1. User copies long technical document
2. Presses Super+Shift+C
3. Clipboard contains: "brief: summarize: [document text]"
4. Hey Claude recognizes operators
5. Claude provides 1-2 sentence summary
6. Perfect for quick understanding
```

#### Example 6: Code-Specific Output
```
1. User copies Python error traceback
2. Holds Super+Shift+V
3. Says: "code only fix"
4. Combined operators: code-only output + fix mode
5. Claude provides just the corrected code
6. Ready to paste back into editor
```

#### Example 7: Formatted Analysis
```
1. User copies competitor pricing data
2. Types in clipboard: "table: compare: [data]"
3. Invokes Hey Claude
4. Response comes as formatted table
5. Easy to read and share
```

---

*Remember: Every feature should reduce friction, not add it. When in doubt, choose simplicity.*

## Voice Feature Design Rationale

The voice enhancement maintains elegant simplicity by:

1. **Being completely optional** - Hey Claude works perfectly without it
2. **Using natural language** - Say what you're thinking, not commands
3. **Providing smart shortcuts** - Keywords like "explain" and "fix" do what you'd expect
4. **Failing gracefully** - If voice doesn't work, clipboard-only mode is always there
5. **Adding context, not complexity** - Voice clarifies intent without adding steps

The goal: Make Claude understand not just WHAT you copied, but WHY you need help with it.

## Structured Output Operators Rationale

The operators provide precise control while maintaining simplicity:

1. **Discoverable** - Natural words with colons (brief:, list:)
2. **Optional** - Everything works without them
3. **Composable** - Combine for exact output (brief: list: fix:)
4. **Predictable** - Same operator always gives same format
5. **Invisible** - Processing hidden, user just sees results

Common operator combinations:
- `brief: list:` - Quick bullet points
- `code only: fix:` - Just the corrected code
- `max 3 lines: tldr:` - Ultra-concise summary
- `table: compare:` - Structured comparison
- `brief: eli5:` - Simple explanation in 1-2 sentences

The operators turn Claude from a general assistant into a precise tool.