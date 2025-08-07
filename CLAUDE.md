# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Modern, streamlined dotfiles repository using chezmoi for cross-platform management. Designed for immediate productivity with minimal configuration.

## Key Commands

### Installation
```bash
# Full installation
./install-new.sh

# Legacy installer (being phased out)
./install.sh
```

### Daily Operations
```bash
# Edit configs
chezmoi edit ~/.zshrc

# Apply changes
chezmoi apply

# Update from repo
chezmoi update

# Sync changes
chezmoi git add .
chezmoi git commit -m "Update"
chezmoi git push
```

### Development Tools
```bash
# Manage versions with mise
mise use node@20
mise use python@3.11

# Claude CLI
claude login
claude chat

# Neovim (kickstart.nvim)
nvim  # Plugins auto-install on first run

# Cloud CLI tools
aws configure    # Setup AWS credentials
az login         # Login to Azure
gcloud auth login # Login to Google Cloud
```

## Architecture

### Core Structure
- **install-new.sh**: Streamlined installer with all essentials
- **home/**: Chezmoi-managed dotfiles (dot_ prefix convention)
- **ansible/**: Cross-platform package installation
- **.chezmoi.toml.tmpl**: User configuration template

### Key Features
1. **Single Command Setup**: Clone and run install-new.sh
2. **Cross-Platform**: macOS (Homebrew), Linux/WSL2 (apt)
3. **Modern Tools**: fzf, ripgrep, bat, eza, tldr, zoxide
4. **Version Management**: mise for all language versions
5. **AI Integration**: Claude CLI pre-configured
6. **Smart Git**: Directory-based email switching
7. **Nerd Fonts**: JetBrainsMono automatically installed
8. **Cloud CLI Tools**: AWS CLI, Azure CLI, Google Cloud SDK with prompt integration

### Configuration Files
- **dot_zshrc**: Modern zsh with plugins and aliases
- **dot_gitconfig.tmpl**: Templated git with conditional includes
- **dot_tmux.conf**: Sensible tmux configuration
- **dot_config/starship/**: Minimal, clean prompt

## Code Quality Standards

### File Standards (CRITICAL - Always Follow)
- **🚨 ALL FILES MUST END WITH A BLANK LINE** - This is non-negotiable for ANY file you create or edit
- **Remove trailing whitespace** from all lines
- **Use UTF-8 encoding** and Unix line endings (LF)
- **Use consistent indentation** (2 spaces for YAML, 4 for Python, etc.)

### File Editing Rules (MANDATORY)
Every time you edit a file:
1. **Verify the file ends with a blank line** after your changes
2. **Remove any trailing whitespace** you may have introduced
3. **Maintain the file's existing indentation style**
4. **Test your changes work correctly**

### Linting Requirements
- **Always run linters** before committing any file
- **Shell scripts**: Use `shellcheck script.sh`
- **YAML files**: Use `yamllint file.yaml` 
- **Markdown**: Use `markdownlint file.md`
- **Fix all linter warnings and errors**

### Shell Script Standards
- Use `#!/usr/bin/env bash` shebang
- Include `set -euo pipefail` for error handling
- Add header comments explaining script purpose
- Quote all variables: `"$variable"`
- Use `readonly` for constants
- End all functions and scripts with blank line

### Documentation Standards
- Update README.md when adding features
- Add inline comments for complex configurations
- Include usage examples in script headers
- Keep CLAUDE.md updated with new commands/workflows

### Pre-commit Checklist
Before committing ANY file:
1. Run appropriate linter
2. Ensure file ends with blank line
3. Remove trailing whitespace
4. Test functionality
5. Check for no secrets/credentials

See CODING_STANDARDS.md for complete guidelines.

## Important Notes

- Neovim uses kickstart.nvim (cloned separately to ~/.config/nvim)
- Old nvim configs removed from home/dot_config/
- Fabric patterns removed (2.7MB of unused configs)
- Simplified from 10+ config directories to essentials only
- Git automatically switches email based on directory (~/work/, ~/personal/)
- All tools work immediately after installation