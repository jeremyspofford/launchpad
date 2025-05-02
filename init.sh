#!/usr/bin/env bash

set -euo pipefail

# ============================================================================ #
# Constants and Configuration
# ============================================================================ #

files_to_backup=(
  .bash_aliases
  .bash_profile
  .bashrc
  .gitconfig
  .profile
  .zshrc
  .zshenv
  .zsh_aliases
  .zprofile
  .vimrc
)

ignore_stow_modules=(
  .stowrc
  ansible
  init.sh
  inventory.ini
  README.md
)

# ============================================================================ #
# Utility Functions
# ============================================================================ #

log() { echo -e "\033[1;34m[INFO]\033[0m $1"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $1"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $1"; }

# ============================================================================ #
# Package Management Functions
# ============================================================================ #

install_ansible_macos() {
  if ! command -v brew >/dev/null; then
    error "❌ Homebrew not found. Please install it from https://brew.sh"
    exit 1
  fi

  if ! command -v ansible >/dev/null; then
    log "Installing Ansible via Homebrew..."
    brew install ansible
  fi
}

install_ansible_ubuntu() {
  if ! command -v ansible >/dev/null; then
    log "Installing Ansible via apt..."
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y software-properties-common
    sudo apt-add-repository --yes --update ppa:ansible/ansible
    sudo apt install -y ansible
  fi
}

detect_os_and_install_ansible() {
  case "$(uname -s)" in
    Darwin)
      log "Detected macOS"
      install_ansible_macos
      ;;
    Linux)
      log "Detected Linux"
      install_ansible_ubuntu
      ;;
    *)
      error "Unsupported OS: $(uname -s)"
      exit 1
      ;;
  esac
}

# ============================================================================ #
# Core Setup Functions
# ============================================================================ #

backup_dotfiles() {
  if [[ "$backup" = true ]]; then
    log "Attempting to backup $HOME dotfiles"
    cd $HOME

    timestamp=$(date +"%Y%m%d_%H%M%S")
    backup_folder="backup_$timestamp"

    for file in "${files_to_backup[@]}"; do
      if [ -f "$file" ] && [ ! -L "$file" ]; then
        mkdir -p "$backup_folder"
        log "Backing up $file"
        mv "$file" "$backup_folder/$file"
      else
        warn "Skipping $file because it's a symlink or doesn't exist"
      fi
    done

    log "Dotfiles backup complete"
  fi
}

stow_it() {
  log "Syncing dotfiles with GNU stow"
  cd ~/dotfiles/
  for dir in *; do
    if [[ ! " ${ignore_stow_modules[@]} " =~ " ${dir} " ]]; then
      stow --target=$HOME --restow "$dir" 2>/dev/null
    fi
  done
  log "Dotfiles sync complete"
}

generate_ssh_key() {
  if [[ ! -f ~/.ssh/personal_id_ed25519 ]]; then
    mkdir -p ~/.ssh
    echo -n "GitHub email: "
    read email
    ssh-keygen -t ed25519 -C $email -f ~/.ssh/personal_id_ed25519 -N ""
    cat ~/.ssh/personal_id_ed25519.pub | xclip -selection clipboard
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/personal_id_ed25519

    log "SSH key generated and copied to clipboard"
    log "Please add the key to GitHub and press enter to continue"
    read -p "Press enter to continue"
  fi
}

# ============================================================================ #
# Tool Installation Functions
# ============================================================================ #

mise_install() {
  if ! command -v mise >/dev/null; then
    log "Installing Mise"
    curl https://mise.run | sh
  fi
  ~/.local/bin/mise install -y
  source ~/.bashrc
}

run_ansible_and_continue() {
  if command -v ansible >/dev/null; then
    log "Running Ansible playbook..."
    ansible-playbook -i ~/dotfiles/ansible/inventory.ini ~/dotfiles/ansible/playbook.yml
  fi
}

finalize() {
  log "Finalizing setup..."
  sudo apt autoremove -y

  # Prompt user about backup folder
  if [[ -d "$HOME/backup_"* ]]; then
    log "Backup folder found. Would you like to remove it? [y/N]"
    read -r remove_backup
    if [[ "$remove_backup" =~ ^[Yy]$ ]]; then
      rm -rf "$HOME/backup_"*
      log "Backup folder removed"
    fi
  fi
  zsh
}

# ============================================================================ #
# Main Script Logic
# ============================================================================ #

main() {
  # Check for enhanced getopt
  if ! getopt --test >/dev/null 2>&1; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      brew install gnu-getopt
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
      sudo apt install util-linux
    else
      error "Unsupported OS: $OSTYPE" >&2
      exit 1
    fi
  fi

  # Parse command line options
  backup=true
  OPTIONS=n
  LONGOPTIONS=no-backup
  
  PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTIONS --name "$0" -- "$@")
  if [[ $? -ne 0 ]]; then
    exit 1
  fi
  eval set -- "$PARSED"

  while true; do
    case "$1" in
      -n | --no-backup)
        backup=false
        shift
        ;;
      --)
        shift
        break
        ;;
      *)
        error "Invalid option: $1" >&2
        exit 1
        ;;
    esac
  done

  # Execute setup steps
  rm -rf "$HOME/backup_"*
  backup_dotfiles
  detect_os_and_install_ansible
  run_ansible_and_continue
  stow_it
  mise_install
  generate_ssh_key
  finalize

  log "✅ Full bootstrap complete!"
}

main "$@"
