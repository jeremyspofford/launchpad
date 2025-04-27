# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
  # include .bashrc if it exists
  if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
  fi

  if [[ -f $HOME/.bash_aliases ]]; then
    source "$HOME/.bash_aliases"
  fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ]; then
  PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ]; then
  PATH="$HOME/.local/bin:$PATH"
fi

if [[ -f ~/.inputrc ]]; then
  source "$HOME/.inputrc"
fi

export PATH="$NVM_DIR/versions/node/*/bin:$PATH"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# Switch to node version in current directory, if an .nvmrc file is present.
# cd() {
#   builtin cd "$@"
#   if [[ -f .nvmrc ]]; then
#     nvm use >/dev/null
#   fi
# }
# cd .
#

export BASH_SILENCE_DEPRECATION_WARNING=1

complete -C /opt/homebrew/bin/terragrunt terragrunt
