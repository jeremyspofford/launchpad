# Changelog

All notable changes to this dotfiles repository will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-01-13

### Changed
- **BREAKING**: Migrated from GNU Stow to chezmoi for dotfile management
- **BREAKING**: Reorganized all dotfiles into `home/` directory structure
- Updated installation process to use chezmoi initialization
- Replaced manual stow commands with chezmoi apply workflow

### Added
- Cross-platform compatibility (macOS, Linux, Windows)
- Template-based configuration system via chezmoi
- Automated package installation via Ansible playbooks
- Windows application installer (`install.ps1`) with winget integration
- Extensive fabric AI pattern library (200+ patterns)
- chezmoi configuration file (`.chezmoi.toml`) with user prompts
- Enhanced shell configuration with modern CLI tools
- Starship prompt configuration
- mise version manager integration
- Comprehensive documentation updates

### Enhanced
- Installation script (`install.sh`) with better error handling
- Git configuration now uses templates for cross-platform compatibility
- SSH key management with automated generation
- Zsh configuration with modern tool integration

### Removed
- Legacy directory structure (`bash/`, `git/`, `zsh/`, `nvim/`, etc.)
- GNU Stow dependency and configuration
- Platform-specific installation scripts (consolidated into single script)

### Migration Notes
- Users upgrading from v1.x should backup existing configurations
- Run `./install.sh` to migrate to the new chezmoi-based system
- Legacy dotfiles will be automatically backed up during installation
- Use `chezmoi` commands instead of `stow` for managing dotfiles

## [1.x.x] - Historical

### Features (Legacy Stow-based System)
- GNU Stow-based dotfile management
- Basic shell configuration (bash/zsh)
- Git configuration
- Neovim setup
- Manual installation scripts per platform
- Basic package management

---

## Migration Guide from v1.x to v2.0

1. **Backup your current dotfiles**: The installer will do this automatically
2. **Clone the new repository**: `git clone https://github.com/jeremyspofford/dotfiles.git`
3. **Run the new installer**: `./dotfiles/install.sh`
4. **Follow the prompts**: Provide email, name, and GitHub username
5. **Verify the setup**: Use `chezmoi status` to see managed files
6. **Remove legacy backups**: After confirming everything works

### New Commands to Learn
- `chezmoi apply` - Apply configuration changes
- `chezmoi edit <file>` - Edit dotfiles with template support
- `chezmoi update` - Pull and apply remote changes
- `chezmoi diff` - See what would change
- `chezmoi status` - View current state