# #!/bin/bash

# repo_name="dotfiles"

# command_exists() {
#     command -v "$1" &> /dev/null
# }

# # Generate SSH key
# generate_ssh_key() {
#     mkdir -p ~/.ssh
#     ssh-keygen -t ed25519 -C "jeremyspofford@gmail.com" -f ~/.ssh/personal_id_ed25519 -N ""
#     cat ~/.ssh/personal_id_ed25519.pub | xclip -selection clipboard
#     eval "$(ssh-agent -s)"
#     ssh-add ~/.ssh/personal_id_ed25519

#     # Pause until user presses enter
#     echo "SSH key generated and copied to clipboard"
#     echo "Please add the key to GitHub and press enter to continue"
#     read -p "Press enter to continue"
# }


# # Identify the operating system
# OS=$(uname -s)

# echo "Detected operating system: $OS"

# if [ "$OS" == "Linux" ]; then
#     echo "Installing packages for Linux"

#     sudo add-apt-repository -y ppa:ansible/ansible
#     sudo apt update -y && sudo apt upgrade -y
#     sudo apt install -y software-properties-common \
#         xclip \
#         ansible
#     sudo apt autoremove -y

#     if [[ ! -f ~/.ssh/personal_id_ed25519.pub ]]; then
#         generate_ssh_key
#     fi

#     if [[ ! -d $repo_name ]]; then
#         git clone git@github.com:jeremyspofford/$repo_name.git $HOME/$repo_name
#     fi

#     ansible-playbook -i $HOME/$repo_name/inventory.ini $HOME/$repo_name/debian.yaml -K

# # elif [ "$OS" == "Darwin" ]; then
# #     brew install mise

# #     generate_ssh_key

# #     git clone git@github.com:jeremyspofford/$repo_name.git
# #     cd $repo_name

# #     ansible-playbook -i inventory.ini bootstrap.yaml

# else
#     echo "Unsupported operating system: $OS"
#     exit 1
# fi



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
      if grep -q Microsoft /proc/version 2>/dev/null; then
        log "Detected WSL"
        install_ansible_ubuntu
      else
        log "Detected Linux"
        install_ansible_ubuntu
      fi
      ;;
    *)
      echo "Unsupported OS: $(uname -s)"
      exit 1
      ;;
  esac
}

run_ansible_and_continue() {
  log "Running Ansible playbook..."
  ansible-playbook ansible/playbook.yml

  log "Running remaining shell bootstrap (GPG, yadm, 1Password)..."
#   ./bootstrap.sh
}

clone_dotfiles() {
  log "Cloning dotfiles..."
  mkdir -p ~/dotfiles
  cd ~/dotfiles
  yadm clone https://github.com/jeremyspofford/dotfiles.git  -f
#   yadm clone git@github.com:jeremyspofford/dotfiles.git
}

main() {
  detect_os_and_install_ansible
  run_ansible_and_continue
  clone_dotfiles
  log "✅ Full bootstrap complete!"
}

main "$@"
