# Hey Claude - Test Plan

This document outlines comprehensive test scenarios to ensure Hey Claude functions correctly across different environments and use cases.

## Test Environment Setup

### Prerequisites
- Linux system (Ubuntu 20.04+ recommended)
- Claude CLI installed (`npm install -g @anthropic-ai/claude`)
- Claude CLI authenticated (`claude login`)
- At least one clipboard tool (xclip, xsel, or wl-paste)
- Terminal emulator (gnome-terminal, xterm, etc.)

### Test Data Preparation
```bash
# Create test content files
echo "Simple test content" > test_simple.txt
echo "brief: explain quantum computing" > test_operator.txt
printf "Line 1\nLine 2\nLine 3" > test_multiline.txt
python3 -c "print('x' * 15000)" > test_large.txt
echo "Special chars: \$PATH & 'quotes' \"double\" \`backticks\`" > test_special.txt
```

## Core Functionality Tests

### Test 1: Basic Clipboard Flow
**Objective**: Verify basic copy-paste-respond flow

**Steps**:
1. Copy text: `echo "What is machine learning?" | xclip -selection clipboard`
2. Run: `./heyclaude`
3. Verify thinking indicator appears
4. Verify response streams in real-time
5. Verify continuation prompt appears
6. Press ESC to exit

**Expected**: Smooth flow from invocation to response to exit

### Test 2: Empty Clipboard
**Objective**: Verify graceful handling of empty clipboard

**Steps**:
1. Clear clipboard: `echo -n "" | xclip -selection clipboard`
2. Run: `./heyclaude`

**Expected**: 
```
📋 Nothing in clipboard. Copy some text first!
```
Exit code: 0

### Test 3: Large Clipboard Content
**Objective**: Verify size limit enforcement

**Steps**:
1. Copy large content: `cat test_large.txt | xclip -selection clipboard`
2. Run: `./heyclaude`

**Expected**:
```
⚠️  Clipboard content too large (15000 bytes, max 10240)
```
Exit code: 1

### Test 4: Continuation Flow
**Objective**: Verify conversation continuation

**Steps**:
1. Copy: `echo "Tell me about Python" | xclip -selection clipboard`
2. Run: `./heyclaude`
3. Wait for response
4. Press SPACE
5. Verify Claude continues conversation
6. Press ESC

**Expected**: Seamless continuation with context maintained

## Operator Tests

### Test 5: Single Operator - Brief
**Objective**: Verify brief operator

**Steps**:
1. Copy: `echo "brief: explain recursion" | xclip -selection clipboard`
2. Run: `./heyclaude`

**Expected**: 1-2 sentence response

### Test 6: Single Operator - List
**Objective**: Verify list formatting

**Steps**:
1. Copy: `echo "list: benefits of version control" | xclip -selection clipboard`
2. Run: `./heyclaude`

**Expected**: Bullet point response

### Test 7: Chained Operators
**Objective**: Verify multiple operators work together

**Steps**:
1. Copy: `echo "brief: list: explain REST API" | xclip -selection clipboard`
2. Run: `./heyclaude`

**Expected**: Brief bullet points (1-2 points)

### Test 8: Numeric Operator
**Objective**: Verify word limit operator

**Steps**:
1. Copy: `echo "max 30 words: explain cloud computing" | xclip -selection clipboard`
2. Run: `./heyclaude`

**Expected**: Response ≤ 30 words

### Test 9: Code Operator
**Objective**: Verify code-only output

**Steps**:
1. Copy: `echo "code only: Python function to reverse a string" | xclip -selection clipboard`
2. Run: `./heyclaude`

**Expected**: Only code, no explanation

### Test 10: Invalid Operator
**Objective**: Verify invalid operators are ignored

**Steps**:
1. Copy: `echo "invalid: explain Git" | xclip -selection clipboard`
2. Run: `./heyclaude`

**Expected**: Normal response (operator ignored)

## Special Character Tests

### Test 11: Shell Metacharacters
**Objective**: Verify proper escaping

**Steps**:
1. Copy: `echo "What does \$PATH do in bash?" | xclip -selection clipboard`
2. Run: `./heyclaude`

**Expected**: Correct handling of $, no shell expansion

### Test 12: Quotes and Backticks
**Objective**: Verify quote handling

**Steps**:
1. Copy: `echo "Explain 'single' vs \"double\" quotes and \`backticks\`" | xclip -selection clipboard`
2. Run: `./heyclaude`

**Expected**: All quote types preserved in prompt

### Test 13: Unicode Content
**Objective**: Verify Unicode support

**Steps**:
1. Copy: `echo "Translate: こんにちは 🌍 café" | xclip -selection clipboard`
2. Run: `./heyclaude`

**Expected**: Unicode preserved and handled correctly

### Test 14: Multiline Content
**Objective**: Verify multiline clipboard content

**Steps**:
1. Copy multiline code or text
2. Run: `./heyclaude`

**Expected**: Line breaks preserved in prompt

## Error Handling Tests

### Test 15: Missing Claude CLI
**Objective**: Verify dependency check

**Steps**:
1. Temporarily rename claude: `sudo mv /usr/local/bin/claude /usr/local/bin/claude.bak`
2. Run: `./heyclaude`
3. Restore: `sudo mv /usr/local/bin/claude.bak /usr/local/bin/claude`

**Expected**:
```
⚠️  Claude CLI not installed
    Run: npm install -g @anthropic-ai/claude
    Or visit: anthropic.com/claude-cli
```

### Test 16: Missing Clipboard Tool
**Objective**: Verify clipboard tool detection

**Steps**:
1. Run with PATH excluding clipboard tools:
   ```bash
   PATH=/usr/bin:/bin ./heyclaude
   ```

**Expected**:
```
⚠️  No clipboard tool found
    Install one of: xclip, xsel, wl-clipboard
    Ubuntu/Debian: sudo apt install xclip
```

### Test 17: User Interruption
**Objective**: Verify Ctrl+C handling

**Steps**:
1. Copy: `echo "Explain artificial intelligence in detail" | xclip -selection clipboard`
2. Run: `./heyclaude`
3. Press Ctrl+C during response

**Expected**:
```
Interrupted. Goodbye!
```
Clean exit, no hanging processes

### Test 18: Network Failure
**Objective**: Verify network error handling

**Steps**:
1. Disable network temporarily
2. Run: `./heyclaude` with content
3. Re-enable network

**Expected**: Clear network error message from Claude CLI

## Terminal Behavior Tests

### Test 19: Terminal Detection
**Objective**: Verify terminal auto-detection

**Steps**:
1. Run from different terminals:
   - gnome-terminal
   - xterm
   - konsole
   - alacritty

**Expected**: Launches correctly in each

### Test 20: Non-Terminal Launch
**Objective**: Verify behavior when not in terminal

**Steps**:
1. Create desktop launcher
2. Launch from GUI

**Expected**: Opens new terminal window

### Test 21: Terminal Sizing
**Objective**: Verify terminal size handling

**Steps**:
1. Run in small terminal (40x10)
2. Run in large terminal (200x50)
3. Resize during operation

**Expected**: Content adapts, no crashes

## Configuration Tests

### Test 22: Default Configuration
**Objective**: Verify zero-config operation

**Steps**:
1. Remove config: `rm -rf ~/.config/heyclaude`
2. Run: `./heyclaude`

**Expected**: Works with all defaults

### Test 23: Custom Configuration
**Objective**: Verify config loading

**Steps**:
1. Create config:
   ```bash
   mkdir -p ~/.config/heyclaude
   echo "max_clipboard_size=5000" > ~/.config/heyclaude/config
   ```
2. Copy content larger than 5000 bytes
3. Run: `./heyclaude`

**Expected**: Respects custom limit

### Test 24: Invalid Configuration
**Objective**: Verify config error handling

**Steps**:
1. Create invalid config:
   ```bash
   echo "invalid_key=value" > ~/.config/heyclaude/config
   ```
2. Run: `./heyclaude`

**Expected**: Ignores invalid keys, continues normally

## Performance Tests

### Test 25: Startup Speed
**Objective**: Verify fast startup

**Steps**:
1. Measure startup time:
   ```bash
   time ./heyclaude
   ```

**Expected**: Real time < 100ms to thinking indicator

### Test 26: Rapid Invocation
**Objective**: Verify no resource leaks

**Steps**:
1. Run multiple times rapidly:
   ```bash
   for i in {1..10}; do
       echo "test $i" | xclip -selection clipboard
       timeout 2 ./heyclaude
   done
   ```

**Expected**: No accumulating processes or memory

## Integration Tests

### Test 27: Hotkey Integration
**Objective**: Verify hotkey launch

**Steps**:
1. Set up hotkey binding
2. Copy text
3. Press hotkey

**Expected**: Terminal appears with Hey Claude running

### Test 28: Installation Script
**Objective**: Verify installer functionality

**Steps**:
1. Run: `./install.sh`
2. Verify installation to `/usr/local/bin`
3. Test `hc` symlink
4. Test `heyclaude` command

**Expected**: Clean installation, both commands work

### Test 29: Cross-Platform Clipboard
**Objective**: Verify clipboard tool fallback

**Steps**:
1. Test on systems with:
   - Only xclip
   - Only xsel  
   - Only wl-paste (Wayland)
   - Only pbpaste (macOS)

**Expected**: Detects and uses available tool

## Edge Case Tests

### Test 30: Operator Edge Cases
**Objective**: Test operator parsing boundaries

**Test Cases**:
```bash
# Operator without content
echo "brief:" | xclip -selection clipboard

# Operator with colon in content
echo "brief: explain the command: ls -la" | xclip -selection clipboard

# Case variations
echo "BRIEF: LIST: explain" | xclip -selection clipboard

# Operators mid-content
echo "This is brief: not an operator" | xclip -selection clipboard

# Many operators
echo "brief: short: list: max 10 words: explain" | xclip -selection clipboard
```

**Expected**: Correct operator extraction in each case

### Test 31: Process Cleanup
**Objective**: Verify no orphaned processes

**Steps**:
1. Note process count: `ps aux | grep -c heyclaude`
2. Run and interrupt multiple times
3. Check process count again

**Expected**: No accumulating processes

### Test 32: File Descriptor Leaks
**Objective**: Verify proper FD handling

**Steps**:
1. Check open files: `lsof -p $$ | wc -l`
2. Run Hey Claude multiple times
3. Check open files again

**Expected**: No increasing file descriptors

## Stress Tests

### Test 33: Long Running Session
**Objective**: Verify stability over time

**Steps**:
1. Start conversation
2. Continue 20+ times with SPACE
3. Monitor memory usage

**Expected**: Stable memory, no degradation

### Test 34: Special Terminal States
**Objective**: Verify terminal handling

**Test Cases**:
- Run inside tmux
- Run inside screen  
- Run over SSH
- Run in VSCode terminal
- Run in Docker container

**Expected**: Functions correctly in all environments

## Accessibility Tests

### Test 35: Screen Reader Compatibility
**Objective**: Verify screen reader friendly output

**Steps**:
1. Enable screen reader
2. Run Hey Claude
3. Verify status messages are readable
4. Verify response is readable

**Expected**: Clear text output, no graphics-only information

### Test 36: Keyboard-Only Operation
**Objective**: Verify no mouse required

**Steps**:
1. Complete full flow using only keyboard
2. Test all interactions

**Expected**: Everything accessible via keyboard

## Security Tests

### Test 37: Command Injection
**Objective**: Verify no command injection

**Steps**:
1. Copy: `echo "; rm -rf /" | xclip -selection clipboard`
2. Run: `./heyclaude`

**Expected**: Safely passed to Claude, no execution

### Test 38: Path Traversal
**Objective**: Verify no path traversal

**Steps**:
1. Set malicious config path attempts
2. Try to read files outside config dir

**Expected**: Confined to intended directories

## Regression Test Checklist

Before any release, verify:

- [ ] Basic flow works (copy → run → response → exit)
- [ ] All operators function correctly
- [ ] Error messages display properly
- [ ] Ctrl+C handling works
- [ ] Configuration loading works
- [ ] Installation script works
- [ ] No resource leaks
- [ ] Performance targets met

## Test Automation

While Hey Claude uses manual testing, key tests can be automated:

```bash
#!/bin/bash
# Automated test runner

echo "Running Hey Claude automated tests..."

# Test 1: Empty clipboard
echo -n "" | xclip -selection clipboard
output=$(timeout 2 ./heyclaude 2>&1)
if [[ "$output" == *"Nothing in clipboard"* ]]; then
    echo "✓ Empty clipboard test passed"
else
    echo "✗ Empty clipboard test failed"
fi

# Test 2: Brief operator
echo "brief: test" | xclip -selection clipboard
output=$(timeout 5 ./heyclaude 2>&1)
# Check response characteristics

# Add more automated tests...
```

## Test Coverage Matrix

| Component | Unit | Integration | E2E | Stress |
|-----------|------|-------------|-----|--------|
| Clipboard Detection | ✓ | ✓ | ✓ | ✓ |
| Claude CLI Check | ✓ | ✓ | ✓ | - |
| Operator Parsing | ✓ | ✓ | ✓ | ✓ |
| Response Streaming | - | ✓ | ✓ | ✓ |
| Error Handling | ✓ | ✓ | ✓ | - |
| Configuration | ✓ | ✓ | ✓ | - |
| Terminal Handling | - | ✓ | ✓ | ✓ |
| Signal Handling | ✓ | ✓ | ✓ | ✓ |

## Success Criteria

All tests pass when:
1. Expected output matches actual output
2. Exit codes are correct
3. No error messages unless expected
4. No hanging processes
5. No resource leaks
6. Performance within targets

This comprehensive test plan ensures Hey Claude maintains its quality and reliability across all supported use cases and environments.