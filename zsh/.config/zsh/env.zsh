# Editor configuration
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Source additional environment variables if they exist
if [[ -f ~/.zshenv ]]; then
  source ~/.zshenv
fi

# Mise activation
eval "$(~/.local/bin/mise activate zsh)" 