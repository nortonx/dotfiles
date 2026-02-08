# Purpose

Verify latest changes in the current branch and validate implementation

## Usage

/commandname validate-implementation

## Tasks

1. Verify code changes and check if unit tests pass
2. All code quality checks must pass (lint, typecheck, format, build and unit tests)
3. Check any other relevant aspects that need to be verified
4. Do not add experimental features
5. Avoid Turbopack if is not already installed
6. Check Cognitive Complexity of functions and methods

## Output

Provide your analysis in this structure:

### Critical Performance Issues

List issues that severely impact performance

### High Priority Optimizations

Changes that would provide significant improvements

### Medium Priority Optimizations

Nice-to-have improvements

### Quick Wins

Simple changes with immediate benefits

For each optimization, provide:

- Current code snippet
- Optimized code snippet
- Expected performance improvement
- Implementation complexity (Easy/Medium/Hard)

## Notes

Summarize updated changes and test results
EOF
