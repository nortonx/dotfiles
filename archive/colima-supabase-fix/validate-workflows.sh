#!/bin/bash

# Workflow Validation Script
# This script validates the GitHub Actions workflow files

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOWS_DIR="$SCRIPT_DIR/../.github/workflows"

echo "🔍 Validating GitHub Actions Workflows..."
echo "Workflows directory: $WORKFLOWS_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Function to check if file exists
check_file_exists() {
    local file="$1"
    local description="$2"

    if [ -f "$file" ]; then
        print_success "$description exists"
        return 0
    else
        print_error "$description does not exist: $file"
        return 1
    fi
}

# Function to check if string exists in file
check_content() {
    local file="$1"
    local pattern="$2"
    local description="$3"

    if grep -q "$pattern" "$file"; then
        print_success "$description found"
        return 0
    else
        print_error "$description not found in $file"
        return 1
    fi
}

# Function to validate basic YAML syntax
validate_yaml_basic() {
    local file="$1"
    local filename=$(basename "$file")

    echo "Validating $filename..."

    # Check for basic YAML syntax issues
    if [[ $(grep -c "^[[:space:]]*-[[:space:]]*name:" "$file") -gt 0 ]]; then
        print_success "$filename: Steps have names"
    else
        print_warning "$filename: Some steps may be missing names"
    fi

    # Check for proper indentation (basic check)
    if ! grep -q "^[[:space:]]\{1,\}[^[:space:]]" "$file"; then
        print_error "$filename: No indented content found - possible YAML structure issue"
        return 1
    fi

    # Check for required top-level keys
    local required_keys=("name" "on" "jobs")
    for key in "${required_keys[@]}"; do
        if ! grep -q "^$key:" "$file"; then
            print_error "$filename: Missing required top-level key: $key"
            return 1
        fi
    done

    print_success "$filename: Basic YAML structure looks good"
    return 0
}

# Validate ci.yml
validate_ci_workflow() {
    local file="$WORKFLOWS_DIR/ci.yml"
    echo ""
    echo "🔍 Validating CI Workflow..."

    check_file_exists "$file" "CI workflow file" || return 1
    validate_yaml_basic "$file" || return 1

    # Check triggers
    check_content "$file" "branches: \[develop, main\]" "Correct branch triggers"
    check_content "$file" "pull_request:" "Pull request trigger"
    check_content "$file" "push:" "Push trigger"

    # Check jobs
    local required_jobs=("test:" "build:" "e2e-test:" "version-bump:")
    for job in "${required_jobs[@]}"; do
        check_content "$file" "$job" "Job: $job"
    done

    # Check services
    check_content "$file" "postgres:" "PostgreSQL service"
    check_content "$file" "image: postgres:15" "PostgreSQL 15 image"

    # Check Node.js version
    check_content "$file" "node-version: 24.x" "Node.js 24.x version"

    # Check version bump logic
    check_content "$file" "npm version" "Version bump command"
    check_content "$file" "git tag" "Git tagging"

    # Check environment variables
    check_content "$file" "DATABASE_URL:" "Database URL environment variable"

    print_success "CI workflow validation completed"
}

# Validate code-quality.yml
validate_code_quality_workflow() {
    local file="$WORKFLOWS_DIR/code-quality.yml"
    echo ""
    echo "🔍 Validating Code Quality Workflow..."

    check_file_exists "$file" "Code Quality workflow file" || return 1
    validate_yaml_basic "$file" || return 1

    # Check jobs
    local required_jobs=("code-quality:" "security:")
    for job in "${required_jobs[@]}"; do
        check_content "$file" "$job" "Job: $job"
    done

    # Check quality tools
    check_content "$file" "prettier" "Prettier formatting check"
    check_content "$file" "npm run lint" "ESLint check"
    check_content "$file" "tsc --noEmit" "TypeScript check"
    check_content "$file" "npm audit" "Security audit"

    print_success "Code Quality workflow validation completed"
}

# Validate version-management.yml
validate_version_management_workflow() {
    local file="$WORKFLOWS_DIR/version-management.yml"
    echo ""
    echo "🔍 Validating Version Management Workflow..."

    check_file_exists "$file" "Version Management workflow file" || return 1
    validate_yaml_basic "$file" || return 1

    # Check manual trigger
    check_content "$file" "workflow_dispatch:" "Manual workflow dispatch trigger"

    # Check version types
    local version_types=("patch" "minor" "major")
    for type in "${version_types[@]}"; do
        check_content "$file" "$type" "Version type: $type"
    done

    # Check jobs
    local required_jobs=("check-version-bump-needed:" "version-bump:" "create-release:")
    for job in "${required_jobs[@]}"; do
        check_content "$file" "$job" "Job: $job"
    done

    print_success "Version Management workflow validation completed"
}

# Validate dependabot.yml
validate_dependabot_config() {
    local file="$WORKFLOWS_DIR/../dependabot.yml"
    echo ""
    echo "🔍 Validating Dependabot Configuration..."

    check_file_exists "$file" "Dependabot configuration file" || return 1

    # Check package ecosystems
    check_content "$file" "package-ecosystem: \"npm\"" "NPM package ecosystem"
    check_content "$file" "package-ecosystem: \"github-actions\"" "GitHub Actions ecosystem"

    # Check schedule
    check_content "$file" "interval: \"weekly\"" "Weekly update schedule"

    print_success "Dependabot configuration validation completed"
}

# Main validation function
main() {
    echo "Starting workflow validation..."
    echo "Current directory: $(pwd)"
    echo ""

    local errors=0

    # Validate each workflow
    validate_ci_workflow || ((errors++))
    validate_code_quality_workflow || ((errors++))
    validate_version_management_workflow || ((errors++))
    validate_dependabot_config || ((errors++))

    echo ""
    echo "============================================"

    if [ $errors -eq 0 ]; then
        print_success "All workflows validated successfully! 🎉"
        echo ""
        echo "Your GitHub Actions setup includes:"
        echo "• Comprehensive CI pipeline with tests"
        echo "• Code quality and security checks"
        echo "• Automated version management"
        echo "• Dependabot for dependency updates"
        echo ""
        echo "The workflows will trigger on:"
        echo "• Pull requests to main/develop branches"
        echo "• Pushes to main/develop branches"
        echo "• Manual workflow dispatch (version management)"
        echo ""
        return 0
    else
        print_error "Validation failed with $errors error(s)"
        echo ""
        echo "Please fix the issues above before using the workflows."
        return 1
    fi
}

# Run validation
main "$@"
