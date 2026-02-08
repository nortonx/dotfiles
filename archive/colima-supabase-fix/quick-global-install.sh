#!/bin/bash

# Quick Global Colima + Supabase Fix Installer
# One-liner: curl -sSL <this-script-url> | bash

set -e

echo "🌍 Quick Global Colima + Supabase Fix Installer"
echo "==============================================="
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ This script is designed for macOS only${NC}"
    exit 1
fi

# Check requirements
echo -e "${BLUE}📋 Checking requirements...${NC}"

if ! command -v colima > /dev/null 2>&1; then
    echo -e "${RED}❌ Colima not found. Install with: brew install colima${NC}"
    exit 1
fi

if ! command -v supabase > /dev/null 2>&1; then
    echo -e "${RED}❌ Supabase CLI not found. Install with: brew install supabase/tap/supabase${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Requirements satisfied${NC}"

# Create global fix command
echo -e "${BLUE}📦 Installing global commands...${NC}"

sudo tee /usr/local/bin/colima-supabase-fix > /dev/null << 'EOF'
#!/bin/bash
# Global Colima + Supabase Fix
set -e

echo "🔧 Fixing Colima + Supabase Docker socket..."

# Start Colima if not running
if ! colima status >/dev/null 2>&1; then
    echo "Starting Colima..."
    colima start
fi

# Set Docker context
docker context use colima > /dev/null 2>&1

# Create symlink
COLIMA_SOCKET="$HOME/.colima/default/docker.sock"
STANDARD_SOCKET="/var/run/docker.sock"

if [ ! -S "$COLIMA_SOCKET" ]; then
    echo "❌ Colima Docker socket not found"
    exit 1
fi

echo "Creating Docker socket symlink..."
sudo mkdir -p /var/run
sudo rm -f "$STANDARD_SOCKET"
sudo ln -sf "$COLIMA_SOCKET" "$STANDARD_SOCKET"

echo "✅ Fix applied successfully"
EOF

# Create global supabase-start command
sudo tee /usr/local/bin/supabase-start > /dev/null << 'EOF'
#!/bin/bash
# Global Supabase Start with Colima
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
supabase start "$@"

echo ""
echo "✅ Supabase is running!"
echo "📊 Studio: http://localhost:54323"
echo "🔌 API: http://localhost:54321"
EOF

# Make executable
sudo chmod +x /usr/local/bin/colima-supabase-fix
sudo chmod +x /usr/local/bin/supabase-start

# Add to shell profile
SHELL_PROFILE=""
if [ -n "$ZSH_VERSION" ] || [ "$SHELL" = "/bin/zsh" ]; then
    SHELL_PROFILE="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ] || [ "$SHELL" = "/bin/bash" ]; then
    SHELL_PROFILE="$HOME/.bashrc"
fi

if [ -n "$SHELL_PROFILE" ] && [ -f "$SHELL_PROFILE" ]; then
    if ! grep -q "DOCKER_HOST.*var/run/docker.sock" "$SHELL_PROFILE" 2>/dev/null; then
        echo -e "${BLUE}📝 Adding environment to $SHELL_PROFILE...${NC}"
        cat >> "$SHELL_PROFILE" << 'EOF'

# Colima + Supabase Global Fix
export DOCKER_HOST="unix:///var/run/docker.sock"
export DOCKER_CONTEXT="colima"
EOF
    fi
fi

# Run initial fix
echo -e "${BLUE}🔧 Running initial fix...${NC}"
/usr/local/bin/colima-supabase-fix

echo ""
echo -e "${GREEN}🎉 Installation Complete!${NC}"
echo ""
echo "📋 Available commands:"
echo "  colima-supabase-fix  # Fix Docker socket issues"
echo "  supabase-start       # Start Supabase with Colima"
echo ""
echo "🚀 Usage:"
echo "  cd /path/to/any/supabase-project"
echo "  supabase-start"
echo ""
echo -e "${YELLOW}⚠️  Restart your terminal for environment changes${NC}"
echo ""
echo -e "${GREEN}✅ You can now use Supabase with Colima from anywhere!${NC}"
