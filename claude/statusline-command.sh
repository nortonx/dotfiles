#!/bin/bash

# P10k-Inspired StatusLine script for Claude Code
# Displays: directory path, git branch + status, and context window usage
# Uses colored text (no backgrounds) inspired by Powerlevel10k

# Ensure jq is in PATH (may be in /usr/sbin on some systems)
export PATH="/usr/sbin:/usr/bin:/bin:$PATH"

# ANSI color codes (text colors only) - using $'...' for proper escape interpretation
BLUE=$'\033[94m'
CYAN=$'\033[36m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
DIM=$'\033[2m'
RESET=$'\033[0m'

# Read JSON input from Claude Code
input=$(cat)

# Extract values using jq
cwd=$(echo "$input" | jq -r '.cwd // ""')

# Get shortened directory path (replace home with ~)
display_path="${cwd/#$HOME/\~}"

# Get git branch and detailed status (using --no-optional-locks to avoid locking issues)
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || echo "detached")

  # Get ahead/behind counts
  ahead_behind=$(git -C "$cwd" --no-optional-locks rev-list --left-right --count HEAD...@{upstream} 2>/dev/null || echo "0	0")
  ahead=$(echo "$ahead_behind" | cut -f1)
  behind=$(echo "$ahead_behind" | cut -f2)

  # Get staged, unstaged, and untracked counts
  staged=$(git -C "$cwd" --no-optional-locks diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
  unstaged=$(git -C "$cwd" --no-optional-locks diff --numstat 2>/dev/null | wc -l | tr -d ' ')
  untracked=$(git -C "$cwd" --no-optional-locks ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')

  # Build git status string with p10k-style indicators
  git_status=""
  [ "$ahead" -gt 0 ] && git_status="${git_status}⇡${ahead}"
  [ "$behind" -gt 0 ] && git_status="${git_status}⇣${behind}"
  [ "$staged" -gt 0 ] && git_status="${git_status}+${staged}"
  [ "$unstaged" -gt 0 ] && git_status="${git_status}!${unstaged}"
  [ "$untracked" -gt 0 ] && git_status="${git_status}?${untracked}"

  # Determine color based on repo state
  if [ -z "$git_status" ]; then
    git_color="$GREEN"
  else
    git_color="$YELLOW"
  fi

  # Format: " branch status" with appropriate color
  if [ -n "$git_status" ]; then
    git_segment=" ${DIM}|${RESET} ${git_color} ${branch} ${git_status}${RESET}"
  else
    git_segment=" ${DIM}|${RESET} ${git_color} ${branch}${RESET}"
  fi
else
  git_segment=""
fi

# Calculate context window usage percentage with color coding
usage=$(echo "$input" | jq '.context_window.current_usage')
if [ "$usage" != "null" ] && [ -n "$usage" ]; then
  # Sum input tokens + cache creation tokens + cache read tokens
  current=$(echo "$usage" | jq '.input_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
  size=$(echo "$input" | jq '.context_window.context_window_size')

  if [ "$current" != "null" ] && [ "$size" != "null" ] && [ "$size" -gt 0 ]; then
    pct=$((current * 100 / size))

    # Format token counts (K for thousands)
    if [ "$current" -ge 1000 ]; then
      current_display="$((current / 1000))K"
    else
      current_display="$current"
    fi
    if [ "$size" -ge 1000 ]; then
      size_display="$((size / 1000))K"
    else
      size_display="$size"
    fi

    # Color based on usage percentage
    if [ "$pct" -lt 50 ]; then
      context_color="$GREEN"
    elif [ "$pct" -lt 75 ]; then
      context_color="$YELLOW"
    else
      context_color="$RED"
    fi

    context_segment=" ${DIM}|${RESET} ${context_color}${current_display}/${size_display} (${pct}%)${RESET}"
  else
    context_segment=""
  fi
else
  context_segment=""
fi

# Output the statusLine: directory | git | context (all colored)
printf "${BLUE} %s${RESET}%s%s" "$display_path" "$git_segment" "$context_segment"
