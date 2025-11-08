# Common Role

Cross-platform essential tools installation and dotfiles setup role for the GNU Stow dotfiles repository.

## Description

This role installs essential development tools and CLI utilities across macOS and Linux platforms, sets up dotfiles management with GNU Stow, and configures SSH keys and Oh My Zsh.

## Requirements

- **Ansible 2.9+**
- **Community.general collection** (for npm and homebrew modules)
- **GNU Stow** (installed automatically by this role)
- **Internet connection** for downloading tools and Oh My Zsh

## What This Role Does

### Package Installation

Installs common development tools across platforms:

- **Modern CLI Tools**: `bat`, `delta`, `fzf`, `ripgrep`, `jq`
- **Development Tools**: `git`, `neovim`, `tmux`, `zsh`, `gh` (GitHub CLI), `glab` (GitLab CLI)
- **Code Quality**: `shellcheck`, `yamllint`  
- **Utilities**: `curl`, `wget`, `starship` (shell prompt)

### Node.js Ecosystem

- **nvm** (Node Version Manager) - Latest version (v0.39.1)
- **tldr** - Simplified man pages via npm global install

### Dotfiles Management

- **GNU Stow installation** - Cross-platform (Homebrew on macOS, package manager on Linux)
- **Automatic stow operation** - Symlinks dotfiles from `home/` to `~`
- **Workspace directory creation** - Creates `~/workspace` directory

### Additional Setup

- **SSH key generation and setup** for Git hosting services
- **Oh My Zsh installation and configuration**

## Role Variables

### Defaults (`defaults/main.yml`)

```yaml
common_packages:
  - bat
  - curl  
  - delta
  - fzf
  - gh
  - glab
  - git
  - jq
  - neovim
  - ripgrep
  - shellcheck
  - starship
  - tmux
  - wget
  - yamllint
  - zsh

os_packages: []  # Override in host_vars or playbook for OS-specific packages
```

### Customization

- **`common_packages`**: List of packages to install on all platforms
- **`os_packages`**: Additional OS-specific packages (empty by default)

## Platform Support

- **macOS**: Uses Homebrew for package installation (no sudo required)
- **Linux (Debian/Ubuntu)**: Uses apt package manager (requires sudo)
- **Linux (RHEL/CentOS)**: Uses yum/dnf package manager (requires sudo)

## Dependencies

**Ansible Collections:**

- `community.general` - Required for npm and homebrew modules

**External Dependencies:**

- Internet access for downloading NVM, tldr, and Oh My Zsh
- Package managers (brew/apt/yum) functional on target system

## Example Usage

### Basic Playbook

```yaml
---
- hosts: localhost
  connection: local
  roles:
    - common
```

### With Custom Packages

```yaml
---
- hosts: localhost
  connection: local
  vars:
    os_packages:
      - tree      # Linux-specific package
      - htop      # Another example
  roles:
    - common
```

### Platform-Specific Variables

```yaml
# host_vars/macos.yml
os_packages:
  - mas        # Mac App Store CLI

# host_vars/linux.yml  
os_packages:
  - tree
  - htop
```

## Tasks Overview

1. **Package Installation**: Installs common and OS-specific packages
2. **NVM Setup**: Installs Node Version Manager if not present
3. **tldr Installation**: Global npm install of tldr utility
4. **Stow Setup**: Ensures stow is installed and runs stow operation
5. **Directory Creation**: Creates workspace directory
6. **SSH Keys**: Imports SSH key setup tasks
7. **Oh My Zsh**: Imports Oh My Zsh installation tasks

## Idempotency

All tasks are designed to be idempotent:

- Packages only installed if not present
- NVM only installed if `~/.nvm/nvm.sh` doesn't exist
- tldr only installed if command fails
- Stow only runs if needed
- SSH keys and Oh My Zsh have their own idempotency checks

## Error Handling

- Package installation failures will stop the playbook
- NVM installation uses temporary files and cleanup
- Missing commands (like tldr) are handled gracefully with `ignore_errors`
- Platform detection ensures correct package manager usage

## File Structure

```
roles/common/
├── README.md           # This file
├── defaults/main.yml   # Default variables
├── tasks/
│   ├── main.yml       # Main task file
│   ├── ssh_keys.yml   # SSH key setup tasks
│   └── oh_my_zsh.yml  # Oh My Zsh setup tasks
└── vars/main.yml      # Role variables
```
