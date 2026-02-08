#!/bin/bash

# Colima + Supabase Shell Functions
# Source this file in your shell profile for global access
# Usage: source /path/to/colima-supabase-shell-functions.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to fix Colima + Supabase Docker socket issue
colima-supabase-fix() {
    echo -e "${BLUE}🔧 Fixing Colima + Supabase Docker socket...${NC}"

    # Check if Colima is running
    if ! colima status >/dev/null 2>&1; then
        echo -e "${YELLOW}Starting Colima...${NC}"
        colima start
    fi

    # Set Docker context
    docker context use colima > /dev/null 2>&1

    # Create symlink
    local colima_socket="$HOME/.colima/default/docker.sock"
    local standard_socket="/var/run/docker.sock"

    if [ ! -S "$colima_socket" ]; then
        echo -e "${RED}Error: Colima Docker socket not found${NC}"
        return 1
    fi

    echo -e "${BLUE}Creating Docker socket symlink...${NC}"
    sudo mkdir -p /var/run
    sudo rm -f "$standard_socket"
    sudo ln -sf "$colima_socket" "$standard_socket"

    echo -e "${GREEN}✅ Colima + Supabase fix applied successfully${NC}"
    return 0
}

# Function to start Supabase with Colima support
supabase-start() {
    echo -e "${BLUE}🚀 Starting Supabase with Colima support...${NC}"

    # Ensure Colima is running
    if ! colima status >/dev/null 2>&1; then
        echo -e "${YELLOW}Starting Colima...${NC}"
        colima start
    fi

    # Set environment variables
    export DOCKER_HOST="unix:///var/run/docker.sock"
    export DOCKER_CONTEXT="colima"
    docker context use colima > /dev/null 2>&1

    # Check if we're in a Supabase project
    if [ ! -f "supabase/config.toml" ]; then
        echo -e "${YELLOW}Warning: Not in a Supabase project directory${NC}"
        echo -e "${YELLOW}Looking for supabase/config.toml...${NC}"
    fi

    echo -e "${BLUE}Starting Supabase services...${NC}"
    supabase start "$@"

    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✅ Supabase is running!${NC}"
        echo -e "${BLUE}📊 Studio: http://localhost:54323${NC}"
        echo -e "${BLUE}🔌 API: http://localhost:54321${NC}"
        echo -e "${BLUE}🗄️  Database: postgresql://postgres:postgres@localhost:54322/postgres${NC}"
    fi
}

# Function to stop Supabase
supabase-stop() {
    echo -e "${BLUE}🛑 Stopping Supabase services...${NC}"
    supabase stop "$@"
    echo -e "${GREEN}✅ Supabase stopped${NC}"
}

# Function to test Colima + Supabase setup
test-colima-supabase() {
    echo -e "${BLUE}🧪 Testing Colima + Supabase setup...${NC}"
    echo "======================================="

    local tests_passed=0
    local tests_total=0

    # Test 1: Colima status
    echo -e "${BLUE}[TEST] Checking Colima status...${NC}"
    tests_total=$((tests_total + 1))
    if colima status 2>&1 | grep -q "running"; then
        echo -e "${GREEN}[PASS] Colima is running${NC}"
        tests_passed=$((tests_passed + 1))
    else
        echo -e "${RED}[FAIL] Colima is not running${NC}"
    fi

    # Test 2: Docker connectivity
    echo -e "${BLUE}[TEST] Checking Docker connectivity...${NC}"
    tests_total=$((tests_total + 1))
    export DOCKER_HOST="unix:///var/run/docker.sock"
    if docker version > /dev/null 2>&1; then
        echo -e "${GREEN}[PASS] Docker is accessible${NC}"
        tests_passed=$((tests_passed + 1))
    else
        echo -e "${RED}[FAIL] Docker is not accessible${NC}"
    fi

    # Test 3: Docker socket symlink
    echo -e "${BLUE}[TEST] Checking Docker socket symlink...${NC}"
    tests_total=$((tests_total + 1))
    if [ -L "/var/run/docker.sock" ]; then
        local symlink_target=$(readlink "/var/run/docker.sock" 2>/dev/null || echo "unknown")
        if [[ "$symlink_target" == *".colima/default/docker.sock" ]]; then
            echo -e "${GREEN}[PASS] Docker socket symlink is correct${NC}"
            tests_passed=$((tests_passed + 1))
        else
            echo -e "${RED}[FAIL] Docker socket symlink points to wrong location: $symlink_target${NC}"
        fi
    else
        echo -e "${RED}[FAIL] Docker socket symlink does not exist${NC}"
    fi

    # Test 4: Supabase CLI
    echo -e "${BLUE}[TEST] Checking Supabase CLI...${NC}"
    tests_total=$((tests_total + 1))
    if command -v supabase > /dev/null 2>&1; then
        echo -e "${GREEN}[PASS] Supabase CLI is installed${NC}"
        tests_passed=$((tests_passed + 1))
    else
        echo -e "${RED}[FAIL] Supabase CLI is not installed${NC}"
    fi

    echo ""
    echo "======================================="
    echo "Results: $tests_passed / $tests_total tests passed"

    if [ $tests_passed -eq $tests_total ]; then
        echo -e "${GREEN}✅ All tests passed! Setup is working correctly.${NC}"
        return 0
    else
        echo -e "${RED}❌ Some tests failed. Run 'colima-supabase-fix' to resolve issues.${NC}"
        return 1
    fi
}

# Function to show help
colima-supabase-help() {
    echo "Colima + Supabase Helper Functions"
    echo "=================================="
    echo ""
    echo "Available functions:"
    echo "  colima-supabase-fix    # Fix Docker socket issues"
    echo "  supabase-start         # Start Supabase with Colima support"
    echo "  supabase-stop          # Stop Supabase services"
    echo "  test-colima-supabase   # Test the setup"
    echo "  colima-supabase-help   # Show this help"
    echo ""
    echo "Usage examples:"
    echo "  # Fix Docker socket (run once or when issues occur)"
    echo "  colima-supabase-fix"
    echo ""
    echo "  # Start Supabase from any project directory"
    echo "  cd /path/to/your/supabase-project"
    echo "  supabase-start"
    echo ""
    echo "  # Test if everything is working"
    echo "  test-colima-supabase"
    echo ""
    echo "Installation:"
    echo "  Add this to your ~/.zshrc or ~/.bashrc:"
    echo "  source /path/to/colima-supabase-shell-functions.sh"
}

# Set up environment variables
export DOCKER_HOST="unix:///var/run/docker.sock"
export DOCKER_CONTEXT="colima"

# Auto-set Docker context if Colima is running
if command -v colima > /dev/null 2>&1 && colima status >/dev/null 2>&1; then
    docker context use colima > /dev/null 2>&1 || true
fi

# Print load message
echo -e "${GREEN}✅ Colima + Supabase functions loaded${NC}"
echo -e "${BLUE}Run 'colima-supabase-help' for usage information${NC}"
