# ls aliases
alias ls='ls --color=auto'
alias ll='ls -AlF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'

# grep aliases
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# ANSIBLE ALIASES
alias ap="ansible-playbook"

# PYTHON ALIASES
alias python="python3"
alias pip="pip3"

# TERRAFORM
alias tf="terraform"
alias tfp="terraform plan"
alias tfa="terraform apply"

# TERRAGRUNT
alias tg="terragrunt"
alias tgp="terragrunt plan"
alias tga="terragrunt apply"

# Kubernetes
alias k="kubectl"

# NeoVim configurations
alias craftzdog="NVIM_APPNAME=craftzdog/dotfiles-public/.config/nvim nvim"
alias starter="NVIM_APPNAME=starter nvim"
alias xero="NVIM_APPNAME=xero/dotfiles/neovim/.config/nvim nvim"
alias nvchad="NVIM_APPNAME=nvchad nvim"
alias nvim-kickstart='NVIM_APPNAME=nvim-kickstart nvim'
alias obsidian="nvim ~/Obsidian"

# Alert alias for long running commands
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"' 