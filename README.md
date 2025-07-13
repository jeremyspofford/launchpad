# 🚀 dotfiles

A comprehensive cross-platform dotfiles configuration for developers, using chezmoi for advanced management and Ansible for automated setup.

## ✨ Core Features

- **Cross-platform compatibility**: Works on macOS, Linux, and Windows
- **chezmoi-managed dotfiles**: Advanced templating and secret management
- **Automated package installation**: Ansible playbooks for system dependencies
- **Modern shell configuration**: Zsh with starship prompt and productivity tools
- **AI-powered CLI tools**: Extensive fabric pattern library (200+ patterns)
- **Version management**: mise for development tool management
- **Git configuration**: Template-based with cross-platform compatibility

## 🛠️ What's Included

### Development Tools
- **Shell**: Zsh with modern CLI tools (fzf, ripgrep, bat, exa, zoxide)
- **Prompt**: Starship with customized configuration
- **Editor**: Neovim configuration (managed via chezmoi)
- **Version Manager**: mise for runtime version management
- **Terminal Multiplexer**: tmux configuration
- **AI Tools**: fabric with extensive pattern library

### System Integration
- **Package Management**: Automated via Ansible (apt for Debian/Ubuntu, Homebrew for macOS)
- **Git Configuration**: Template-based with user-specific settings
- **SSH Key Management**: Automated generation and setup prompts
- **Cross-platform Support**: Windows (via PowerShell/winget), macOS, Linux

## 🚀 Quick Start

### Unix-like Systems (Linux/macOS)

1. Clone and bootstrap:
```bash
git clone https://github.com/jeremyspofford/dotfiles.git
./dotfiles/install.sh
```

2. Skip backup (if you don't want existing dotfiles backed up):
```bash
./dotfiles/install.sh --no-backup
```

### Windows

1. Clone the repository
2. Run the Windows installer:
```powershell
./dotfiles/install.ps1
```

This will install development tools and optionally set up WSL with the full Unix environment.

## 🔧 Management Commands

### Daily Operations
```bash
# Apply configuration changes
chezmoi apply

# Edit dotfiles (with automatic template handling)
chezmoi edit ~/.zshrc

# Update from repository
chezmoi update

# View pending changes
chezmoi diff

# Install/update development tools
mise install -y
```

### Advanced Operations
```bash
# Run Ansible playbook manually
ansible-playbook -i ~/dotfiles/ansible/inventory.ini ~/dotfiles/ansible/playbook.yml

# Add new files to chezmoi management
chezmoi add ~/.newconfig

# View chezmoi status
chezmoi status
```

## 🎯 Installation Process

The setup process will prompt for:

1. **Personal Information**: Name, email, GitHub username (for git config and SSH)
2. **Tool Preferences**: Optional components and integrations
3. **SSH Key Setup**: Automated key generation with GitHub integration prompts

## 🏗️ Architecture

### Directory Structure
- **`home/`**: chezmoi source directory with all managed dotfiles
- **`ansible/`**: System package installation and configuration
- **`install.sh`**: Primary bootstrap script for Unix-like systems
- **`install.ps1`**: Windows application installer
- **Legacy directories** (`bash/`, `git/`, etc.): Historical reference, not actively managed

### Migration Status
This repository has migrated from GNU Stow to chezmoi for enhanced:
- Cross-platform compatibility
- Template-based configuration
- Secret management capabilities
- Git integration

## 📦 Installed Packages

### System Tools
- build-essential, curl, git, jq, unzip
- fzf, ripgrep, bat, exa, fd, zoxide
- tmux, zsh, starship
- chezmoi, mise

### Windows Applications (via install.ps1)
- Development: Docker Desktop, Cursor IDE
- Productivity: 1Password, Obsidian, Joplin
- Privacy: Proton suite (Mail, VPN, Drive, Pass)
- Browser: Brave
- Optional: Steam and other personal applications

## 🛠️ Prerequisites

- **Git** and **curl** (for initial bootstrap)
- **Terminal** with Unicode and Nerd Font support
- **Administrator privileges** (for package installation)

## 📚 Resources

- [chezmoi Documentation](https://www.chezmoi.io/)
- [Starship Configuration](https://starship.rs/config/)
- [Fabric AI Patterns](https://github.com/danielmiessler/fabric)
- [mise Version Manager](https://mise.jdx.dev/)

## 🤝 Contributing

Feel free to fork and customize for your needs. Pull requests for improvements are welcome!
