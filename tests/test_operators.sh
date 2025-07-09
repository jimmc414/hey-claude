#!/bin/bash
# Test operator extraction logic

# Source just the operator extraction function
extract_operators() {
    local input="$1"
    local remaining="$input"
    
    OPERATORS=()
    
    # Length operators
    local length_pattern="^(brief:|short:|medium:|detailed:|essay:|max[[:space:]]+[0-9]+[[:space:]]+(words|lines|paragraphs):)"
    
    # Format operators  
    local format_pattern="^(list:|steps:|tldr:|outline:|table:|json:|yaml:|markdown:)"
    
    # Code operators
    local code_pattern="^(code[[:space:]]+only:|commented:|diff:|terminal:)"
    
    # Keep extracting operators while they match
    while true; do
        local matched=false
        
        # Check each pattern
        for pattern in "$length_pattern" "$format_pattern" "$code_pattern"; do
            if [[ "$remaining" =~ $pattern ]]; then
                local op="${BASH_REMATCH[1]}"
                # Normalize operator (remove trailing colon and spaces)
                op="${op%:}"
                op="${op// /_}"
                OPERATORS+=("$op")
                remaining="${remaining#${BASH_REMATCH[0]}}"
                matched=true
                break
            fi
        done
        
        [[ "$matched" == false ]] && break
        
        # Skip whitespace between operators
        remaining="${remaining#"${remaining%%[![:space:]]*}"}"
    done
    
    CLEAN_CONTENT="$remaining"
}

# Test cases
test_cases=(
    "brief: explain Git"
    "list: benefits of Python"
    "brief: list: explain Docker"
    "max 50 words: summarize AI"
    "code only: reverse a string"
    "This has no operators"
    "brief: list: code only: fix error"
)

echo "Testing operator extraction:"
echo "============================"

for test in "${test_cases[@]}"; do
    echo
    echo "Input: \"$test\""
    extract_operators "$test"
    echo "Operators: [${OPERATORS[@]}]"
    echo "Clean content: \"$CLEAN_CONTENT\""
done