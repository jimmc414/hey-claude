# Hey Claude - Project Structure

```
hey-claude/
├── heyclaude                   # Main executable script
├── LICENSE                     # MIT License
├── README.md                   # User-facing documentation
├── PROJECT_STRUCTURE.md        # This file
├── .gitignore                  # Git ignore rules
│
├── docs/                       # All documentation
│   ├── design/                 # Design documents
│   │   ├── requirements.md     # Project requirements
│   │   ├── architecture.md     # System architecture
│   │   └── ux_design.md        # UX design principles
│   │
│   ├── technical/              # Technical documentation
│   │   ├── implementation.md   # Implementation guide
│   │   ├── implementation_summary.md
│   │   ├── execution_flow.md   # Runtime flow
│   │   ├── data_flow_diagram.md
│   │   ├── sequence_diagram.md
│   │   └── call_graph.md       # Function relationships
│   │
│   └── testing/                # Test documentation
│       ├── test_plan.md        # Comprehensive test plan
│       └── test_results.md     # Test execution results
│
├── scripts/                    # Utility scripts
│   └── install.sh              # Installation script
│
└── tests/                      # Test files
    ├── test_operators.sh       # Operator testing
    ├── test_prompt_building.sh # Prompt building tests
    ├── mock_clipboard.sh       # Mock clipboard for testing
    └── heyclaude_test          # Test version of main script
```

## Directory Purposes

### `/` (Root)
- Contains the main executable and user-facing files
- Everything a user needs to get started

### `/docs`
- Comprehensive documentation organized by type
- Design docs explain the "why"
- Technical docs explain the "how"
- Testing docs ensure quality

### `/scripts`
- Installation and utility scripts
- Helper tools for setup and maintenance

### `/tests`
- Test scripts and mock tools
- Everything needed to verify functionality

## File Naming Convention
- All lowercase with underscores
- No spaces in filenames
- Descriptive names that indicate purpose
- Markdown files use `.md` extension
- Shell scripts are executable