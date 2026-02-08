# Colima + Supabase Setup Guide

This guide provides a comprehensive solution for resolving Docker socket issues when using Colima as a Docker Desktop alternative with Supabase CLI.

## Problem Description

When using Colima with Supabase CLI, you may encounter this error:

```
failed to start docker container: Error response from daemon: error while creating mount source path '/Users/norton/.colima/default/docker.sock': mkdir /Users/norton/.colima/default/docker.sock: operation not supported
```

## Root Cause

The issue occurs because:
- **Supabase CLI** expects Docker at the standard location (`/var/run/docker.sock`)
- **Colima** creates its socket at `~/.colima/default/docker.sock`
- **Mount conflict**: Supabase tries to mount the Colima socket path as a directory instead of recognizing it as a socket file

## Solution Overview

Our solution involves:
1. Creating a symlink from standard Docker socket location to Colima's socket
2. Setting proper environment variables
3. Configuring persistent shell environment
4. Creating helper scripts for easy startup

## Quick Fix

### Automated Setup (Recommended)

Run the automated fix script:

```bash
./scripts/fix-colima-supabase.sh
```

This script will:
- ✅ Verify Colima is running
- ✅ Set correct Docker context
- ✅ Create necessary symlinks
- ✅ Configure environment variables
- ✅ Create helper scripts
- ✅ Set up persistent configuration

### Manual Setup

If you prefer manual setup or need to troubleshoot:

1. **Ensure Colima is running:**
   ```bash
   colima start
   colima status
   ```

2. **Set Docker context:**
   ```bash
   docker context use colima
   ```

3. **Create symlink (requires sudo):**
   ```bash
   sudo mkdir -p /var/run
   sudo ln -sf "$HOME/.colima/default/docker.sock" /var/run/docker.sock
   ```

4. **Set environment variables:**
   ```bash
   export DOCKER_HOST="unix:///var/run/docker.sock"
   export DOCKER_CONTEXT="colima"
   ```

5. **Add to shell profile (choose your shell):**
   
   **For Zsh (.zshrc):**
   ```bash
   echo 'export DOCKER_HOST="unix:///var/run/docker.sock"' >> ~/.zshrc
   echo 'export DOCKER_CONTEXT="colima"' >> ~/.zshrc
   source ~/.zshrc
   ```
   
   **For Bash (.bashrc or .bash_profile):**
   ```bash
   echo 'export DOCKER_HOST="unix:///var/run/docker.sock"' >> ~/.bashrc
   echo 'export DOCKER_CONTEXT="colima"' >> ~/.bashrc
   source ~/.bashrc
   ```

## Usage

### Option 1: Using Helper Script (Recommended)

After running the fix script, use the generated helper:

```bash
./scripts/start-supabase.sh
```

This automatically:
- Ensures Colima is running
- Sets proper environment
- Starts Supabase with correct configuration

### Option 2: Manual Start

Set environment and start manually:

```bash
export DOCKER_HOST="unix:///var/run/docker.sock"
supabase start --debug
```

## Verification

After setup, verify everything is working:

```bash
# Check Docker connectivity
docker ps

# Check Colima status
colima status

# Check Docker context
docker context show
# Should output: colima

# Check environment variable
echo $DOCKER_HOST
# Should output: unix:///var/run/docker.sock

# Start Supabase
supabase start
```

## Service URLs

Once Supabase is running, you can access:

- **Supabase Studio**: http://localhost:54323
- **API Server**: http://localhost:54321
- **Database**: postgresql://postgres:postgres@localhost:54322/postgres
- **Inbucket (Email testing)**: http://localhost:54324

## Troubleshooting

### Common Issues

1. **"Colima is not running"**
   ```bash
   colima start
   ```

2. **"Permission denied" for symlink creation**
   - The script requires `sudo` for creating symlinks in `/var/run`
   - This is normal and necessary

3. **"Docker context not found"**
   ```bash
   colima start
   docker context use colima
   ```

4. **Environment variables not persisting**
   - Restart your terminal
   - Or manually source your profile: `source ~/.zshrc` (or `~/.bashrc`)

5. **Supabase services won't start**
   ```bash
   # Stop all services and restart
   supabase stop --no-backup
   export DOCKER_HOST="unix:///var/run/docker.sock"
   supabase start
   ```

### Advanced Troubleshooting

**Check socket permissions:**
```bash
ls -la ~/.colima/default/docker.sock
ls -la /var/run/docker.sock
```

**Verify Docker daemon:**
```bash
docker version
docker info
```

**Debug Supabase startup:**
```bash
supabase start --debug
```

**Reset Colima (if needed):**
```bash
colima stop
colima delete
colima start
# Then re-run the fix script
```

## File Structure

After running the setup, you'll have:

```
fintrack-backend/
├── scripts/
│   ├── fix-colima-supabase.sh      # Main fix script
│   ├── start-supabase.sh           # Helper startup script
│   └── COLIMA_SUPABASE_SETUP.md    # This documentation
```

## Environment Details

This setup has been tested with:
- **macOS** (Intel and Apple Silicon)
- **Colima** with Docker runtime
- **Supabase CLI** latest version
- **Shells**: Zsh, Bash

## Alternative Solutions

If this solution doesn't work for your setup:

1. **Use Docker Desktop**: Switch back to Docker Desktop temporarily
2. **Lima + Docker**: Try Lima instead of Colima
3. **Podman**: Use Podman as Docker alternative
4. **Remote Docker**: Use Docker on a remote machine or VM

## Contributing

If you encounter issues or have improvements:
1. Check existing troubleshooting steps
2. Document your specific error and environment
3. Test the fix before sharing
4. Update this documentation with new findings

## References

- [Colima Documentation](https://github.com/abiosoft/colima)
- [Supabase CLI Documentation](https://supabase.com/docs/guides/cli)
- [Docker Context Documentation](https://docs.docker.com/engine/context/working-with-contexts/)