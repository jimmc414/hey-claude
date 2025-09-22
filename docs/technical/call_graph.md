# Hey Claude - Call Graph

This document maps the function call hierarchy in the Hey Claude script, showing how functions invoke each other during execution.

## Main Call Graph

```mermaid
graph TD
    A[Script Entry Point] --> B{In Terminal?}
    B -->|Yes| C[main]
    B -->|No| D[exec TERMINAL_CMD[@]]
    D --> A
    
    C --> E[detect_clipboard_tool]
    C --> F[check_claude_cli]
    C --> G[detect_terminal]
    C --> H[detect_voice_tools]
    C --> I[load_config]
    C --> J[read_clipboard]
    
    J --> K[error - if empty]
    
    C --> L[extract_operators]
    C --> M[build_prompt]
    C --> N[run_claude - initial]
    
    N --> O[show_spinner background]
    N --> P[claude -p command]
    
    C --> Q[Continuation Loop]
    Q --> R[get_continuation_choice]
    R --> S{User Choice}
    S -->|SPACE| T[run_claude - continue]
    S -->|ESC| U[Exit Loop]
    T --> Q
    
    U --> V[cleanup via trap]
```

## Detailed Function Call Hierarchy

### 1. Entry Point Flow
```
#!/usr/bin/env bash (line 1)
│
├─ trap cleanup EXIT (line 433)
├─ trap 'INTERRUPTED=true; exit 130' INT TERM (line 434)
│
└─ Terminal Check (line 436-441)
    ├─ IF already in terminal
    │   └─ main() (line 385)
    │
    └─ ELSE launch in terminal
        └─ exec "${TERMINAL_CMD[@]}" "$0" "$@"
            └─ [Script restarts in terminal]
```

### 2. Main Function Calls
```
main() (line 385-428)
│
├─ detect_clipboard_tool() (line 387)
│   └─ command -v [xclip|xsel|wl-paste|pbpaste]
│
├─ check_claude_cli() (line 388)
│   ├─ command -v claude
│   └─ error() - if not found
│
├─ detect_terminal() (line 389)
│   └─ command -v [gnome-terminal|konsole|xterm|...]
│
├─ detect_voice_tools() (line 390)
│   └─ command -v [parecord|arecord]
│
├─ load_config() (line 394)
│   └─ [reads ~/.config/heyclaude/config]
│
├─ read_clipboard() (line 398)
│   ├─ eval "$CLIPBOARD_TOOL"
│   └─ error() - if empty or too large
│
├─ extract_operators() (line 404)
│   └─ [pattern matching logic]
│
├─ build_prompt() (line 407)
│   └─ [operator transformation logic]
│
├─ run_claude() - initial (line 410)
│   ├─ show_spinner() - background
│   └─ claude -p "$prompt"
│
└─ WHILE loop (line 416-427)
    ├─ get_continuation_choice() (line 417)
    │   └─ stty raw -echo
    │
    └─ run_claude() - continue (line 419)
        └─ claude -c
```

### 3. Utility Function Calls
```
error() (line 44-49)
│
└─ exit $exit_code - if non-zero

cleanup() (line 52-62)
│
├─ echo -en "${COLOR_RESET}"
├─ jobs -p
├─ xargs -r kill
└─ echo - if interrupted

show_spinner() (line 65-76)
│
├─ kill -0 "$pid" - check if alive
├─ echo -en "\r${SPINNER_FRAMES[$frame]}"
└─ sleep 0.1
```

### 4. Detection Function Details
```
detect_clipboard_tool() (line 82-95)
│
├─ FOR tool in [xclip, xsel, wl-paste, pbpaste]
│   ├─ command -v "$tool_name"
│   └─ CLIPBOARD_TOOL="$tool_cmd" - if found
│
└─ error() - if none found

check_claude_cli() (line 133-137)
│
├─ command -v claude
└─ error() - if not found

detect_terminal() (line 98-130)
│
├─ [[ -t 0 && -t 1 && -t 2 ]] - check if in TTY
├─ [[ -n "${TERMINAL:-}" ]] - check env var
├─ FOR term in [gnome-terminal, konsole, ...]
│   └─ command -v "$term"
│
└─ error() - if none found
```

### 5. Input Processing Functions
```
read_clipboard() (line 175-193)
│
├─ eval "$CLIPBOARD_TOOL"
├─ [[ -z "$content" ]] - check empty
├─ ${#content} - check size
└─ echo "$content"

extract_operators() (line 196-233)
│
├─ Pattern matching loops
│   ├─ [[ "$remaining" =~ $length_pattern ]]
│   ├─ [[ "$remaining" =~ $format_pattern ]]
│   └─ [[ "$remaining" =~ $code_pattern ]]
│
└─ CLEAN_CONTENT="$remaining"

build_prompt() (line 236-278)
│
├─ FOR op in "${OPERATORS[@]}"
│   └─ case "$op" in ...
│
└─ echo "$prompt"
```

### 6. Display Functions
```
show_status() (line 285-288)
│
└─ echo -e "${COLOR_SYSTEM}${message}${COLOR_RESET}"

get_continuation_choice() (line 291-313)
│
├─ echo -e prompt
├─ stty -g - save settings
├─ stty raw -echo
├─ dd bs=1 count=1
├─ case "$choice" in ...
└─ stty "$old_settings" - restore
```

### 7. Claude Execution Function
```
run_claude() (line 320-356)
│
├─ IF mode == "initial"
│   ├─ Background subshell for spinner
│   │   └─ WHILE true
│   │       ├─ echo -en spinner
│   │       └─ sleep 0.1
│   │
│   ├─ claude -p "$prompt"
│   ├─ kill $spinner_pid
│   └─ wait $spinner_pid
│
└─ ELSE mode == "continue"
    └─ claude -c
```

## Function Call Frequency

### Called Once Per Execution
- `main()` - Entry point
- `detect_clipboard_tool()` - Tool detection
- `check_claude_cli()` - Dependency check
- `detect_terminal()` - Terminal detection
- `detect_voice_tools()` - Optional feature check
- `load_config()` - Configuration loading
- `cleanup()` - Exit handler

### Called Once Per Query
- `read_clipboard()` - Get input
- `extract_operators()` - Parse operators
- `build_prompt()` - Enhance prompt
- `run_claude("initial")` - First query

### Called Multiple Times
- `get_continuation_choice()` - After each response
- `run_claude("continue")` - For each continuation
- `show_spinner()` - Animation loop
- `error()` - As needed

## Error Propagation

```
Error Detection Points:
│
├─ detect_clipboard_tool()
│   └─ error "No clipboard tool found" → exit 1
│
├─ check_claude_cli()
│   └─ error "Claude CLI not installed" → exit 1
│
├─ detect_terminal()
│   └─ error "No terminal emulator found" → exit 1
│
├─ read_clipboard()
│   ├─ error "Failed to read clipboard" → exit 1
│   ├─ error "Nothing in clipboard" → exit 0
│   └─ error "Clipboard content too large" → exit 1
│
└─ run_claude()
    └─ error "Claude command failed" → exit 1
```

## Signal Flow

```
Signal Handling:
│
├─ SIGINT (Ctrl+C)
│   ├─ Set INTERRUPTED=true
│   ├─ exit 130
│   └─ triggers → cleanup()
│
├─ SIGTERM
│   ├─ Set INTERRUPTED=true
│   ├─ exit 130
│   └─ triggers → cleanup()
│
└─ EXIT (any exit)
    └─ cleanup()
        ├─ Reset colors
        ├─ Kill child processes
        └─ Show message if interrupted
```

## Subprocess Creation

```
main process (heyclaude)
│
├─ detect_clipboard_tool()
│   └─ command -v (multiple times, exits immediately)
│
├─ read_clipboard()
│   └─ xclip/xsel/wl-paste (exits immediately)
│
├─ run_claude("initial")
│   ├─ background subshell (spinner)
│   │   └─ sleep 0.1 (repeated)
│   │
│   └─ claude -p (long-running)
│       └─ node process (API communication)
│
└─ run_claude("continue")
    └─ claude -c (long-running)
```

## Function Dependencies

### Functions with No Dependencies
- `error()` - Pure output function
- `show_status()` - Pure output function
- `show_spinner()` - Only uses built-ins

### Functions Dependent on Global State
- `read_clipboard()` - Requires `CLIPBOARD_TOOL`
- `detect_terminal()` - Sets `TERMINAL_CMD`
- `run_claude()` - Uses colors and terminal
- `cleanup()` - Uses `INTERRUPTED` flag

### Functions that Modify Global State
- `detect_clipboard_tool()` - Sets `CLIPBOARD_TOOL`
- `detect_terminal()` - Sets `TERMINAL_CMD`
- `detect_voice_tools()` - Sets `HAS_VOICE`
- `extract_operators()` - Sets `OPERATORS` and `CLEAN_CONTENT`
- `load_config()` - Modifies color and behavior variables

## Execution Time Analysis

### Fast Functions (<1ms)
- `show_status()`
- `error()`
- `build_prompt()`
- `extract_operators()`

### Medium Functions (1-10ms)
- `detect_clipboard_tool()`
- `check_claude_cli()`
- `detect_terminal()`
- `read_clipboard()`
- `load_config()`

### Slow Functions (>10ms)
- `run_claude()` - Network I/O
- `get_continuation_choice()` - User input
- `show_spinner()` - Intentional delays

## Call Graph Patterns

### Initialization Pattern
```
main()
  → detect_*() functions (parallel checks)
  → load_config()
  → Ready for operation
```

### Input Processing Pattern
```
read_clipboard()
  → extract_operators()
  → build_prompt()
  → Enhanced input ready
```

### Execution Pattern
```
run_claude("initial")
  → spinner (background)
  → claude CLI
  → stream output
  → kill spinner
```

### Continuation Pattern
```
get_continuation_choice()
  → SPACE: run_claude("continue") → loop
  → ESC: exit loop → cleanup()
```

This call graph architecture ensures:
1. Clear separation of concerns
2. Minimal function interdependencies
3. Predictable execution flow
4. Easy error propagation
5. Clean subprocess management