# Oh My Zsh installation check and install if needed
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"

# Oh My Zsh plugins configuration
plugins=(
  git
  vi-mode
  zsh-autosuggestions
  zsh-syntax-highlighting
  colored-man-pages
  command-not-found
  extract
  z
  docker
  kubectl
  terraform
  ansible
)

# Source Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Install zsh-autosuggestions if not present
if [[ ! -d "$ZSH/custom/plugins/zsh-autosuggestions" ]]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH/custom/plugins/zsh-autosuggestions
fi

# Install zsh-syntax-highlighting if not present
if [[ ! -d "$ZSH/custom/plugins/zsh-syntax-highlighting" ]]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH/custom/plugins/zsh-syntax-highlighting
fi

# Zsh autosuggestions configuration
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff00ff,bg=cyan,bold,underline"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

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
