# Path to Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Source modular configurations
for config_file (~/.config/zsh/*.zsh) source $config_file

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh 