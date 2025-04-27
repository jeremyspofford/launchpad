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
  sudo apt update
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

main() {
  detect_os_and_install_ansible
  run_ansible_and_continue
  mise_install
  # if [[ ! ~/.ssh/personal_id_ed25519 ]]; then
    generate_ssh_key
  # fi
#  clone_dotfiles
  log "✅ Full bootstrap complete!"
}

main "$@"
