# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

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
# Key Bindings
# ============================================================================ #
bindkey -e  # Use emacs key bindings (needed immediately)
bindkey -v  # vi key bindings

# ============================================================================ #
# Interactive Shell Integrations
# ============================================================================ #

# Load local configuration if it exists
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

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

# Activate mise
eval "$(command mise activate zsh)"

# Load aliases immediately - they're lightweight and expected to be available
[ -f ~/.aliases ] && source ~/.aliases

# Added by Antigravity
export PATH="/Users/jeremyspofford/.antigravity/antigravity/bin:$HOME/.npm-global/bin:$PATH"

# eval "$(op signin)"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

# Open WebUI aliases
alias openwebui='docker start open-webui 2>/dev/null; xdg-open http://localhost:3000 2>/dev/null || open http://localhost:3000'
alias webui='openwebui'
