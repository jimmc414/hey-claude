# Hey Claude - UX Design Document

This document outlines the user experience design principles, interaction patterns, and interface decisions that make Hey Claude a frictionless tool.

## Core UX Principles

### 1. Invisible Until Needed
- No background processes
- No system tray icon
- No persistent UI elements
- Appears only when invoked

### 2. Zero Learning Curve
- Works immediately with basic copy → run → read flow
- Advanced features discoverable but not required
- No documentation needed for basic use
- Natural language operators (not codes or flags)

### 3. Minimal Interaction Points
- Single command to start: `hc`
- Single key to continue: `SPACE`
- Single key to exit: `ESC`
- No menus, no options, no configuration required

### 4. Instant Feedback
- Visual response within 100ms
- Clear status indicators
- Streaming output (no waiting for complete response)
- Immediate error messages with solutions

## User Journey Maps

### First-Time User Journey
```
Discovery → Installation → First Use → Delight
    │            │             │          │
    ├─ "I need   ├─ Run       ├─ Copy   ├─ "It just
    │   quick    │  install.sh │  text   │   worked!"
    │   Claude   │             │         │
    │   access"  ├─ See clear ├─ Run hc ├─ No config
    │            │  dependency │         │   needed
    │            │  checks    ├─ See    │
    │            │            │  response├─ Natural
    │            └─ Done in   │         │   interaction
    │               1 minute  └─ Press  │
    │                           SPACE   └─ Want to
    │                                      use again
```

### Power User Journey
```
Basic Use → Discover Operators → Master Shortcuts → Workflow Integration
    │              │                    │                    │
    ├─ Use hc     ├─ Notice "brief:"  ├─ Set up hotkey   ├─ Part of
    │  daily      │  in docs          │  Super+Shift+C   │  muscle
    │             │                    │                   │  memory
    ├─ Want       ├─ Try it           ├─ Use operators   │
    │  shorter    │                    │  regularly       ├─ Copy →
    │  responses  ├─ "Wow, that       │                   │  Hotkey →
    │             │  worked!"          ├─ Discover more   │  Done
    │             │                    │  operators       │
    │             └─ Start using      │                   └─ Seconds
    │                operators         └─ Create custom      not minutes
    │                                    workflows
```

## Interaction Design

### Visual Hierarchy
```
┌─────────────────────────────────────────┐
│                                         │ ← Terminal window appears
│  ◐ Claude is thinking...                │ ← Dim gray status (secondary)
│                                         │
│  [Claude's response begins here in      │ ← Bright white (primary focus)
│   bright white, drawing immediate       │
│   attention to the content that         │
│   matters]                              │
│                                         │
│  [SPACE to continue / ESC to exit]     │ ← Blue prompt (action item)
│                                         │
└─────────────────────────────────────────┘
```

### Color Psychology
- **Dim Gray** (#666666) - System messages, non-intrusive
- **Bright White** (#FFFFFF) - Claude's response, maximum readability
- **Light Blue** (#5DADE2) - Interactive prompts, trustworthy
- **Light Red** (#E74C3C) - Errors, attention without alarm
- **Light Purple** (#9B59B6) - Voice indicators, special feature

### Animation Design
```
Thinking Animation (100ms cycle):
◐ → ◓ → ◑ → ◒ → ◐

Purpose:
- Shows activity without distraction
- Disappears immediately when response starts
- Cultural universal (spinning = processing)
```

## Error Message Design

### Principles
1. **State the problem clearly**
2. **Provide the solution immediately**
3. **Use visual indicators (⚠️ 📋)**
4. **Keep it scannable**

### Examples
```
Bad:  ERROR: Failed to read clipboard
Good: ⚠️  No clipboard tool found
           Install one of: xclip, xsel, wl-clipboard
           Ubuntu/Debian: sudo apt install xclip

Bad:  ERROR: Command not found: claude
Good: ⚠️  Claude CLI not installed
           Run: npm install -g @anthropic-ai/claude
           Or visit: anthropic.com/claude-cli
```

## Operator Design Philosophy

### Natural Language Approach
Instead of flags like `-b` or `--brief`, operators use natural words:
- `brief:` not `-b`
- `list:` not `--format=list`
- `max 50 words:` not `--limit-words=50`

### Progressive Disclosure
```
Level 1: Basic use (no operators)
         └─ Just works

Level 2: Simple operators (brief:, list:)
         └─ Discovered through examples

Level 3: Combined operators (brief: list:)
         └─ Natural progression

Level 4: Advanced operators (max 50 words: json:)
         └─ Power user features
```

### Operator Feedback
When operators are used, their effect is immediate and obvious:
- `brief:` → Visibly shorter response
- `list:` → Clear bullet points
- `code only:` → Just code appears

## Terminal Window Behavior

### Window Appearance
- **Size**: 80x24 (standard, readable)
- **Position**: Center screen (predictable)
- **Title**: "Hey Claude" (identifiable)
- **Focus**: Automatic (ready for interaction)

### Why New Terminal Window?
1. **Clean slate** - No previous command clutter
2. **Dedicated space** - Clear mental model
3. **Focus management** - Returns to previous window on exit
4. **Hotkey friendly** - Works from any application

## Response Streaming UX

### Why Stream?
- **Perceived speed** - See results immediately
- **Engagement** - Watch Claude "think"
- **Interruptibility** - Can Ctrl+C if wrong direction
- **Natural reading** - Matches human reading speed

### Streaming Behavior
```
Traditional:  [Wait...........] → [Complete response]
                ↑                          ↑
            Anxiety builds           Relief but slow

Hey Claude:   [First words appear] → [Streaming...] → [Done]
                ↑                         ↑              ↑
            Instant feedback      Engaged reading    Natural end
```

## Continuation Interface

### Design Decisions
1. **Single key interaction** - No Enter required
2. **Clear options** - SPACE/ESC are universal
3. **Visible prompt** - Blue color draws eye
4. **Forgiving** - Invalid keys just re-show prompt

### Why SPACE and ESC?
- **SPACE** - Largest key, easiest to hit, means "go"
- **ESC** - Universal "get me out", muscle memory
- Both work in all keyboard layouts
- No modifiers needed

## Mobile Terminal Considerations

While primarily desktop-focused, the design accommodates terminal apps:
- Short lines (80 columns)
- Clear visual breaks
- No mouse required
- Works with touch keyboards

## Accessibility Considerations

### Visual
- High contrast colors
- No color-only information
- Clear text hierarchy
- Readable in all terminal themes

### Motor
- Large target keys (SPACE)
- No key combinations required
- No time pressure
- Forgiving input handling

### Cognitive
- Clear mental model (clipboard → Claude)
- Consistent behavior
- No modes to remember
- Error messages explain solutions

## Notification Design

### Current: Terminal-Based
```
◐ Claude is thinking...    ← Subtle, in-context
[Response streams here]     ← Focus on content
[SPACE to continue / ESC]   ← Clear next action
```

### Future: System Notifications
Could add optional desktop notifications:
- Complete in background
- Click to open response
- Maintains non-intrusive principle

## Voice UX (Future Enhancement)

### Activation
- Hold-to-talk: Natural, prevents accidents
- Visual feedback: 🎤 Listening...
- Transcription preview: See what was heard
- Cancel window: 1 second to correct

### Mental Model
```
Current:  Copy → Run → Read
Voice:    Copy → Speak → Read
          └─ Same flow, enhanced input
```

## Performance Perception

### Speed Techniques
1. **Immediate visual feedback** (<100ms)
2. **Streaming responses** (no waiting)
3. **Minimal startup time** (no loading screens)
4. **Clean exit** (no cleanup delays)

### Psychological Speed
- Spinner shows "working" not "stuck"
- First words appear quickly
- Natural reading pace
- No progress bars (imply waiting)

## Failure Recovery

### Network Failure
```
⚠️  Can't reach Claude. Check your connection.
    └─ Clear, actionable, no technical jargon
```

### Clipboard Empty
```
📋 Nothing in clipboard. Copy some text first!
    └─ Friendly, includes emoji, tells what to do
```

### User Mistakes
- Copy without selecting: Clear message
- Wrong operator syntax: Still works (ignored)
- Multiple spaces: Handled gracefully
- Special characters: Properly escaped

## Habit Formation

### Daily Use Pattern
```
Morning: Check email → Copy → hc → Answer
Coding:  See error → Copy → hc → Fix
Reading: Complex text → Copy → hc → Understand
Writing: Need ideas → Copy → hc → Inspire
```

### Muscle Memory Development
1. `hc` - Two letters, left hand
2. `SPACE` - Thumb, natural position
3. `ESC` - Pinky, standard position
4. Copy/Paste - Existing muscle memory

## Competitive UX Advantages

### vs. Web Interface
- No browser needed
- No login/navigation
- No UI loading
- Keyboard-only workflow

### vs. Desktop Apps
- No installation size
- No update prompts
- No system resources
- No window management

### vs. Other CLI Tools
- No command memorization
- No flag combinations
- No configuration files
- No learning curve

## Future UX Enhancements

### Considered but Deferred
1. **Response to clipboard** - Put answer back
2. **History** - Recent conversations
3. **Themes** - Custom colors
4. **Aliases** - Custom operators

### Why Deferred?
Each adds complexity that could break the core simplicity. The current design is complete and sufficient for 90% of use cases.

## Design Validation

### Success Metrics
- Time to first use: <30 seconds
- Time to value: <1 minute
- Commands to remember: 1 (`hc`)
- Keys to remember: 2 (SPACE, ESC)
- Configuration required: 0

### User Feedback Patterns
Expected positive signals:
- "It just works"
- "So simple"
- "Why didn't this exist before?"
- "I use it dozens of times daily"

Expected concerns:
- "Can I change the colors?" → Config file
- "Can I save responses?" → Copy from terminal
- "Can I use different models?" → Through Claude CLI

## Design Philosophy Summary

Hey Claude's UX embodies the principle that the best interface is often the least interface. By removing everything unnecessary and focusing on the essential interaction - getting from question to answer - it achieves a rare combination of power and simplicity.

The design succeeds not through features, but through their careful omission.