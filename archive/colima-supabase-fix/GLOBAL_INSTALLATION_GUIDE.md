# Global Colima + Supabase Fix Installation Guide

This guide provides multiple approaches to install the Colima + Supabase Docker socket fix system-wide, making it available for any Supabase project on your macOS system.

## 🎯 Problem Solved

When using Colima as a Docker Desktop alternative with Supabase CLI, you encounter:
```
failed to start docker container: Error response from daemon: error while creating mount source path '/Users/username/.colima/default/docker.sock': mkdir /Users/username/.colima/default/docker.sock: operation not supported
```

This global installation resolves this issue system-wide.

## 📋 Installation Options

Choose the approach that best fits your needs:

### Option 1: Full Global Installation (Recommended)

This installs global commands available from anywhere on your system.

```bash
# Run the global installer
./scripts/install-global-colima-fix.sh
```

**What it installs:**
- `colima-supabase-fix` - Fix Docker socket issues
- `supabase-start` - Start Supabase with Colima support
- `test-colima-supabase` - Test the setup
- `uninstall-colima-supabase-fix` - Remove installation

**Usage:**
```bash
# From any directory
colima-supabase-fix              # Fix Docker socket
cd /path/to/any/supabase-project
supabase-start                   # Start Supabase
test-colima-supabase            # Verify setup
```

### Option 2: Shell Functions (Lightweight)

Add functions to your shell profile for lighter installation.

```bash
# Add to ~/.zshrc or ~/.bashrc
source /path/to/scripts/colima-supabase-shell-functions.sh

# Or copy the content to your shell profile
cat scripts/colima-supabase-shell-functions.sh >> ~/.zshrc
```

**Functions available:**
- `colima-supabase-fix`
- `supabase-start`
- `supabase-stop`
- `test-colima-supabase`
- `colima-supabase-help`

### Option 3: Manual System Installation

For custom installation paths or advanced users.

#### 1. Copy scripts to system location
```bash
# Create system directory
sudo mkdir -p /usr/local/share/colima-supabase-fix

# Copy scripts
sudo cp scripts/fix-colima-supabase.sh /usr/local/share/colima-supabase-fix/
sudo cp scripts/start-supabase.sh /usr/local/share/colima-supabase-fix/
sudo cp scripts/test-colima-setup.sh /usr/local/share/colima-supabase-fix/

# Make executable
sudo chmod +x /usr/local/share/colima-supabase-fix/*.sh
```

#### 2. Create global commands
```bash
# Create symlinks in PATH
sudo ln -sf /usr/local/share/colima-supabase-fix/fix-colima-supabase.sh /usr/local/bin/colima-supabase-fix
sudo ln -sf /usr/local/share/colima-supabase-fix/start-supabase.sh /usr/local/bin/supabase-start
sudo ln -sf /usr/local/share/colima-supabase-fix/test-colima-setup.sh /usr/local/bin/test-colima-supabase
```

#### 3. Add to shell profile
```bash
# Add to ~/.zshrc or ~/.bashrc
echo 'export DOCKER_HOST="unix:///var/run/docker.sock"' >> ~/.zshrc
echo 'export DOCKER_CONTEXT="colima"' >> ~/.zshrc
source ~/.zshrc
```

### Option 4: Homebrew Formula (Advanced)

Create a custom Homebrew formula for easy distribution.

#### 1. Create formula directory
```bash
mkdir -p /usr/local/Homebrew/Library/Taps/local/homebrew-tools/Formula
```

#### 2. Create formula file
```ruby
# /usr/local/Homebrew/Library/Taps/local/homebrew-tools/Formula/colima-supabase-fix.rb
class CollimaSupabaseFix < Formula
  desc "Fix Docker socket issues when using Colima with Supabase"
  homepage "https://github.com/your-username/colima-supabase-fix"
  version "1.0.0"
  
  def install
    bin.install "fix-colima-supabase.sh" => "colima-supabase-fix"
    bin.install "start-supabase.sh" => "supabase-start"
    bin.install "test-colima-setup.sh" => "test-colima-supabase"
  end
end
```

#### 3. Install via Homebrew
```bash
brew install local/tools/colima-supabase-fix
```

## 🚀 Usage Examples

### Daily Workflow

1. **One-time setup** (or when issues occur):
   ```bash
   colima-supabase-fix
   ```

2. **Start Supabase in any project**:
   ```bash
   cd /path/to/my-supabase-project
   supabase-start
   ```

3. **Verify setup** (optional):
   ```bash
   test-colima-supabase
   ```

### Advanced Usage

**Start Supabase with debug output:**
```bash
supabase-start --debug
```

**Start specific services only:**
```bash
supabase-start --ignore-health-check
```

**Stop Supabase:**
```bash
supabase stop --no-backup
```

## 🔧 Global Commands Reference

### `colima-supabase-fix`
Fixes the Docker socket mounting issue between Colima and Supabase.

```bash
colima-supabase-fix
```

**What it does:**
- Starts Colima if not running
- Sets correct Docker context
- Creates symlink from `/var/run/docker.sock` to Colima's socket
- Configures environment variables

### `supabase-start`
Starts Supabase with proper Colima configuration.

```bash
supabase-start [options]
```

**Features:**
- Auto-starts Colima if needed
- Sets proper Docker environment
- Shows service URLs when successful
- Passes through all Supabase CLI options

### `test-colima-supabase`
Verifies that the Colima + Supabase setup is working correctly.

```bash
test-colima-supabase
```

**Tests performed:**
- Colima status check
- Docker connectivity
- Socket symlink verification
- Supabase CLI availability

### `uninstall-colima-supabase-fix`
Removes the global installation (Option 1 only).

```bash
uninstall-colima-supabase-fix
```

## 🏠 Installation Locations

### Option 1 (Full Installation)
- **Commands**: `/usr/local/bin/`
- **Scripts**: `/usr/local/share/colima-supabase-fix/`
- **Shell**: Environment variables in `~/.zshrc` or `~/.bashrc`

### Option 2 (Shell Functions)
- **Functions**: Loaded in shell session
- **Shell**: Functions defined in `~/.zshrc` or `~/.bashrc`

## 🧪 Verification

After installation, verify everything works:

```bash
# Test the setup
test-colima-supabase

# Should output:
# ✅ All tests passed! Setup is working correctly.
```

Test with a real Supabase project:

```bash
cd /path/to/any/supabase-project
supabase-start
# Should start without Docker socket errors
```

## 🔄 Maintenance

### Updating

**Option 1 (Full Installation):**
```bash
# Re-run installer to update
./scripts/install-global-colima-fix.sh
```

**Option 2 (Shell Functions):**
```bash
# Re-source the updated functions
source /path/to/scripts/colima-supabase-shell-functions.sh
```

### Troubleshooting

**If commands are not found:**
```bash
# Check PATH
echo $PATH | grep -o '/usr/local/bin'

# Reload shell
source ~/.zshrc  # or ~/.bashrc
```

**If Docker socket issues persist:**
```bash
# Re-run the fix
colima-supabase-fix

# Check Colima status
colima status

# Restart Colima if needed
colima restart
```

**If Supabase still fails to start:**
```bash
# Check Docker connectivity
docker version

# Verify environment
echo $DOCKER_HOST
echo $DOCKER_CONTEXT

# Test Docker with Colima
docker run --rm hello-world
```

## 🗑️ Uninstallation

### Option 1 (Full Installation)
```bash
uninstall-colima-supabase-fix
```

### Option 2 (Shell Functions)
Remove or comment out the `source` line from your shell profile:
```bash
# ~/.zshrc or ~/.bashrc
# source /path/to/scripts/colima-supabase-shell-functions.sh
```

### Option 3 (Manual)
```bash
# Remove commands
sudo rm -f /usr/local/bin/colima-supabase-fix
sudo rm -f /usr/local/bin/supabase-start
sudo rm -f /usr/local/bin/test-colima-supabase

# Remove scripts directory
sudo rm -rf /usr/local/share/colima-supabase-fix

# Remove Docker symlink
sudo rm -f /var/run/docker.sock
```

### Option 4 (Homebrew)
```bash
brew uninstall colima-supabase-fix
```

## 📚 Additional Resources

- **Project Documentation**: `COLIMA_SUPABASE_SETUP.md`
- **Troubleshooting**: `README_COLIMA_FIX.md`
- **Development Guide**: `CLAUDE.md`

## 🤝 Contributing

To improve the global installation:

1. Test on different macOS versions
2. Add support for other shells (fish, etc.)
3. Create Windows/Linux compatibility
4. Add auto-update functionality
5. Create proper Homebrew formula

## ⚡ Quick Start

**TL;DR - Just want it to work?**

```bash
# Install globally (recommended)
./scripts/install-global-colima-fix.sh

# Use anywhere
cd /any/supabase/project
supabase-start
```

That's it! Your Colima + Supabase setup now works system-wide. 🎉