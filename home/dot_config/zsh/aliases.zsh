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

# Modern command alternatives (if available)
command -v exa >/dev/null && alias ls='exa --color=auto --icons'
command -v exa >/dev/null && alias ll='exa -la --color=auto --icons --git'
command -v exa >/dev/null && alias la='exa -a --color=auto --icons'
command -v exa >/dev/null && alias tree='exa --tree --color=auto --icons'

command -v bat >/dev/null && alias cat='bat --paging=never'
command -v bat >/dev/null && alias less='bat'

command -v fd >/dev/null && alias find='fd'

# Git aliases (enhanced)
alias gst='git status'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gaa='git add .'
alias gcm='git commit -m'
alias gp='git push'
alias gl='git pull'
alias glog='git log --oneline --graph --decorate'
alias gdiff='git diff'

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# System monitoring
alias htop='htop -C'
alias df='df -h'
alias du='du -h'
alias free='free -h'

# Network
alias ping='ping -c 5'
alias myip='curl -s ifconfig.me'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Chezmoi shortcuts
alias cm='chezmoi'
alias cma='chezmoi apply'
alias cmd='chezmoi diff'
alias cme='chezmoi edit'
alias cms='chezmoi status'
alias cmu='chezmoi update'

# Fabric AI shortcuts
alias fab='fabric'
alias fabp='fabric -p'
alias fablist='fabric --list'
alias fabupdate='fabric --updatepatterns'

# Development shortcuts
alias serve='python3 -m http.server'
alias servephp='php -S localhost:8000'
alias jsonpp='python3 -m json.tool'
alias urlencode='python3 -c "import sys, urllib.parse as ul; print(ul.quote_plus(sys.argv[1]))"'
alias urldecode='python3 -c "import sys, urllib.parse as ul; print(ul.unquote_plus(sys.argv[1]))"'

# Docker shortcuts
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias drm='docker rm'
alias drmi='docker rmi'
alias dstop='docker stop $(docker ps -q)'
alias dclean='docker system prune -af'

# mise shortcuts
alias m='mise'
alias mi='mise install'
alias ml='mise list'
alias mg='mise global'
alias mloc='mise local'

# Quick edits
alias zshrc='chezmoi edit ~/.zshrc'
alias bashrc='chezmoi edit ~/.bashrc'
alias gitconfig='chezmoi edit ~/.gitconfig'
alias aliases='chezmoi edit ~/.config/zsh/aliases.zsh'

# System information
alias sysinfo='uname -a && lsb_release -a 2>/dev/null || sw_vers 2>/dev/null'
alias ports='ss -tuln || netstat -tuln'
alias listening='ss -tlnp || netstat -tlnp'

# File operations
alias mkdir='mkdir -pv'
alias wget='wget -c'
alias mount='mount | column -t'

# Process management
alias psg='ps aux | grep'
alias killall='killall -v'

# Archive operations
alias tarx='tar -xvf'
alias tarc='tar -cvf'
alias tarz='tar -czvf'
alias untar='tar -xvf'

# Quick navigation to common directories
alias dev='cd ~/Development || cd ~/dev || cd ~/code'
alias downloads='cd ~/Downloads'
alias desktop='cd ~/Desktop'
alias documents='cd ~/Documents'

# Reload shell configuration
alias reload='source ~/.zshrc || source ~/.bashrc'

# Weather (requires curl)
alias weather='curl -s "wttr.in?format=3"'
alias weatherfull='curl -s "wttr.in"'

# System updates
alias update-arch='sudo pacman -Syu'
alias update-debian='sudo apt update && sudo apt upgrade'
alias update-fedora='sudo dnf upgrade'
alias update-macos='softwareupdate -i -a'
alias update-brew='brew update && brew upgrade'

# Time and date
alias now='date +"%T"'
alias nowdate='date +"%d-%m-%Y"'
alias week='date +%V'

# Clipboard (cross-platform)
if command -v xclip >/dev/null; then
    alias clipboard='xclip -selection clipboard'
    alias cb='xclip -selection clipboard'
elif command -v pbcopy >/dev/null; then
    alias clipboard='pbcopy'
    alias cb='pbcopy'
fi

# Text processing
alias linecount='wc -l'
alias wordcount='wc -w'
alias charcount='wc -c'

# Network diagnostics
alias portscan='nmap -sS -O'
alias flushdns='sudo dscacheutil -flushcache || sudo systemctl restart systemd-resolved'
alias publicip='curl -s ifconfig.me && echo'
alias localip='hostname -I || ipconfig getifaddr en0'

# Security
alias checksum='shasum -a 256'
alias md5check='md5sum'
alias passgen='openssl rand -base64 32' 
