#!/bin/bash

repo_name="bootstrap"

command_exists() {
    command -v "$1" &> /dev/null
}

# Generate SSH key
generate_ssh_key() {
    mkdir -p ~/.ssh
    ssh-keygen -t ed25519 -C "jeremyspofford@gmail.com" -f ~/.ssh/personal_id_ed25519 -N ""
    cat ~/.ssh/personal_id_ed25519.pub | xclip -selection clipboard
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/personal_id_ed25519

    # Pause until user presses enter
    echo "SSH key generated and copied to clipboard"
    echo "Please add the key to GitHub and press enter to continue"
    read -p "Press enter to continue"
}


# Identify the operating system
OS=$(uname -s)

echo "Detected operating system: $OS"

if [ "$OS" == "Linux" ]; then
    echo "Installing packages for Linux"

    sudo add-apt-repository -y ppa:ansible/ansible
    sudo apt update -y && sudo apt upgrade -y
    sudo apt install -y software-properties-common \
        xclip \
        ansible
    sudo apt autoremove -y

    if [[ ! -f ~/.ssh/personal_id_ed25519.pub ]]; then
        generate_ssh_key
    fi

    if [[ ! -d $repo_name ]]; then
        git clone git@github.com:jeremyspofford/$repo_name.git $HOME/$repo_name
    fi

    ansible-playbook -i $HOME/$repo_name/inventory.ini $HOME/$repo_name/debian.yaml -K

# elif [ "$OS" == "Darwin" ]; then
#     brew install mise

#     generate_ssh_key

#     git clone git@github.com:jeremyspofford/$repo_name.git
#     cd $repo_name

#     ansible-playbook -i inventory.ini bootstrap.yaml

else
    echo "Unsupported operating system: $OS"
    exit 1
fi