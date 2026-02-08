# dotfiles

Unified dotfiles for **Ubuntu**, **Fedora Linux**, and **native Windows**.

## What's included

| Directory | Description | Platforms |
|-----------|-------------|-----------|
| `shell/` | Zsh config, Prezto, Powerlevel10k, aliases, fzf, zoxide | Linux |
| `claude/` | Claude Code commands, agents, settings, statusline | All |
| `git/` | Git config with aliases and credential helpers | Linux |
| `wezterm/` | WezTerm terminal emulator config | Linux |
| `archive/` | Old company scripts (never symlinked) | — |

## Setup

### Linux (Ubuntu / Fedora)

```bash
git clone https://github.com/nortonx/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup.sh
source ~/.zshrc
```

**What it does:**
- Symlinks shell configs (`~/.zshrc`, `~/.zpreztorc`, `~/.p10k.zsh`)
- Symlinks `~/.gitconfig` and `~/.wezterm.lua`
- Symlinks Claude Code `commands/`, `agents/`, and `statusline-command.sh` into `~/.claude/`
- Generates `~/.claude/settings.json` by merging `settings.json` + `settings.linux.json` via `jq`
- Backs up any existing files to `.bak` before overwriting
- Optionally installs [Zprezto](https://github.com/sorin-ionescu/prezto) if missing

**Dependencies:** `git`, `zsh`, `jq`

**Recommended:** `fzf`, `fd`, `eza`, `bat`, `zoxide`, `mise`

### Windows

```powershell
git clone https://github.com/nortonx/dotfiles.git "$env:USERPROFILE\.dotfiles"
cd "$env:USERPROFILE\.dotfiles"
.\setup.ps1
```

**What it does:**
- Creates directory junctions for Claude Code `commands/` and `agents/` into `%USERPROFILE%\.claude\`
- Generates `%USERPROFILE%\.claude\settings.json` by merging `settings.json` + `settings.windows.json`
- No shell configs, no statusline — Claude Code only

No admin rights required (uses `mklink /J` for junctions).

## Settings split

Claude Code settings are split into three files:

| File | Contents |
|------|----------|
| `claude/settings.json` | Base config shared across all platforms |
| `claude/settings.linux.json` | Linux overlay: statusLine + mcpServers |
| `claude/settings.windows.json` | Windows overlay: mcpServers |

The setup scripts merge base + overlay into `~/.claude/settings.json` at install time. Edit the source files in this repo, then re-run the setup script to regenerate.

## Updating

After pulling new changes:

```bash
# Linux — re-run to pick up any new symlinks or regenerate settings
./setup.sh

# Windows
.\setup.ps1
```

Symlinks that already point to the correct target are skipped automatically.
