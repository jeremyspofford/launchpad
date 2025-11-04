# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

plugins=(
    vi-mode
    # git
    zsh-autosuggestions
    zsh-syntax-highlighting
    colored-man-pages
    # command-not-found
    # extract
    # z
)

source $ZSH/oh-my-zsh.sh

# ============================================================================ #
# Post Oh My Zsh Configuration - Custom Settings
# ============================================================================ #

# XDG directories for better organization
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# Create zsh state directory if it doesn't exist
if [ ! -d "$XDG_STATE_HOME/zsh" ]; then
    mkdir -p "$XDG_STATE_HOME/zsh"
fi

# Set custom history file location
export HISTFILE="$XDG_STATE_HOME/zsh/history"

# Source common configurations (shared with bash)
[ -f ~/.commonrc ] && source ~/.commonrc

# ============================================================================ #
# Zsh-Specific Configuration
# ============================================================================ #

# Remove duplicates from PATH (zsh-specific feature)
typeset -U path

# Homebrew setup (if not already done in .commonrc)
if [[ ! "$PATH" =~ "homebrew" ]] && [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ ! "$PATH" =~ "homebrew" ]] && [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# ============================================================================ #
# OS-specific configurations removed for faster startup
# ============================================================================ #

# ============================================================================ #
# ZSH Options
# ============================================================================ #

# History options
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# Directory options
setopt AUTO_CD
setopt AUTO_PUSHD
setopt CDABLE_VARS
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# Completion options
setopt ALWAYS_TO_END
setopt AUTO_LIST
setopt AUTO_MENU
setopt AUTO_PARAM_SLASH
setopt COMPLETE_IN_WORD
setopt MENU_COMPLETE
setopt PATH_DIRS

# Other options
setopt EXTENDED_GLOB
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP
setopt PROMPT_SUBST
setopt VI

# ============================================================================ #
# Completions - moved to .commonrc.lazy for faster startup
# ============================================================================ #

# ============================================================================ #
# Key Bindings - moved to .commonrc.lazy for faster startup
# ============================================================================ #
bindkey -e  # Use emacs key bindings (needed immediately)
bindkey -v  # vi key bindings

# ============================================================================ #
# Additional Plugin Configuration
# ============================================================================ #

# Plugins are now managed by Oh My Zsh via the plugins=() array above
# No manual loading needed for zsh-autosuggestions, zsh-syntax-highlighting, etc.

# ============================================================================ #
# Interactive Shell Integrations
# ============================================================================ #

# Load local configuration if it exists
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# PATH is now managed in .commonrc

# ============================================================================ #
# Welcome Message
# ============================================================================ #

# Removed welcome message for faster startup
# Uncomment below if you want it back:
# if [[ -o interactive ]]; then
#     echo "Welcome to $(whoami)@$(hostname -s)!"
# fi

# ============================================================================ #
# Deferred/Lazy Loading
# ============================================================================ #

# Load heavy tools in background after 0.1 seconds (recommended)
(sleep 0.1 && source ~/.commonrc.lazy 2>/dev/null) &!

# Lazy load rbenv - only initialize when first used
rbenv() {
    unset -f rbenv
    eval "$(command rbenv init - zsh)"
    rbenv "$@"
}

# Lazy load mise - only initialize when first used
mise() {
    unset -f mise
    eval "$(command mise activate zsh)"
    mise "$@"
}

# Load aliases immediately - they're lightweight and expected to be available
[ -f ~/.aliases ] && source ~/.aliases
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/jeremyspofford/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

export TEAMS_WEBHOOK_URL="https://REDACTED_DOMAIN:443/powerautomate/automations/direct/workflows/08da888b32f64478ab95edb494c09c8f/triggers/manual/paths/invoke?api-version=1&sp=%2Ftriggers%2Fmanual%2Frun&sv=1.0&sig=***REDACTED***"


# opencode
export PATH=/Users/jeremyspofford/.opencode/bin:$PATH
