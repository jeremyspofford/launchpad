#!/usr/bin/env bash

set -euo pipefail

log() { echo -e "\033[1;34m[INFO]\033[0m $1"; }

install_ansible_macos() {
  if ! command -v brew >/dev/null; then
    echo "❌ Homebrew not found. Please install it from https://brew.sh"
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
    echo "Unsupported OS: $(uname -s)"
    exit 1
    ;;
  esac
}

run_ansible_and_continue() {
  if ! command -v ansible >/dev/null; then
    log "Running Ansible playbook..."
    ansible-playbook ~/dotfiles/setup/ansible/playbook.yml
  fi

  # log "Running remaining shell bootstrap (GPG, yadm, 1Password)..."
  #   ./bootstrap.sh
}

# Generate SSH key
generate_ssh_key() {
  if [[ ! -f ~/.ssh/personal_id_ed25519 ]]; then
    mkdir -p ~/.ssh
    echo -n "GitHub email: "
    read email
    ssh-keygen -t ed25519 -C $email -f ~/.ssh/personal_id_ed25519 -N ""
    cat ~/.ssh/personal_id_ed25519.pub | xclip -selection clipboard
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/personal_id_ed25519

    # Pause until user presses enter
    log "SSH key generated and copied to clipboard"
    log "Please add the key to GitHub and press enter to continue"
    read -p "Press enter to continue"
  fi
}

# Install mise and tools
mise_install() {
  if ! command -v mise >/dev/null; then
    log "Installing Mise"
    curl https://mise.run | sh
    mise install -y
  fi
}

backup_dotfiles() {
  log "Backing up $HOME dotfiles"
  cd $HOME

  # Create a timestamp for the unique backup forlder
  timestamp=$(date +"%Y%m%d_%H%M%S")
  backup_folder="backup_$timestamp"

  mkdir -p "$backup_folder"

  # Array of files to be backed up
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

  # Loop through the array and move each file to the backup folder
  for file in "${files_to_backup[@]}"; do
    if [ -f "$file" ]; then
      log "Backing up $file"
      mv "$file" "$backup_folder/$file"
    fi
  done

  log "Dotfiles backup complete"
}

stow_it() {
  log "Syncing dotfiles with GNU stow"
  cd $HOME/dotfiles/
  for dir in $(ls -d */); do
    log "Stowing $dir"
    # stow $dir
  done
  log "Dotfiles sync complete"
}

install_oh_my_zsh() {
  if [[ ! -d ~/.oh-my-zsh ]]; then
    log "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi
}

finalize() {
  log "Finalizing setup..."

  sudo apt autoremove -y

  # Change default shell to zsh if not already set
  if [[ "$SHELL" != "/bin/zsh" ]]; then
    log "Changing default shell to zsh"
    chsh -s $(which zsh)
    log "Please log out and log back in for shell changes to take effect"
  fi
}

main() {
  generate_ssh_key
  detect_os_and_install_ansible
  run_ansible_and_continue
  mise_install
  backup_dotfiles
  install_oh_my_zsh
  stow_it
  finalize
  #  clone_dotfiles

  log "✅ Full bootstrap complete!"
}

main "$@"
