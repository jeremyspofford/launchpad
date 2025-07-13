# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# Editor configuration
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi
export VISUAL="$EDITOR"

# Browser configuration
if [[ "$OSTYPE" == "darwin"* ]]; then
    export BROWSER="open"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    export BROWSER="xdg-open"
fi

# Development directories
export DEV_DIR="$HOME/Development"
export PROJECT_DIR="$DEV_DIR"
export WORKSPACE_DIR="$DEV_DIR"

# Tool-specific configuration directories
export MISE_CONFIG_DIR="$XDG_CONFIG_HOME/mise"
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
export FABRIC_CONFIG_DIR="$XDG_CONFIG_HOME/fabric"

# Language-specific environment variables
export PYTHONPATH="$HOME/.local/lib/python3/site-packages:$PYTHONPATH"
export PIP_USER=1
export PIPENV_VENV_IN_PROJECT=1
export POETRY_VENV_IN_PROJECT=true

# Node.js and npm
export NPM_CONFIG_PREFIX="$HOME/.local"
export NODE_REPL_HISTORY="$XDG_DATA_HOME/node_repl_history"

# Go
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"

# Rust
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"

# Docker
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export COMPOSE_FILE="docker-compose.yml"

# SSH
export SSH_KEY_PATH="$HOME/.ssh/personal_id_ed25519"

# History configuration
export HISTFILE="$XDG_DATA_HOME/zsh/history"
export HISTSIZE=50000
export SAVEHIST=50000
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.

# Less settings
export LESS="-R"
export LESSHISTFILE="$XDG_DATA_HOME/less/history"

# Man pages with bat
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# FZF settings
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --multi --cycle'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS='--preview "bat --color=always --style=numbers --line-range=:500 {}"'
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_ALT_C_OPTS='--preview "tree -C {} | head -200"'

# Bat (better cat) settings
export BAT_THEME="GitHub"
export BAT_CONFIG_PATH="$XDG_CONFIG_HOME/bat/config"

# Zoxide settings
export _ZO_DATA_DIR="$XDG_DATA_HOME/zoxide"

# Performance and behavior
export DISABLE_AUTO_TITLE="true"
export ENABLE_CORRECTION="false"
export COMPLETION_WAITING_DOTS="true"

# Security
export GPG_TTY=$(tty)

# Locale settings
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

# Pager settings
export PAGER="less"
if command -v bat >/dev/null; then
    export PAGER="bat"
fi

# Platform-specific environment variables
case "$OSTYPE" in
    darwin*)
        # macOS specific
        export HOMEBREW_NO_ANALYTICS=1
        export HOMEBREW_NO_AUTO_UPDATE=1
        ;;
    linux-gnu*)
        # Linux specific
        export DISPLAY=":0"
        ;;
    msys|cygwin)
        # Windows specific
        export WSLENV="USERPROFILE/p:APPDATA/p"
        ;;
esac

# Zsh options for better experience
setopt AUTO_CD                   # cd into directories without typing cd
setopt GLOB_DOTS                 # Include hidden files in glob patterns
setopt NO_BEEP                   # Disable beeping
setopt CORRECT                   # Auto correct commands

# Source additional environment variables if they exist
if [[ -f ~/.zshenv ]]; then
  source ~/.zshenv
fi

# Mise activation
if command -v mise >/dev/null; then
    eval "$(mise activate zsh)"
elif [[ -f ~/.local/bin/mise ]]; then
    eval "$(~/.local/bin/mise activate zsh)"
fi 