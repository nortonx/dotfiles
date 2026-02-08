#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/.dotfiles"

# ── Colors ──────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
RESET='\033[0m'

info()  { printf "${GREEN}[OK]${RESET}  %s\n" "$1"; }
warn()  { printf "${YELLOW}[!!]${RESET}  %s\n" "$1"; }
error() { printf "${RED}[ERR]${RESET} %s\n" "$1"; }

# ── Dependency check ───────────────────────────────────────────────
missing=()
for cmd in git zsh jq; do
  command -v "$cmd" &>/dev/null || missing+=("$cmd")
done
if [[ ${#missing[@]} -gt 0 ]]; then
  error "Missing dependencies: ${missing[*]}"
  echo "  Install them with your package manager and re-run this script."
  exit 1
fi

# ── Helper: create symlink with backup ─────────────────────────────
link() {
  local src="$1" dst="$2"

  # Already correctly linked
  if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
    info "Already linked: $dst"
    return
  fi

  # Back up existing file/directory (not a symlink pointing elsewhere)
  if [[ -e "$dst" || -L "$dst" ]]; then
    warn "Backing up $dst → ${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi

  # Ensure parent directory exists
  mkdir -p "$(dirname "$dst")"

  ln -s "$src" "$dst"
  info "Linked: $dst → $src"
}

# ── Shell configs (Linux only) ────────────────────────────────────
echo ""
echo "=== Shell configs ==="
link "$DOTFILES/shell/zshrc"      "$HOME/.zshrc"
link "$DOTFILES/shell/zpreztorc"  "$HOME/.zpreztorc"
link "$DOTFILES/shell/p10k.zsh"   "$HOME/.p10k.zsh"

# ── Git ────────────────────────────────────────────────────────────
echo ""
echo "=== Git config ==="
link "$DOTFILES/git/gitconfig"    "$HOME/.gitconfig"

# ── Wezterm ────────────────────────────────────────────────────────
echo ""
echo "=== Wezterm ==="
link "$DOTFILES/wezterm/wezterm.lua" "$HOME/.wezterm.lua"

# ── Claude Code ────────────────────────────────────────────────────
echo ""
echo "=== Claude Code ==="
mkdir -p "$HOME/.claude"

link "$DOTFILES/claude/commands"              "$HOME/.claude/commands"
link "$DOTFILES/claude/agents"                "$HOME/.claude/agents"
link "$DOTFILES/claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"

# Generate merged settings.json (base + linux overlay)
echo ""
echo "=== Generating Claude Code settings.json ==="
jq -s '.[0] * .[1]' \
  "$DOTFILES/claude/settings.json" \
  "$DOTFILES/claude/settings.linux.json" \
  > "$HOME/.claude/settings.json"
info "Generated: ~/.claude/settings.json"

# ── Zprezto ────────────────────────────────────────────────────────
echo ""
echo "=== Zprezto ==="
if [[ -d "$HOME/.zprezto" ]]; then
  info "Zprezto already installed"
else
  warn "Zprezto not found. Install it?"
  read -rp "  Clone zprezto into ~/.zprezto? [y/N] " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "$HOME/.zprezto"
    info "Zprezto installed"
  else
    warn "Skipped zprezto installation"
  fi
fi

echo ""
echo "=== Setup complete ==="
echo "  Run 'source ~/.zshrc' to reload your shell."
