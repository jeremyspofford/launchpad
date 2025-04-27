# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
if [[ $(echo $(uname)) == "Darwin" ]]; then
  # if macos
  alias start="open"
else
  alias start="explorer.exe"
fi

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

# GIT ALIASES
alias gitr="git ls-files -z --deleted | git update-index -z --remove --stdin"
alias gitrm="git rm --cached"
alias gita="git aa"
alias gitu="gita .;gitr;git c"
alias gitua="gita .;gitr;git commit --amend"
alias gituah="gita .;gitr;git commit --amend -C HEAD --allow-empty"
alias gitp="git push origin HEAD -u"
alias gitpf="gitp --force"
function gitprune() {
  git branch -vv | grep ': gone]' | grep -v '\*' | awk '{ print $1; }' | xargs -r git branch -d
}
alias gitstat='for k in $(git branch -a --merged|grep -v "\->"|sed s/^..//);do echo -e $(git log -1 --pretty=format:"%Cgreen%ci %Cred%cr%Creset" "$k")\\t"$k";done|sort|more'

# ANSIBLE ALIASES
alias ap="ansible-playbook"

# DOCKER-COMPOSE ALIASES
alias dc="docker-compose"
alias dcu="dc up"
alias dcd="dc down"
alias dcb="dc build"
alias dce="dc exec"

# DOCKER ALIASES
alias dsa="docker ps -qa | xargs docker stop"
alias dra="docker ps -qa | xargs docker rm"
alias dri="docker images -q | xargs docker rmi"

# PYTHON ALIASES
alias python="python3"
alias pip="pip3"

alias vim="nvim"

# alias chezmoi
alias c="chezmoi"
alias ch="chezmoi help"
alias ccd="chezmoi cd"
alias ca="chezmoi add"

# TERRAFORM
alias tf="terraform"
alias tfp="terraform plan"
alias tfa="terraform apply"

# OpenTofu
# alias tf="tofu"
# alias tfp="tofu plan"
# alias tfa="tofu apply"

# TERRAGRUNT
alias tg="terragrunt"
alias tgp="terragrunt plan"
alias tga="terragrunt apply"

# Kubernentes
alias k="kubectl"

# some more ls aliases
alias ll='ls -AlF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'

alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"

# NeoVim
alias craftzdog="NVIM_APPNAME=craftzdog/dotfiles-public/.config/nvim nvim"
alias starter="NVIM_APPNAME=starter nvim"
alias xero="NVIM_APPNAME=xero/dotfiles/neovim/.config/nvim nvim"
alias nvchad="NVIM_APPNAME=nvchad nvim"
alias nvim-kickstart='NVIM_APPNAME=nvim-kickstart nvim'
alias obsidian="nvim ~/Obsidian"

