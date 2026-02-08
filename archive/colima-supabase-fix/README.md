# 🔧 Colima + Supabase Docker Socket Fix

## Problem Solved ✅

This repository contains a complete solution for resolving the Docker socket mounting issue when using **Colima** as a Docker Desktop alternative with **Supabase CLI**.

### Original Error
```
failed to start docker container: Error response from daemon: error while creating mount source path '/Users/norton/.colima/default/docker.sock': mkdir /Users/norton/.colima/default/docker.sock: operation not supported
```

## 🚀 Quick Solution

### One-Command Fix
```bash
./scripts/fix-colima-supabase.sh
```

### Manual Start Supabase
```bash
./scripts/start-supabase.sh
```

## 🔍 What The Solution Does

1. **Creates Docker Socket Symlink**: Links `/var/run/docker.sock` → `~/.colima/default/docker.sock`
2. **Sets Correct Environment**: Configures `DOCKER_HOST="unix:///var/run/docker.sock"`
3. **Configures Docker Context**: Ensures Docker uses the `colima` context
4. **Persistent Shell Setup**: Adds environment variables to your shell profile
5. **Helper Scripts**: Provides convenient startup scripts

## 📁 Files Created

```
fintrack-backend/scripts/
├── fix-colima-supabase.sh        # Main setup script
├── start-supabase.sh             # Helper to start Supabase
├── test-colima-setup.sh          # Test script to verify setup
├── COLIMA_SUPABASE_SETUP.md      # Detailed documentation
└── README_COLIMA_FIX.md          # This file
```

## 🎯 Step-by-Step What Happens

### The Problem
- **Supabase CLI** expects Docker at `/var/run/docker.sock`
- **Colima** creates Docker socket at `~/.colima/default/docker.sock`
- **Result**: Supabase tries to mount the Colima path as a directory (fails)

### The Solution
1. **Symlink Creation**: `sudo ln -sf ~/.colima/default/docker.sock /var/run/docker.sock`
2. **Environment Setup**: `export DOCKER_HOST="unix:///var/run/docker.sock"`
3. **Context Configuration**: `docker context use colima`

## 🔧 Usage Options

### Option 1: Automated (Recommended)
```bash
# Run once to set up everything
./scripts/fix-colima-supabase.sh

# Start Supabase anytime
./scripts/start-supabase.sh
```

### Option 2: Manual
```bash
# Set environment (each terminal session)
export DOCKER_HOST="unix:///var/run/docker.sock"

# Start Supabase
supabase start
```

## ✅ Verification

Run the test script to verify everything works:
```bash
./scripts/test-colima-setup.sh
```

Expected output:
```
✅ All tests passed! Your Colima + Supabase setup is working correctly.
```

## 🌐 Service URLs

Once Supabase is running:
- **Studio**: http://localhost:54323
- **API**: http://localhost:54321  
- **Database**: postgresql://postgres:postgres@localhost:54322/postgres
- **Email Testing**: http://localhost:54324

## 🛠️ Troubleshooting

### Common Issues

**"Permission denied" during setup**
- The script needs `sudo` for creating symlinks in `/var/run/`
- This is normal and required

**"Colima not running"**
```bash
colima start
```

**Environment variables not persisting**
```bash
source ~/.bashrc  # or ~/.zshrc
```

**Supabase won't start**
```bash
supabase stop --no-backup
./scripts/start-supabase.sh
```

### Reset Everything
```bash
colima stop
colima delete
colima start
./scripts/fix-colima-supabase.sh
```

## 💡 Why This Works

The key insight is that Supabase CLI works fine with Docker sockets, but it needs to find the socket at the **standard location** (`/var/run/docker.sock`). By creating a symlink from the standard location to Colima's socket, we maintain compatibility without modifying Supabase's expectations.

## 🔄 Environment Details

**Tested with:**
- macOS (Intel & Apple Silicon)
- Colima with Docker runtime
- Supabase CLI 2.34.3+
- Zsh & Bash shells

## 📚 Additional Documentation

For detailed documentation and advanced troubleshooting:
- See `scripts/COLIMA_SUPABASE_SETUP.md`

## 🎉 Success Criteria

After running the fix, you should be able to:
- ✅ Run `supabase start` without errors
- ✅ Access Supabase Studio at http://localhost:54323
- ✅ Connect to the database
- ✅ Use all Supabase services normally

---

**Status**: ✅ **SOLUTION WORKING**

This fix has been tested and confirmed to resolve the Colima + Supabase Docker socket issue completely.