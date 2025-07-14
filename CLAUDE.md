# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a comprehensive dotfiles repository for developers focused on modern Unix-like environments. The setup uses chezmoi for cross-platform dotfile management and Ansible for automated system package installation. The repository has transitioned from using GNU Stow to chezmoi for enhanced cross-platform compatibility and templating capabilities.

## Core Architecture

### Main Components

- **install.sh**: Primary bootstrap script that orchestrates the entire setup process
- **install.ps1**: Windows-specific setup script for installing applications via winget
- **ansible/**: Automated package installation using Ansible playbooks
  - `playbook.yml`: Main playbook that applies the bootstrap role
  - `roles/bootstrap/tasks/main.yml`: Installs essential system packages (build-essential, curl, fzf, ripgrep, chezmoi, tmux, zsh, etc.)
- **home/**: chezmoi-managed dotfiles directory
  - All dotfiles are organized in chezmoi's naming convention (e.g., `dot_bashrc`, `dot_gitconfig.tmpl`)
  - Configuration files are stored in `dot_config/` subdirectories
  - Templates use chezmoi's templating system for cross-platform compatibility
  - Contains extensive fabric configuration for AI-powered CLI tools in `dot_config/fabric/`
- **.chezmoi.toml**: chezmoi configuration file with user prompts and settings
- **.chezmoiroot**: Points chezmoi to use the `home/` directory as the source
- **Legacy directories**: `bash/`, `git/`, `zsh/`, `nvim/`, etc. (kept for historical reference but migrated to `home/` structure)

### chezmoi Management

The repository uses chezmoi for advanced dotfile management with features like:
- **Cross-platform compatibility**: Templates handle OS-specific configurations
- **Secret management**: Secure handling of sensitive configuration data
- **Templating**: Dynamic configuration based on user input and system detection
- **Version control integration**: Direct integration with git repositories

### Tool Configuration Included

- **Fabric**: Extensive AI-powered CLI pattern library with 200+ patterns for various tasks
- **Zsh**: Complete shell configuration with modern tools integration
- **Git**: Template-based configuration for cross-platform compatibility
- **Starship**: Modern shell prompt configuration
- **mise**: Version management for development tools
- **Various CLI tools**: fzf, ripgrep, bat, exa, zoxide, and more

## Common Commands

### Initial Setup
```bash
# Clone and run full bootstrap
git clone https://github.com/jeremyspofford/dotfiles.git
./dotfiles/install.sh

# Skip backup of existing dotfiles
./install.sh --no-backup
```

### Manual Operations
```bash
# Apply dotfile changes with chezmoi
chezmoi apply

# Edit dotfiles with chezmoi (automatically manages templates)
chezmoi edit ~/.bashrc

# Update dotfiles from repository
chezmoi update

# Install/update tool versions via mise
mise install -y

# Run Ansible playbook manually (requires sudo password)
ansible-playbook -i ~/dotfiles/ansible/inventory.ini ~/dotfiles/ansible/playbook.yml --ask-become-pass

# View current chezmoi status
chezmoi status

# Add new files to chezmoi management
chezmoi add ~/.newconfig
```

### Windows Setup
```powershell
# Run Windows application installer (installs development tools and Proton suite)
./install.ps1
```

## Development Workflow

### Making Changes
1. Edit configuration files using `chezmoi edit <file>` or directly in the `home/` directory
2. Test changes with `chezmoi diff` to see what will change
3. Apply changes with `chezmoi apply`
4. Commit changes to the repository

### Adding New Tools
1. Add configuration files to the `home/` directory using chezmoi naming convention
2. Use `chezmoi add <file>` to automatically add existing system files
3. For templates, use `.tmpl` extension and chezmoi templating syntax
4. Update Ansible bootstrap role for any new system dependencies

### Migration Status
- **Completed**: Migration from GNU Stow to chezmoi
- **Legacy directories**: bash/, git/, zsh/, nvim/, etc. remain for reference but are not actively managed
- **Active management**: All configuration now managed through the `home/` directory structure

## System Requirements

- Git, curl (for bootstrap process)
- Support for Unicode and Nerd Fonts
- Platform support: macOS (via Homebrew), Ubuntu/Debian (via apt), Windows (via winget)
- Ansible for automated package installation
- chezmoi (installed automatically by bootstrap script)