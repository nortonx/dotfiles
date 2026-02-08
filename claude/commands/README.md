# Project Claude Code Commands

## Available Commands

### Development

- `/component [name]` - Generate React component
- `/api [endpoint]` - Create REST endpoint
- `/test` - Generate tests for current file

### Maintenance

- `/review` - Code review checklist
- `/security` - Security audit
- `/optimize` - Performance optimization

### Utilities

- `/fix-issue [number]` - Fix GitHub issue
- `/deploy` - Deployment checklist
- `/morning` - Morning routine

## Usage Examples

\`\`\`bash
> /component UserProfile
> /api users/profile
> /fix-issue 1234
\`\`\`

## Creating New Commands

1. Create a .md file in .claude/commands/
2. Use $ARGUMENTS for dynamic content
3. Be specific and detailed
4. Test the command before committing
EOF
