Generate a database migration for: $ARGUMENTS

## Migration Requirements

### 1. Generate Migration Files

Create both up and down migration files:

- migrations/[timestamp]_$ARGUMENTS.up.sql
- migrations/[timestamp]_$ARGUMENTS.down.sql

### 2. Migration Standards

- Use transactions where appropriate
- Include data migration if needed
- Preserve existing data
- Handle edge cases
- Add appropriate indexes
- Include foreign key constraints

### 3. Safety Checks

- Verify rollback capability
- Check for data loss risks
- Identify performance impacts
- Note any application code changes needed

### 4. Documentation

Include:

- Migration purpose
- Affected tables
- Performance considerations
- Rollback instructions
- Testing steps

### 5. Validation Queries

Provide SQL to:

- Verify migration success
- Check data integrity
- Validate constraints
- Test performance

Generate production-ready migration scripts that can be safely deployed.
EOF
