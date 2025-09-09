# Changelog

All notable changes to this dotfiles repository will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.0.0] - 2024-09-09

### 🚀 Major Migration: Chezmoi to GNU Stow

### ✨ Added
- **GNU Stow integration** - Complete migration from chezmoi to stow for dotfile management
- **Streamlined shell configuration** - New `.commonrc` for shared bash/zsh configurations
- **OS-adaptive aliases** - Platform-specific commands (start=open/explorer.exe/xdg-open)
- **One-command setup** - `./scripts/setup.sh` handles Ansible, Oh My Zsh, and stow operations
- **Oh My Zsh plugin management** - Proper plugin loading without conflicts

### 🔧 Changed
- **Repository structure** - `home/` directory now directly mirrors `~/` for stow compatibility  
- **Shell configuration architecture** - Eliminated duplication between `.bashrc` and `.zshrc`
- **Setup process** - Simplified from complex chezmoi workflow to single script execution
- **Documentation** - Updated README.md and CLAUDE.md to reflect new stow-based workflow

### 🗑️ Removed
- **Chezmoi dependencies** - Completely removed chezmoi configuration and templates
- **Fabric integration** - Removed all fabric-related aliases and configurations
- **Obsidian aliases** - Cleaned out obsidian-specific shortcuts
- **Duplicate configurations** - Eliminated redundant environment variables and PATH exports
- **Legacy plugin loading** - Removed manual zsh plugin loading that conflicted with Oh My Zsh

### 🐛 Fixed
- **Zsh exit code 130** - Resolved plugin loading conflicts causing terminal crashes
- **Stow package structure** - Fixed directory organization for proper symlink creation
- **Ansible playbook** - Corrected gnu_stow task configuration
- **History file management** - Separated bash and zsh history locations
- **Platform detection** - Improved WSL vs native Linux detection

### 📋 Migration Notes
This is a **breaking change** for existing users. The repository has been completely restructured around GNU Stow. Users should:
1. Back up existing configurations
2. Run `./scripts/setup.sh` for fresh installation
3. Verify symlinks with `ls -la ~ | grep '\->'`

## [2.1.0] - 2025-01-07

### 🧹 Major Cleanup & UX Improvements

### ✨ Added
- **Enhanced SSH key generation UX** - colorized output with clear GitHub instructions and direct link to https://github.com/settings/keys
- **Improved error handling** - better chezmoi template variable management and robust installation
- **Streamlined repository** - removed 2.9MB of unused files and configurations

### 🔧 Changed  
- **SSH key setup** - beautiful colored interface with step-by-step GitHub integration
- **Documentation consolidation** - unified README replaces multiple versions
- **Repository structure** - removed legacy development artifacts and unused configs

### 🗑️ Removed  
- **Legacy documentation** - old `docs/` directory (faq, installation, troubleshooting, usage)
- **Development artifacts** - Dockerfiles, test scripts, verification tools  
- **Unused configurations** - VS Code, Kitty, duplicate tmux configs
- **Fabric AI patterns** - complete removal of 300+ unused pattern files (2.7MB saved)
- **Testing infrastructure** - Docker containers, verification scripts

### 🐛 Fixed
- **Neovim installation conflicts** - robust handling of broken symlinks and existing configs
- **chezmoi template errors** - proper variable initialization for SSH key generation
- **GitHub Actions reliability** - improved YAML syntax and error handling
- **Package installation issues** - removed problematic packages not available in repos

## [Unreleased] - 2024-08-07

### Added
- **New streamlined installer** (`install-new.sh`) with single-command setup
- **GitHub CLI integration** with automatic installation and useful aliases (`ghpr`, `ghpv`, etc.)
- **JetBrainsMono Nerd Font** automatic installation across platforms
- **kickstart.nvim integration** - replaces multiple nvim configurations with official setup
- **Claude CLI** automatic installation and configuration via npm
- **Comprehensive coding standards** (CODING_STANDARDS.md) with file formatting rules
- **Code quality tools** (shellcheck, yamllint) automatically installed and configured
- **Smart git configuration** with directory-based email switching (work/personal)
- **Modern shell aliases** for productivity and linting (`lint-sh`, `lint-yaml`, `lint-all`)
- **Enhanced starship prompt** with clean, minimal design and language detection
- **Security scanning** - comprehensive security audit completed
- **Linting aliases** and quality assurance tools built into shell

### Changed
- **BREAKING**: Streamlined from complex multi-config to essential-tools-only approach
- **Removed 2.7MB of fabric patterns** - kept only core productivity tools
- **Simplified nvim setup** - removed multiple configurations, uses kickstart.nvim instead
- **Modernized zshrc** with current best practices and tool integrations
- **Enhanced tmux configuration** with vim-like bindings and modern colors
- **Improved git config** with delta diff, better aliases, and conditional email includes
- **Updated installation process** with better cross-platform support and error handling
- **Streamlined starship config** from complex themed to clean minimal design

### Removed
- **Fabric AI patterns directory** (home/dot_config/fabric/ - 2.7MB freed)
- **Multiple nvim configurations** (craftzdog, nvchad, xero configs)
- **Legacy shell configurations** (consolidated into single modern zshrc)
- **Unused dotfile directories** and redundant configurations
- **Complex installation menus** (replaced with smart defaults)

### Security
- **Security audit completed** - no critical vulnerabilities or secrets found
- **Shell script security** enhanced following shellcheck recommendations
- **Proper secrets management** with comprehensive .gitignore
- **File permissions** correctly configured (644 for configs, 755 for scripts)
- **Supply chain security** noted for future improvements

### Technical Improvements
- **All files now end with blank lines** (enforced coding standard)
- **Trailing whitespace removed** from all configurations
- **Consistent indentation** applied throughout
- **Linting tools integrated** into installation and daily workflow
- **Cross-platform font installation** working on macOS, Linux, WSL2
- **Error handling improved** in all shell scripts

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
2. **Clone the new repository**: `git clone https://github.com/yourusername/dotfiles.git`
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