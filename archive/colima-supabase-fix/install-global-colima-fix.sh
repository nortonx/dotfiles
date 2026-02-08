#!/bin/bash

# Global Colima + Supabase Fix Installer
# This script installs the Colima+Supabase Docker socket fix system-wide

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global installation paths
GLOBAL_BIN_DIR="/usr/local/bin"
GLOBAL_SCRIPTS_DIR="/usr/local/share/colima-supabase-fix"
USER_HOME="$HOME"

print_header() {
    echo ""
    echo "🌍 Colima + Supabase Global Fix Installer"
    echo "=========================================="
    echo ""
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_requirements() {
    print_status "Checking system requirements..."

    # Check if running on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is designed for macOS. Detected OS: $OSTYPE"
        exit 1
    fi

    # Check if Colima is installed
    if ! command -v colima > /dev/null 2>&1; then
        print_warning "Colima not found. Please install it first:"
        echo "  brew install colima"
        echo ""
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    # Check if Supabase CLI is installed
    if ! command -v supabase > /dev/null 2>&1; then
        print_warning "Supabase CLI not found. Please install it first:"
        echo "  brew install supabase/tap/supabase"
        echo ""
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    print_success "System requirements check completed"
}

create_global_scripts() {
    print_status "Creating global scripts directory..."

    # Create global scripts directory
    sudo mkdir -p "$GLOBAL_SCRIPTS_DIR"

    # Create the main fix script
    print_status "Creating global fix script..."
    sudo tee "$GLOBAL_SCRIPTS_DIR/fix-colima-supabase.sh" > /dev/null << 'EOF'
#!/bin/bash

# Global Colima + Supabase Docker Socket Fix
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo "🔧 Global Colima + Supabase Fix"
echo "==============================="

# Check if Colima is running
print_status "Checking Colima status..."
if ! colima status >/dev/null 2>&1; then
    print_status "Starting Colima..."
    colima start
fi

# Set Docker context
print_status "Setting Docker context..."
docker context use colima > /dev/null 2>&1

# Create symlink
COLIMA_SOCKET="$HOME/.colima/default/docker.sock"
STANDARD_SOCKET="/var/run/docker.sock"

if [ ! -S "$COLIMA_SOCKET" ]; then
    print_error "Colima Docker socket not found at $COLIMA_SOCKET"
    exit 1
fi

print_status "Creating Docker socket symlink..."
sudo mkdir -p /var/run
sudo rm -f "$STANDARD_SOCKET"
sudo ln -sf "$COLIMA_SOCKET" "$STANDARD_SOCKET"

print_success "Docker socket symlink created"
print_success "Colima + Supabase fix applied successfully"
echo ""
echo "You can now run: supabase-start"
EOF

    # Create the Supabase start wrapper
    print_status "Creating Supabase start wrapper..."
    sudo tee "$GLOBAL_SCRIPTS_DIR/supabase-start.sh" > /dev/null << 'EOF'
#!/bin/bash

# Global Supabase Start with Colima Support
set -e

echo "🚀 Starting Supabase with Colima..."

# Ensure Colima is running
if ! colima status >/dev/null 2>&1; then
    echo "Starting Colima..."
    colima start
fi

# Set environment
export DOCKER_HOST="unix:///var/run/docker.sock"
export DOCKER_CONTEXT="colima"
docker context use colima > /dev/null 2>&1

# Start Supabase
echo "Starting Supabase services..."
supabase start "$@"

echo ""
echo "✅ Supabase is running!"
echo "📊 Studio: http://localhost:54323"
echo "🔌 API: http://localhost:54321"
echo "🗄️  Database: postgresql://postgres:postgres@localhost:54322/postgres"
EOF

    # Create the test script
    print_status "Creating test script..."
    sudo tee "$GLOBAL_SCRIPTS_DIR/test-colima-supabase.sh" > /dev/null << 'EOF'
#!/bin/bash

# Global Colima + Supabase Test
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_test() { echo -e "${BLUE}[TEST]${NC} $1"; }
print_pass() { echo -e "${GREEN}[PASS]${NC} $1"; }
print_fail() { echo -e "${RED}[FAIL]${NC} $1"; }

echo "🧪 Testing Global Colima + Supabase Setup"
echo "=========================================="

TESTS_PASSED=0
TESTS_TOTAL=0

# Test Colima
print_test "Checking Colima status..."
TESTS_TOTAL=$((TESTS_TOTAL + 1))
if colima status 2>&1 | grep -q "running"; then
    print_pass "Colima is running"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    print_fail "Colima is not running"
fi

# Test Docker
print_test "Checking Docker connectivity..."
TESTS_TOTAL=$((TESTS_TOTAL + 1))
export DOCKER_HOST="unix:///var/run/docker.sock"
if docker version > /dev/null 2>&1; then
    print_pass "Docker is accessible"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    print_fail "Docker is not accessible"
fi

# Test symlink
print_test "Checking Docker socket symlink..."
TESTS_TOTAL=$((TESTS_TOTAL + 1))
if [ -L "/var/run/docker.sock" ]; then
    SYMLINK_TARGET=$(readlink "/var/run/docker.sock" 2>/dev/null || echo "unknown")
    if [[ "$SYMLINK_TARGET" == *".colima/default/docker.sock" ]]; then
        print_pass "Docker socket symlink is correct"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        print_fail "Docker socket symlink points to wrong location"
    fi
else
    print_fail "Docker socket symlink does not exist"
fi

echo ""
echo "Results: $TESTS_PASSED / $TESTS_TOTAL tests passed"
if [ $TESTS_PASSED -eq $TESTS_TOTAL ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
else
    echo -e "${RED}❌ Some tests failed. Run: colima-supabase-fix${NC}"
fi
EOF

    # Make scripts executable
    sudo chmod +x "$GLOBAL_SCRIPTS_DIR"/*.sh

    print_success "Global scripts created in $GLOBAL_SCRIPTS_DIR"
}

create_global_commands() {
    print_status "Creating global command wrappers..."

    # Create global command: colima-supabase-fix
    sudo tee "$GLOBAL_BIN_DIR/colima-supabase-fix" > /dev/null << EOF
#!/bin/bash
exec "$GLOBAL_SCRIPTS_DIR/fix-colima-supabase.sh" "\$@"
EOF

    # Create global command: supabase-start
    sudo tee "$GLOBAL_BIN_DIR/supabase-start" > /dev/null << EOF
#!/bin/bash
exec "$GLOBAL_SCRIPTS_DIR/supabase-start.sh" "\$@"
EOF

    # Create global command: test-colima-supabase
    sudo tee "$GLOBAL_BIN_DIR/test-colima-supabase" > /dev/null << EOF
#!/bin/bash
exec "$GLOBAL_SCRIPTS_DIR/test-colima-supabase.sh" "\$@"
EOF

    # Make commands executable
    sudo chmod +x "$GLOBAL_BIN_DIR/colima-supabase-fix"
    sudo chmod +x "$GLOBAL_BIN_DIR/supabase-start"
    sudo chmod +x "$GLOBAL_BIN_DIR/test-colima-supabase"

    print_success "Global commands created in $GLOBAL_BIN_DIR"
}

setup_shell_functions() {
    print_status "Setting up shell functions..."

    # Detect shell
    SHELL_PROFILE=""
    if [ -n "$ZSH_VERSION" ] && [ -f "$USER_HOME/.zshrc" ]; then
        SHELL_PROFILE="$USER_HOME/.zshrc"
    elif [ -n "$BASH_VERSION" ] && [ -f "$USER_HOME/.bashrc" ]; then
        SHELL_PROFILE="$USER_HOME/.bashrc"
    elif [ -f "$USER_HOME/.bash_profile" ]; then
        SHELL_PROFILE="$USER_HOME/.bash_profile"
    elif [ -f "$USER_HOME/.profile" ]; then
        SHELL_PROFILE="$USER_HOME/.profile"
    fi

    if [ -n "$SHELL_PROFILE" ]; then
        # Check if functions already exist
        if ! grep -q "# Colima Supabase Global Functions" "$SHELL_PROFILE" 2>/dev/null; then
            print_status "Adding shell functions to $SHELL_PROFILE..."

            cat >> "$SHELL_PROFILE" << 'EOF'

# Colima Supabase Global Functions
export DOCKER_HOST="unix:///var/run/docker.sock"
export DOCKER_CONTEXT="colima"

# Ensure Docker context is set when starting new shell
if command -v colima > /dev/null 2>&1 && colima status >/dev/null 2>&1; then
    docker context use colima > /dev/null 2>&1 || true
fi
EOF
            print_success "Shell functions added to $SHELL_PROFILE"
        else
            print_success "Shell functions already exist in $SHELL_PROFILE"
        fi
    else
        print_warning "Could not detect shell profile for persistent environment setup"
    fi
}

create_uninstaller() {
    print_status "Creating uninstaller script..."

    sudo tee "$GLOBAL_BIN_DIR/uninstall-colima-supabase-fix" > /dev/null << EOF
#!/bin/bash

echo "🗑️  Uninstalling Global Colima + Supabase Fix..."

# Remove global commands
sudo rm -f "$GLOBAL_BIN_DIR/colima-supabase-fix"
sudo rm -f "$GLOBAL_BIN_DIR/supabase-start"
sudo rm -f "$GLOBAL_BIN_DIR/test-colima-supabase"
sudo rm -f "$GLOBAL_BIN_DIR/uninstall-colima-supabase-fix"

# Remove scripts directory
sudo rm -rf "$GLOBAL_SCRIPTS_DIR"

# Remove Docker symlink
sudo rm -f "/var/run/docker.sock"

echo "✅ Global Colima + Supabase Fix uninstalled"
echo ""
echo "Note: Shell profile modifications were NOT removed."
echo "You may want to manually remove the 'Colima Supabase Global Functions'"
echo "section from your shell profile if no longer needed."
EOF

    sudo chmod +x "$GLOBAL_BIN_DIR/uninstall-colima-supabase-fix"
    print_success "Uninstaller created: uninstall-colima-supabase-fix"
}

run_initial_fix() {
    print_status "Running initial Colima + Supabase fix..."

    # Run the fix script
    "$GLOBAL_SCRIPTS_DIR/fix-colima-supabase.sh"

    print_success "Initial fix completed"
}

print_completion_message() {
    echo ""
    echo "🎉 Installation Complete!"
    echo "========================="
    echo ""
    echo "📋 Available Global Commands:"
    echo "  colima-supabase-fix      # Fix Docker socket issues"
    echo "  supabase-start           # Start Supabase with Colima"
    echo "  test-colima-supabase     # Test the setup"
    echo "  uninstall-colima-supabase-fix  # Remove installation"
    echo ""
    echo "🔧 Usage Examples:"
    echo "  # Fix Docker socket (run once or when issues occur)"
    echo "  colima-supabase-fix"
    echo ""
    echo "  # Start Supabase from any directory"
    echo "  cd /path/to/any/supabase-project"
    echo "  supabase-start"
    echo ""
    echo "  # Test if everything is working"
    echo "  test-colima-supabase"
    echo ""
    echo "🏠 Installation Locations:"
    echo "  Commands: $GLOBAL_BIN_DIR"
    echo "  Scripts:  $GLOBAL_SCRIPTS_DIR"
    echo ""
    print_warning "Restart your terminal or run 'source ~/.zshrc' (or ~/.bashrc) for shell functions"
    echo ""
    print_success "You can now use Supabase with Colima from anywhere on your system!"
}

# Main installation flow
main() {
    print_header

    print_status "This script will install Colima + Supabase fix globally on your system"
    print_warning "This installation requires sudo privileges"
    echo ""
    read -p "Continue with installation? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled"
        exit 0
    fi
    echo ""

    check_requirements
    create_global_scripts
    create_global_commands
    setup_shell_functions
    create_uninstaller
    run_initial_fix
    print_completion_message
}

# Run main function
main "$@"
