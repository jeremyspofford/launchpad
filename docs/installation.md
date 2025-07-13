# Installation Guide

This guide provides detailed installation instructions for the dotfiles repository across different platforms.

## Prerequisites

### All Platforms
- Git
- curl
- Terminal with Unicode and Nerd Font support

### Platform-Specific
- **macOS**: Xcode Command Line Tools (`xcode-select --install`)
- **Linux**: Build tools (`build-essential` on Ubuntu/Debian)
- **Windows**: PowerShell 5.1+ and Windows Package Manager (winget)

## Quick Start

### Unix-like Systems (Linux/macOS)

```bash
# Clone the repository
git clone https://github.com/jeremyspofford/dotfiles.git

# Run the installation script
./dotfiles/install.sh

# Optional: Skip backup of existing dotfiles
./dotfiles/install.sh --no-backup
```

### Windows

```powershell
# Clone the repository
git clone https://github.com/jeremyspofford/dotfiles.git

# Run the Windows installer
./dotfiles/install.ps1
```

## Installation Process

### What Happens During Installation

1. **Dependency Check**: Verifies required tools are available
2. **Backup**: Creates timestamped backup of existing dotfiles (unless `--no-backup`)
3. **Package Installation**: Runs Ansible playbook to install system packages
4. **Tool Installation**: Installs mise and starship
5. **chezmoi Setup**: Initializes chezmoi with the repository
6. **Configuration**: Prompts for user information and applies configurations
7. **Shell Switch**: Switches to zsh (if available)

### User Prompts

During installation, you'll be prompted for:

- **Email address**: Used for Git configuration and SSH key generation
- **Full name**: Used for Git configuration
- **GitHub username**: Used for repository URLs and SSH configuration

## Platform-Specific Details

### macOS Installation

The macOS installation uses Homebrew for package management:

```bash
# Packages installed via Homebrew
- curl, fzf, git, gnu-getopt, jq
- ripgrep, tmux, zoxide, zsh
- exa, bat, fd
- chezmoi
```

### Linux Installation (Ubuntu/Debian)

The Linux installation uses apt for package management:

```bash
# Packages installed via apt
- build-essential, curl, fzf, git, gnupg, jq
- locate, ripgrep, tmux, unzip, util-linux
- xclip, zoxide, zsh, exa, bat, fd-find
```

Note: On Ubuntu, `fd-find` is symlinked to `fd` for compatibility.

### Windows Installation

The Windows installation installs applications via winget:

**Core Applications:**
- 1Password
- Obsidian
- Joplin
- Brave Browser
- Cursor IDE
- Docker Desktop

**Proton Suite:**
- Proton Drive
- Proton Mail
- Proton Pass
- Proton VPN

**Optional:**
- Steam (if requested)
- WSL with Ubuntu 24.04 (if requested)

## Post-Installation

### Verification

After installation, verify the setup:

```bash
# Check chezmoi status
chezmoi status

# Verify shell configuration
echo $SHELL

# Test installed tools
fzf --version
rg --version
mise --version
starship --version
```

### SSH Key Setup

The installation generates an ED25519 SSH key at `~/.ssh/personal_id_ed25519`. You'll need to:

1. Copy the public key: `cat ~/.ssh/personal_id_ed25519.pub`
2. Add it to your GitHub account: Settings → SSH and GPG keys → New SSH key
3. Test the connection: `ssh -T git@github.com`

## Troubleshooting

### Common Issues

**Permission Errors**
```bash
# Fix permissions for SSH keys
chmod 600 ~/.ssh/personal_id_ed25519
chmod 644 ~/.ssh/personal_id_ed25519.pub
```

**Missing Packages**
```bash
# Rerun Ansible playbook
ansible-playbook -i ~/dotfiles/ansible/inventory.ini ~/dotfiles/ansible/playbook.yml
```

**chezmoi Issues**
```bash
# Reinitialize chezmoi
rm -rf ~/.local/share/chezmoi
chezmoi init --apply ~/dotfiles
```

### Getting Help

1. Check the [troubleshooting guide](troubleshooting.md)
2. Review the [FAQ](faq.md)
3. Open an issue on GitHub