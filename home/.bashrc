#!/bin/bash
# ~/.bashrc - Bash configuration
# Sources shared config from .commonrc for consistency with zsh

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# ============================================================================ #
# Bash-Specific Settings
# ============================================================================ #

# History settings
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend

# Check window size after each command
shopt -s checkwinsize

# Enable programmable completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# ============================================================================ #
# Shared Configuration
# ============================================================================ #

# Source common shell configuration (shared with zsh)
[ -f ~/.commonrc ] && source ~/.commonrc

# Source aliases
[ -f ~/.aliases ] && source ~/.aliases

# Source machine-specific local config (not in repo)
[ -f ~/.bashrc.local ] && source ~/.bashrc.local

# Source secrets (API keys, tokens - never commit this)
[ -f ~/.secrets ] && source ~/.secrets
