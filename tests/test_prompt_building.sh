#!/bin/bash
# Test prompt building logic

# Mock operator array and build_prompt function
build_prompt() {
    local content="$1"
    local prompt=""
    
    # Process operators into instructions
    for op in "${OPERATORS[@]}"; do
        case "$op" in
            # Length operators
            brief) prompt+="Please provide a brief response (1-2 sentences). " ;;
            short) prompt+="Keep your response to one paragraph. " ;;
            medium) prompt+="Provide a 2-3 paragraph response. " ;;
            detailed) prompt+="Provide a comprehensive response. " ;;
            essay) prompt+="Provide a long-form response. " ;;
            max_*_words) 
                local words="${op#max_}"
                words="${words%_words}"
                prompt+="Limit your response to ${words} words. "
                ;;
            max_*_lines)
                local lines="${op#max_}"
                lines="${lines%_lines}"
                prompt+="Limit your response to ${lines} lines. "
                ;;
            
            # Format operators
            list) prompt+="Format your response as a bullet point list. " ;;
            steps) prompt+="Format your response as numbered steps. " ;;
            tldr) prompt+="Start with a TL;DR summary, then provide details. " ;;
            outline) prompt+="Format as a hierarchical outline. " ;;
            table) prompt+="Format your response as a table. " ;;
            json) prompt+="Format your response as JSON. " ;;
            yaml) prompt+="Format your response as YAML. " ;;
            markdown) prompt+="Use rich markdown formatting. " ;;
            
            # Code operators
            code_only) prompt+="Respond with only code, no explanations. " ;;
            commented) prompt+="Include helpful inline comments in any code. " ;;
            diff) prompt+="Show changes in diff/patch format. " ;;
            terminal) prompt+="Format commands for direct copy-paste to terminal. " ;;
        esac
    done
    
    # Add user content
    if [[ -n "$prompt" ]]; then
        prompt+=$'\n\nUser request: '
        prompt+="$content"
    else
        prompt="$content"
    fi
    
    echo "$prompt"
}

# Test cases
echo "Testing prompt building:"
echo "======================="

# Test 1: No operators
OPERATORS=()
echo -e "\nTest 1: No operators"
echo "Content: \"What is Git?\""
result=$(build_prompt "What is Git?")
echo "Result: \"$result\""

# Test 2: Single operator
OPERATORS=("brief")
echo -e "\nTest 2: Single operator [brief]"
echo "Content: \"explain Python\""
result=$(build_prompt "explain Python")
echo "Result: \"$result\""

# Test 3: Multiple operators
OPERATORS=("brief" "list")
echo -e "\nTest 3: Multiple operators [brief, list]"
echo "Content: \"explain Docker benefits\""
result=$(build_prompt "explain Docker benefits")
echo "Result: \"$result\""

# Test 4: Code operator
OPERATORS=("code_only")
echo -e "\nTest 4: Code operator [code_only]"
echo "Content: \"reverse a string in Python\""
result=$(build_prompt "reverse a string in Python")
echo "Result: \"$result\""

# Test 5: Complex combination
OPERATORS=("max_30_words" "list")
echo -e "\nTest 5: Complex [max_30_words, list]"
echo "Content: \"benefits of testing\""
result=$(build_prompt "benefits of testing")
echo "Result: \"$result\""

# Verify that prompts with operators include actual line breaks
line_count=$(printf '%s' "$result" | wc -l | tr -d '[:space:]')
if [[ "$result" != *$'\n\nUser request: '* ]]; then
    echo "ERROR: Prompt is missing expected newline-separated user request section."
    printf 'Quoted prompt: %q\n' "$result"
    exit 1
fi

if [[ "$result" == *\\n\\nUser\ request:* ]]; then
    echo "ERROR: Prompt still contains escaped newline sequences."
    printf 'Quoted prompt: %q\n' "$result"
    exit 1
fi

if (( line_count < 2 )); then
    echo "ERROR: Expected prompt to span multiple lines, but only counted $line_count line(s)."
    printf 'Quoted prompt: %q\n' "$result"
    exit 1
fi

printf 'Line break check passed. Prompt representation: %q\n' "$result"
