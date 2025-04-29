#!/usr/bin/env bash

set -euo pipefail

log() { echo -e "\033[1;34m[INFO]\033[0m $1"; }

install_ansible_macos() {
  if ! command -v brew >/dev/null; then
    echo "❌ Homebrew not found. Please install it from https://brew.sh"
    exit 1
  fi
  log "Installing Ansible via Homebrew..."
  brew install ansible
}

install_ansible_ubuntu() {
  log "Installing Ansible via apt..."
  sudo apt update && sudo apt upgrade -y
  sudo apt install -y software-properties-common
  sudo apt-add-repository --yes --update ppa:ansible/ansible
  sudo apt install -y ansible
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
  log "Running Ansible playbook..."
  ansible-playbook ~/dotfiles/setup/ansible/playbook.yml

  log "Running remaining shell bootstrap (GPG, yadm, 1Password)..."
  #   ./bootstrap.sh
}

# Generate SSH key
generate_ssh_key() {
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
}

# Install mise and tools
mise_install() {
  curl https://mise.run | sh
  echo 'eval "$(/home/jeremy/.local/bin/mise activate bash)" >> ~/.bashrc'
  # $HOME/.local/bin/mise install -y
  mise install -y
}

clone_dotfiles() {
  log "Cloning dotfiles..."
  mkdir -p ~/dotfiles
  cd ~/dotfiles
  yadm clone https://github.com/jeremyspofford/dotfiles.git
  #   yadm clone git@github.com:jeremyspofford/dotfiles.git
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
    else
      log "File $file not found, skipping"
    fi
  done

  log "Dotfiles backup complete"
}

stow_it() {
  log "Syncing dotfiles with GNU stow"
  cd $HOME/dotfiles/
  stow .
  log "Dotfiles sync complete"
}

install_oh_my_zsh() {
  log "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

finalize() {
  log "Finalizing setup..."
  # Change default shell to zsh if not already set
  if [[ "$SHELL" != "/bin/zsh" ]]; then
    log "Changing default shell to zsh"
    chsh -s $(which zsh)
  fi

  # Source the new dotfiles
  source ~/.zshrc
}

main() {
  if [[ ! ~/.ssh/personal_id_ed25519 ]]; then
    generate_ssh_key
  fi
  detect_os_and_install_ansible
  run_ansible_and_continue
  mise_install
  backup_dotfiles
  stow_it
  install_oh_my_zsh
  finalize
  #  clone_dotfiles

  log "✅ Full bootstrap complete!"
}

main "$@"
