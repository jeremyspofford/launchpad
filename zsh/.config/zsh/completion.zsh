# Initialize completion system
autoload -Uz +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit

# Case insensitive path-completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select

# Oh My Zsh completion settings
CASE_SENSITIVE="true"
HYPHEN_INSENSITIVE="true" 