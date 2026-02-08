# ssh
export SSH_KEY_PATH="~/.ssh/id_rsa"
export EDITOR="vim"
export VISUAL="$EDITOR"

alias reload="source ~/.zshrc"
alias zshconfig="zed ~/.zshrc"
alias utils_config="zed ~/.dotfiles/shell"
alias zprezto_config="zed ~/.zprezto"

alias cat="bat"

# eza alias
alias lss="eza --color=always --long --git --icons=always"

# zsh autosuggestions
if [[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
elif [[ "$(uname)" == "Darwin" ]] && command -v brew &>/dev/null; then
  source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# FZF
# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

# Zoxide
eval "$(zoxide init zsh)"
alias cd="z"

# Use fd instead of fzf
export FZF_DEFAULT_COMMAND="fd --hidden --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --exclude .git"

# Use fd for listing path candidates
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for details
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}


show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo ${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# video-to-audio conversion
convert_to_audio(){
  ffmpeg -i $1 -f mp3 -vn $1.mp3
}

# video (.mov) to .mp4 conversion
convert_mov_to_mp4(){
  ffmpeg -i $1 -vcodec h264 $1.mp4
}

# Define utils path
util_path=$HOME/.dotfiles/shell

source $util_path/git_functions.sh
