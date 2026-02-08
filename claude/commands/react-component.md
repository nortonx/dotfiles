# Generate a new React component named "$ARGUMENTS" with the following specifications

## Component Structure

Create a functional component using TypeScript with these files:

- components/$ARGUMENTS/$ARGUMENTS.tsx - Main component file
<!--- components/$ARGUMENTS/$ARGUMENTS.styles.ts - Styled components-->
- components/$ARGUMENTS/$ARGUMENTS.types.ts - TypeScript interfaces
- components/$ARGUMENTS/$ARGUMENTS.test.tsx - Unit tests
- components/$ARGUMENTS/$ARGUMENTS.stories.tsx - Storybook stories
- components/$ARGUMENTS/index.ts - Export file

## Requirements

1. Use React hooks appropriately (useState, useEffect, etc.)
2. Include proper TypeScript types for all props
3. Add JSDoc comments for the main component where TypeScript documentation is not available
4. Create comprehensive unit tests with at least 80% coverage
5. Include Storybook stories for all component states
6. Follow our project's naming conventions
7. Use styled-components for styling
8. Make the component accessible (ARIA attributes)
9. Include error boundaries if appropriate
10. Add performance optimizations (memo, useCallback) where needed

## Code Style

- Follow ESLint configuration
- Use consistent naming patterns
- Include prop validation
- Export both named and default exports

Please generate all files with production-ready code.
EOF
