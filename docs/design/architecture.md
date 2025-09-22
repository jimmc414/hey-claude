# Hey Claude - Architecture Document

## Overview

Hey Claude is designed as a single, self-contained shell script that orchestrates system tools to create a seamless AI interface. The architecture prioritizes zero dependencies, instant startup, and graceful degradation.

**Core Architectural Principle**: Do one thing well - bridge the clipboard to Claude with minimal friction.

## System Architecture

### Component Overview

```
┌─────────────────────────────────────────────────────────┐
│                    User Interaction Layer                │
│  ┌──────────┐  ┌──────────┐  ┌────────────┐           │
│  │ Keyboard │  │  Voice   │  │  Terminal  │           │
│  │  Hotkey  │  │  Input   │  │  Command   │           │
│  └────┬─────┘  └────┬─────┘  └─────┬──────┘           │
│       └─────────────┴───────────────┘                  │
│                         │                               │
├─────────────────────────┼───────────────────────────────┤
│                    Main Controller                       │
│  ┌─────────────────────────────────────────────────┐   │
│  │              heyclaude (bash script)             │   │
│  │  ┌───────────┐ ┌──────────┐ ┌────────────────┐ │   │
│  │  │  Input    │ │ Process  │ │    Display     │ │   │
│  │  │ Manager   │ │  Engine  │ │   Controller   │ │   │
│  │  └───────────┘ └──────────┘ └────────────────┘ │   │
│  └─────────────────────────────────────────────────┘   │
│                         │                               │
├─────────────────────────┼───────────────────────────────┤
│                  System Integration                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐            │
│  │Clipboard │  │  Audio   │  │ Terminal │            │
│  │  Tools   │  │ Capture  │  │ Emulator │            │
│  └──────────┘  └──────────┘  └──────────┘            │
│                         │                               │
├─────────────────────────┼───────────────────────────────┤
│                   External Services                      │
│  ┌─────────────────────────────────────────────────┐   │
│  │              Claude CLI (npm package)            │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### Core Modules

#### 1. Input Manager
**Purpose**: Gather and prepare user input from multiple sources

**Responsibilities**:
- Detect and read clipboard content using available system tools
- Capture voice input when triggered
- Extract structured output operators
- Merge voice and clipboard data based on keywords
- Validate and sanitize input
- Handle empty or oversized inputs gracefully

**Key Design Decisions**:
- Try multiple clipboard tools in order of preference
- Voice is always optional and enhances clipboard
- Operators are parsed before Claude sees them
- All input sanitization happens here, once

#### 2. Process Engine
**Purpose**: Transform user input into Claude commands and handle responses

**Responsibilities**:
- Build appropriate Claude CLI commands (`claude -p` and `claude -c`)
- Detect and apply voice keyword modes
- Apply structured output operators to prompt
- Execute Claude with proper escaping
- Stream response data in real-time
- Manage conversation continuity

**Key Design Decisions**:
- Single point of Claude CLI interaction
- Operators become prompt engineering
- Streaming is default for perceived speed
- State is managed minimally (only for continuation)

#### 3. Display Controller
**Purpose**: Manage terminal UI and user feedback

**Responsibilities**:
- Show status indicators (thinking, listening)
- Stream Claude's response with formatting
- Present continuation prompt
- Handle terminal sizing and colors
- Animate status indicators

**Key Design Decisions**:
- Pure terminal UI, no GUI dependencies
- Single-key interaction for all prompts
- Colors are subtle and configurable

### Data Flow

#### Standard Flow (Clipboard Only)
```
1. User copies text
2. User triggers Hey Claude (hotkey/command)
3. Input Manager reads clipboard
4. Input Manager extracts any operators (brief:, list:, etc.)
5. Process Engine builds enhanced prompt with operator instructions
6. Process Engine executes: claude -p "[enhanced_prompt]"
7. Display Controller shows thinking indicator
8. Claude response streams to terminal
9. Display Controller shows continuation prompt
10. User presses SPACE/ESC
11. If SPACE: Process Engine runs: claude -c
12. Loop back to step 8 or exit
```

#### Voice-Enhanced Flow
```
1. User copies text (optional for "just voice" mode)
2. User triggers voice hotkey
3. Display Controller shows listening indicator
4. Input Manager captures audio
5. Voice processor transcribes
6. Display Controller shows transcription
7. Input Manager extracts operators from voice or clipboard
8. Input Manager merges inputs and operators
9. Flow continues from standard step 5
```

### Claude CLI Integration

#### Dependency Architecture
Hey Claude is built as a wrapper around the official Claude CLI:
- **Required**: `@anthropic-ai/claude` npm package
- **Commands Used**:
  - `claude -p "<prompt>"` - Send initial prompt
  - `claude -c` - Continue conversation
- **Not Required**: API keys (handled by Claude CLI)
- **Not Required**: Network code (handled by Claude CLI)

This architecture means:
- Hey Claude focuses solely on UX
- Claude CLI handles all API complexity
- Updates to Claude API don't affect Hey Claude
- Authentication is managed by Claude CLI

### State Management

Hey Claude maintains minimal state to preserve simplicity:

#### Runtime State
- **Current Mode**: Standard or continuation
- **Voice Buffer**: Temporary audio data (cleared after processing)
- **Display State**: What's currently shown (status/response/prompt)
- **Active Operators**: Extracted operators for current request

#### No Persistent State
- No conversation history
- No clipboard history
- No user preferences in memory
- Configuration loaded fresh each run

This stateless design ensures:
- Fast startup (no state to load)
- No cleanup needed
- No privacy concerns
- Predictable behavior

### Operator Processing Architecture

#### Operator Detection Pipeline
```
Input Text → Operator Scanner → Operator Parser → Prompt Builder → Claude
```

#### Operator Categories
1. **Length Operators**: Control response size
   - Pattern: `brief:|short:|medium:|detailed:|essay:|max \d+ (words|lines|paragraphs):`
   - Applied as: Prepended instructions to prompt

2. **Format Operators**: Control response structure
   - Pattern: `list:|steps:|tldr:|table:|json:|markdown:`
   - Applied as: Formatting instructions

3. **Mode Operators**: Control response style
   - Pattern: `explain|fix|improve|translate`
   - Applied as: Context setting

#### Operator Processing Rules
1. **Extraction**: Remove operators from user content
2. **Validation**: Check for valid operator syntax
3. **Combination**: Merge multiple operators intelligently
4. **Translation**: Convert to Claude instructions
5. **Injection**: Add to prompt without user seeing

#### Example Prompt Enhancement
```
User Input: "brief: list: explain this code"
↓
Extracted Operators: ["brief", "list"]
Extracted Content: "explain this code"
↓
Enhanced Prompt to Claude:
"Please provide a brief response in bullet point list format.
User request: explain this code
[clipboard content]"
```

This architecture keeps operators invisible to users while giving them precise control.

### Process Architecture

#### Process Hierarchy
```
heyclaude (main process)
├── clipboard reader (subprocess, exits immediately)
├── voice capture (subprocess, when activated)
├── voice transcription (subprocess, pipes to main)
└── claude CLI (subprocess, long-running)
```

#### Process Communication
- **Clipboard**: Simple command substitution
- **Voice**: Pipe audio data through transcription
- **Claude**: Bidirectional pipe for streaming
- **Terminal**: Direct write to TTY

#### Resource Management
- Subprocesses are short-lived except Claude
- No daemon processes
- No background services
- Clean process group termination on exit

### Integration Points

#### 1. Clipboard Integration
**Strategy**: Multi-tool support with fallback

**Order of Preference**:
1. xclip (most common on Linux)
2. xsel (alternative)
3. wl-paste (Wayland)
4. pbpaste (macOS)

**Error Handling**: If no tool found, suggest installation

#### 2. Terminal Integration
**Strategy**: Terminal-agnostic launch

**Discovery Order**:
1. Check TERMINAL environment variable
2. Try common terminals in order
3. Fall back to xterm

**Window Management**:
- Use terminal's command-line flags for size/position
- Set window class for window manager rules
- Focus stealing is intentional (user triggered)

#### 3. Voice Integration
**Strategy**: System-first, fallback to local

**Audio Capture**:
- PulseAudio (parecord) preferred
- ALSA (arecord) fallback
- macOS (sox) for cross-platform

**Transcription**:
- System speech-to-text API first
- whisper.cpp as local fallback
- Graceful degradation if unavailable

#### 4. Hotkey Integration
**Strategy**: Leverage existing system tools

**Implementation**:
- Desktop environments: Native hotkey settings
- X11: xbindkeys configuration
- Wayland: Desktop-specific methods
- Script just needs to be callable

### Error Handling Architecture

#### Fail-Fast Principle
Detect problems early and inform user clearly:

1. **Startup Checks** (in order):
   - Claude CLI exists?
   - Clipboard tool available?
   - Terminal available?
   - Voice tools (if voice triggered)?

2. **Runtime Failures**:
   - Network errors → Clear message
   - Claude errors → Show actual error
   - Voice failures → Fall back to clipboard
   - Terminal issues → Try to recover

#### Error Display Strategy
- Use Unicode symbols for clarity (⚠️)
- Show solution, not just problem
- Keep messages short
- Exit gracefully

### Performance Architecture

#### Startup Optimization
- No configuration parsing (use defaults)
- No file I/O except config (if exists)
- Minimal subprocess spawning
- Direct execution, no wrapper scripts

#### Runtime Performance
- Stream everything (no buffering)
- Single-pass input processing
- No regex for simple operations
- Efficient escape handling

#### Resource Usage
- Memory: Script + Claude CLI only
- CPU: Minimal (mostly waiting)
- Disk: No temporary files
- Network: Only Claude API calls

### Security Architecture

#### Input Sanitization
- **Clipboard**: Escape shell metacharacters
- **Voice**: Transcription is plain text
- **Combined**: Single sanitization point

#### Privacy Protection
- No logging of clipboard content
- No storage of conversations
- Voice audio deleted immediately
- No telemetry or analytics

#### Process Isolation
- Run with user privileges only
- No setuid/setgid requirements
- No network listeners
- Claude CLI handles API keys

### Configuration Architecture

#### Design Philosophy
- Convention over configuration
- Zero-config must work perfectly
- Power users can customize

#### Configuration Loading
1. Check for config file
2. Load if exists
3. Use defaults for missing values
4. No validation (trust user)

#### Configuration Scope
- Visual preferences (colors, size)
- Tool preferences (terminal, clipboard)
- Behavior toggles (voice, streaming)
- No feature flags or complex logic

### Extension Architecture

#### Current Design: Monolithic
Single script contains all functionality:
- Easier to install
- Easier to understand
- No module loading complexity
- No version conflicts

#### Future Plugin Points
If needed, plugins could hook into:
- Input transformation
- Output formatting
- Additional commands
- Voice processors

But: Resist adding plugin architecture until proven necessary.

### Platform Architecture

#### Linux/X11
- Primary platform
- All features supported
- Best clipboard integration
- Native hotkey support

#### Linux/Wayland
- Full support with wl-clipboard
- Hotkey support varies by compositor
- Voice works identically

#### macOS
- Clipboard via pbpaste
- Voice via system dictation
- Terminal via Terminal.app/iTerm2
- Hotkeys via system preferences

#### Windows (Future)
- WSL2 environment
- Windows clipboard via PowerShell
- Voice would need Windows APIs

### Testing Architecture

#### Test Scenarios
Without formal tests, the architecture ensures reliability through:

1. **Defensive Programming**
   - Check every external command
   - Handle missing tools gracefully
   - Validate input bounds

2. **User as Tester**
   - Immediate feedback
   - Clear error messages
   - Easy to verify behavior

3. **Simple Enough to Verify**
   - Linear flow
   - No hidden state
   - Predictable behavior

### Operational Architecture

#### Logging Strategy
- No logging by default
- Debug mode shows commands
- Errors go to stderr
- User can redirect if needed

#### Monitoring
- No built-in monitoring
- Exit codes indicate failure type
- System tools can monitor if needed

#### Updates
- Single file to replace
- No migration needed
- No state to preserve
- Backward compatible config

## Design Rationale

### Why Bash?
- Universal availability
- No runtime dependencies
- Fast startup
- Good enough for orchestration
- Users can read and modify

### Why No Database?
- No state to store
- No history needed
- Simplicity over features
- Privacy by design

### Why Streaming?
- Immediate feedback
- Feels responsive
- No memory buildup
- Natural for conversation

### Why Single File?
- Easy installation
- No module confusion
- Self-contained
- Portable

### Why Voice Keywords?
- Natural language
- No command memorization
- Discoverable
- Optional complexity

## Architectural Invariants

These principles must remain true:

1. **Zero-Configuration Operation**: Must work without any setup
2. **Single File**: No multi-file installation
3. **No Background Processes**: Clean process model
4. **No State Storage**: Privacy and simplicity
5. **Graceful Degradation**: Features fail safely
6. **Instant Response**: <100ms to visible action
7. **Universal Compatibility**: Runs anywhere bash runs

## Future Architecture Considerations

### Scaling Concerns
Current architecture handles:
- Any clipboard size (with limits)
- Any response length
- Rapid repeated invocations
- Multiple instances

### Potential Optimizations
If performance becomes an issue:
- Cache clipboard tool detection
- Pre-compile whisper model
- Terminal reuse option
- Response caching

But: Don't optimize prematurely. Simplicity > Speed.

### Architectural Boundaries
These changes would require architecture revision:
- Multi-user support
- Conversation persistence
- GUI interface
- Plugin system
- Client-server model

Current architecture explicitly excludes these for simplicity.

---

*Architecture Mantra: Every architectural decision should make Hey Claude simpler to use, not simpler to code.*

## Operator Architecture Benefits

The structured output operators demonstrate architectural elegance:

1. **Zero Learning Curve**: Operators use natural language (brief:, list:) not codes
2. **Progressive Disclosure**: Work without knowing they exist, discover when needed  
3. **Composable Power**: Combine operators for precise control
4. **Invisible Complexity**: Processing hidden from user, just sees better results
5. **Graceful Fallback**: Invalid operators ignored, request still works

This architecture adds power without adding complexity - the hallmark of elegant design.