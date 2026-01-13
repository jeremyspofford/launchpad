# Scripts Directory

Essential scripts for managing the dotfiles repository and system setup.

## Overview

This directory contains automation scripts that handle installation, validation, synchronization, and maintenance of the dotfiles system.

## Scripts

### `setup.sh` - Main Installation Script

The primary entry point for setting up the dotfiles system.

**Usage:**

```bash
./scripts/setup.sh [OPTIONS]

Options:
  -h, --help              Show help message
  -f, --force             Force all tasks to run
  --minimal               Skip package installation
  --update                Re-stow dotfiles only
  --revert                Restore backups
  --create-restore-point  Create system snapshot (Timeshift)
```

**What it does:**

- Auto-detects operating system
- Creates backups of existing configurations
- Creates system restore points (optional Timeshift)
- Delegates application installation to `unified_app_manager.sh`
- Configures GNU Stow to symlink dotfiles
- Provides setup summary and next steps

### `unified_app_manager.sh` - Application Manager

The core logic for installing, uninstalling, and managing applications.

**Usage:**

```bash
./scripts/unified_app_manager.sh
```

**Features:**
- Interactive menu (whiptail) for selecting applications
- Handles installation of System Tools (Zsh, Tmux, Neovim)
- Installs GUI Apps (Ghostty, Browsers, etc.)
- Manages uninstallation of unchecked items
- Robust detection of installed packages
- Font setup guide integration

### `validate-setup.sh` - System Validation

Comprehensive validation script that verifies the dotfiles setup is working correctly.

**Usage:**

```bash
./scripts/validate-setup.sh
```

**Checks performed:**

- Verifies required tools are installed
- Validates symlinks are properly created
- Tests shell configuration loading
- Validates Git configuration
- Tests SSH key setup
- Ensures Neovim configuration is working

### `sync.sh` - Dotfiles Synchronization

Synchronizes dotfiles across machines and handles updates.

**Usage:**

```bash
./scripts/sync.sh [OPTIONS]
```

**What it does:**

- Pulls latest changes from Git repository
- Re-runs stow operations to ensure symlinks are current
- Updates package installations if needed

### `utils.sh` - Shared Utilities

Common utility functions used by other scripts.

**Functions:**

- Logging and output formatting
- Operating system detection
- Error handling helpers
- File and directory utilities

### `doc-update-hook.sh` - Documentation Hook

Claude Code integration hook for automatic documentation updates.

**Purpose:**

- Automatically triggered when code changes are detected
- Updates relevant documentation to stay in sync with implementation

## Platform Support

Currently, the scripts are optimized for:
- **Linux** (Debian/Ubuntu 22.04+) - Full application support
- **macOS** - Basic dotfile linking (application support via Homebrew pending update)
- **WSL2** - Fully supported

## Error Handling

Scripts use comprehensive error handling:

- **Exit codes**: Non-zero exit codes indicate failures
- **Logging**: All operations are logged with timestamps
- **Rollback**: Failed operations attempt to rollback changes

## File Structure

```
scripts/
├── README.md              # This file
├── setup.sh              # Main entry point
├── unified_app_manager.sh # Application installer
├── validate-setup.sh      # System validation
├── sync.sh               # Synchronization tool
├── utils.sh              # Shared libraries
└── doc-update-hook.sh    # Documentation hook
```