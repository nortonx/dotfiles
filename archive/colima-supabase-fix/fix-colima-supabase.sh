#!/bin/bash

# Fix Colima + Supabase Docker Socket Issue
# This script resolves the Docker socket mounting issue when using Colima with Supabase CLI

set -e  # Exit on any error

echo "🔧 Starting Colima + Supabase Docker Socket Fix..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Step 1: Check if Colima is running
print_status "Checking Colima status..."
colima_status=$(colima status 2>&1 || echo "not running")
if [[ $colima_status != *"running"* ]]; then
    print_error "Colima is not running. Starting Colima..."
    colima start
    sleep 5
    colima_status=$(colima status 2>&1 || echo "not running")
elif [[ $colima_status == *"already running"* ]]; then
    print_success "Colima is already running"
fi

if [[ $colima_status == *"running"* ]]; then
    print_success "Colima is running"
else
    print_error "Failed to start Colima. Please check your Colima installation."
    exit 1
fi

# Step 2: Check current Docker context
print_status "Checking Docker context..."
current_context=$(docker context show)
if [ "$current_context" != "colima" ]; then
    print_warning "Docker context is '$current_context', switching to 'colima'..."
    docker context use colima
    print_success "Switched to Colima Docker context"
else
    print_success "Already using Colima Docker context"
fi

# Step 3: Set up Docker socket symlink for Supabase compatibility
print_status "Setting up Docker socket compatibility..."

COLIMA_SOCKET="$HOME/.colima/default/docker.sock"
STANDARD_SOCKET="/var/run/docker.sock"

# Check if Colima socket exists
if [ ! -S "$COLIMA_SOCKET" ]; then
    print_error "Colima Docker socket not found at $COLIMA_SOCKET"
    print_error "Please ensure Colima is properly started"
    exit 1
fi

# Create /var/run directory if it doesn't exist (macOS might not have it)
if [ ! -d "/var/run" ]; then
    print_status "Creating /var/run directory..."
    sudo mkdir -p /var/run
fi

# Remove existing symlink or socket if it exists
if [ -e "$STANDARD_SOCKET" ] || [ -L "$STANDARD_SOCKET" ]; then
    print_status "Removing existing Docker socket at $STANDARD_SOCKET..."
    sudo rm -f "$STANDARD_SOCKET"
fi

# Create symlink from standard location to Colima socket
print_status "Creating symlink from $STANDARD_SOCKET to $COLIMA_SOCKET..."
sudo ln -sf "$COLIMA_SOCKET" "$STANDARD_SOCKET"
print_success "Docker socket symlink created"

# Step 4: Set environment variables
print_status "Setting up environment variables..."

# Export for current session (use symlink instead of direct socket)
export DOCKER_HOST="unix:///var/run/docker.sock"
export DOCKER_CONTEXT="colima"

print_success "Environment variables set for current session"

# Step 5: Verify Docker is working
print_status "Verifying Docker connectivity..."
if docker version > /dev/null 2>&1; then
    print_success "Docker is accessible and working"
else
    print_error "Docker is not responding. Please check your setup."
    exit 1
fi

# Step 6: Stop any running Supabase services
print_status "Stopping any running Supabase services..."
if command -v supabase > /dev/null 2>&1; then
    supabase stop --no-backup > /dev/null 2>&1 || true
    print_success "Supabase services stopped"
else
    print_warning "Supabase CLI not found. Please install it first."
    echo "Install with: brew install supabase/tap/supabase"
fi

# Step 7: Create or update shell profile with persistent environment variables
print_status "Setting up persistent environment variables..."

SHELL_PROFILE=""
if [ -n "$ZSH_VERSION" ] && [ -f "$HOME/.zshrc" ]; then
    SHELL_PROFILE="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
    SHELL_PROFILE="$HOME/.bashrc"
elif [ -f "$HOME/.bash_profile" ]; then
    SHELL_PROFILE="$HOME/.bash_profile"
elif [ -f "$HOME/.profile" ]; then
    SHELL_PROFILE="$HOME/.profile"
fi

if [ -n "$SHELL_PROFILE" ]; then
    # Remove any existing DOCKER_HOST exports to avoid duplicates
    if grep -q "export DOCKER_HOST.*colima" "$SHELL_PROFILE" 2>/dev/null; then
        print_status "Colima DOCKER_HOST already set in $SHELL_PROFILE"
    else
        print_status "Adding DOCKER_HOST to $SHELL_PROFILE..."
        echo "" >> "$SHELL_PROFILE"
        echo "# Colima Docker Socket (for Supabase compatibility)" >> "$SHELL_PROFILE"
        echo "export DOCKER_HOST=\"unix:///var/run/docker.sock\"" >> "$SHELL_PROFILE"
        echo "export DOCKER_CONTEXT=\"colima\"" >> "$SHELL_PROFILE"
        print_success "Environment variables added to $SHELL_PROFILE"
    fi
fi

# Step 8: Create a helper script for starting Supabase
print_status "Creating Supabase startup helper script..."
cat > "$(dirname "$0")/start-supabase.sh" << 'EOF'
#!/bin/bash

# Supabase Startup Helper for Colima
# This script ensures proper environment before starting Supabase

set -e

echo "🚀 Starting Supabase with Colima..."

# Ensure Colima is running
colima_check=$(colima status 2>&1 || echo "not running")
if [[ $colima_check != *"running"* ]]; then
    echo "Starting Colima..."
    colima start
fi

# Set Docker context
docker context use colima > /dev/null 2>&1

# Set environment variables
export DOCKER_HOST="unix:///var/run/docker.sock"
export DOCKER_CONTEXT="colima"

# Start Supabase
echo "Starting Supabase services..."
supabase start "$@"

echo "✅ Supabase is now running!"
echo "📊 Studio URL: http://localhost:54323"
echo "🗄️  Database URL: postgresql://postgres:postgres@localhost:54322/postgres"
echo "🔌 API URL: http://localhost:54321"
EOF

chmod +x "$(dirname "$0")/start-supabase.sh"
print_success "Created start-supabase.sh helper script"

# Step 9: Final verification and instructions
echo ""
echo "🎉 Setup Complete!"
echo ""
print_success "Colima + Supabase compatibility has been configured"
echo ""
echo "📝 Next Steps:"
echo "   1. Restart your terminal or run: source $SHELL_PROFILE"
echo "   2. Start Supabase using one of these methods:"
echo ""
echo "      Option A - Use the helper script:"
echo "      ./scripts/start-supabase.sh"
echo ""
echo "      Option B - Manual start:"
echo "      export DOCKER_HOST=\"unix:///var/run/docker.sock\""
echo "      supabase start"
echo ""
echo "🔧 If you encounter issues:"
echo "   • Restart Colima: colima restart"
echo "   • Check Docker: docker ps"
echo "   • Re-run this script: ./scripts/fix-colima-supabase.sh"
echo ""
print_warning "Note: You may need to restart your terminal for all changes to take effect."
