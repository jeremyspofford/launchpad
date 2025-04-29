# Oh My Zsh plugins configuration
plugins=(
  vi-mode
  themes
)

# Mise activation
if [[ -f ~/.local/bin/mise ]]; then
  eval "$(~/.local/bin/mise activate zsh)"
fi

# Starship prompt (if installed)
if command -v starship &>/dev/null; then
  export STARSHIP_CONFIG=$HOME/.config/starship/starship.toml
  eval "$(starship init zsh)"
fi

# Uncomment to enable these additional tools
# eval "$(gh copilot alias -- zsh)"
# eval "$(zoxide init zsh)" 