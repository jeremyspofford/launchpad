# Scripts Directory

Essential scripts for managing the dotfiles repository and system setup.

## Overview

This directory contains automation scripts that handle installation, validation, and maintenance of the dotfiles system.

## Main Scripts

### `setup.sh` - Main Installation Script

The primary entry point for setting up the dotfiles system.

**Usage:**

```bash
./scripts/setup.sh [OPTIONS]

Options:
  --help                  Show help message
  --minimal               Install dotfiles only, skip package installation
  --update                Re-stow dotfiles without reinstalling packages
  --revert                Restore backed-up files and remove dotfile symlinks
  --revert=BACKUP         Restore from specific backup
  --list-backups          List available backups
  --non-interactive       Skip interactive tool selection
  --create-restore-point  Create Timeshift system snapshot before changes
  --skip-restore-prompt   Don't prompt for restore point creation
```

**What it does:**

1. Auto-detects operating system (macOS, Linux, WSL)
2. Creates backups of existing configurations
3. Optionally creates system restore points (Timeshift)
4. Launches unified application manager for app selection
5. Configures GNU Stow to symlink dotfiles
6. Provides setup summary and next steps

### `unified_app_manager.sh` - Application Manager

Interactive application installer with whiptail menu system.

**Usage:**

```bash
./scripts/unified_app_manager.sh
```

**Features:**
- Interactive selection menu for all applications
- Install/uninstall management
- Tracks installation status
- Supports:
  - System tools (Zsh, Tmux, Neovim, mise)
  - Terminal emulators (Ghostty)
  - IDEs (Cursor, VS Code, Antigravity)
  - Browsers (Chrome, Brave)
  - Productivity apps (Obsidian, Notion, 1Password)
  - Development tools (Orca Slicer, Claude Desktop)

### `validate-setup.sh` - System Validation

Comprehensive validation script that verifies the dotfiles setup.

**Usage:**

```bash
./scripts/validate-setup.sh
```

**Checks:**
- Required tools are installed
- Symlinks are properly created
- Shell configuration loads correctly
- Git configuration is valid
- SSH keys are set up
- Neovim configuration works

### `bootstrap.sh` - Quick Start

Downloads and runs the dotfiles setup from GitHub.

**Usage:**

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/jeremyspofford/dotfiles/main/scripts/bootstrap.sh)
```

Clones the repository and initiates setup.

## Docker Scripts

### `remove-docker-desktop.sh`

Removes Docker Desktop and installs Docker Engine (native Linux approach).

### `remove-docker-desktop-only.sh`

Only removes Docker Desktop without installing anything.

### `uninstall-docker-engine.sh`

Removes Docker Engine packages.

## Utility Scripts

### `sync-secrets.sh`

Fetches secrets from 1Password and creates `~/.secrets` file.

Requires 1Password CLI and proper vault setup.

### `doc-update-hook.sh`

Claude Code integration hook for automatic documentation updates.

### `lib/logger.sh`

Shared logging utilities used by all scripts.

## Platform Support

- **Linux** (Ubuntu 22.04+) - Full support
- **macOS** - Basic dotfile linking
- **WSL2** - Full support

## Directory Structure

```
scripts/
├── README.md                     # This file
├── setup.sh                      # Main entry point
├── unified_app_manager.sh        # Application installer
├── validate-setup.sh             # System validation
├── bootstrap.sh                  # Quick start script
├── sync-secrets.sh               # 1Password integration
├── doc-update-hook.sh            # Documentation hook
├── remove-docker-desktop.sh      # Docker Desktop removal + Engine install
├── remove-docker-desktop-only.sh # Docker Desktop removal only
├── uninstall-docker-engine.sh    # Docker Engine removal
├── lib/
│   └── logger.sh                 # Logging utilities
└── install/
    ├── common.sh                 # Cross-platform installers
    ├── linux.sh                  # Linux-specific
    ├── macos.sh                  # macOS-specific
    └── wsl.sh                    # WSL-specific
```

## Error Handling

All scripts use comprehensive error handling:

- **Exit codes**: Non-zero exit codes indicate failures
- **Logging**: All operations are logged with timestamps
- **Rollback**: Failed operations attempt to rollback changes
- **Dashboards**: Visual summary of installation results

## Development

To add a new application to the unified manager:

1. Add status variable (e.g., `local myapp_status="OFF"`)
2. Add detection logic (e.g., `command_exists myapp && myapp_status="ON"`)
3. Add menu item in the whiptail dialog
4. Create `install_myapp()` function
5. Optionally create `uninstall_myapp()` function
