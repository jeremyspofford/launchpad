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
  -h, --help     Show help message
  -f, --force    Force all tasks to run (skip idempotency checks)
  -v, --verbose  Enable verbose output
  -n, --dry-run  Preview what would be done without making changes
```

**What it does:**

- Auto-detects operating system (macOS, Linux, WSL)
- Installs prerequisites (Homebrew on macOS, Ansible)
- Runs Ansible playbook for package installation
- Installs Oh My Zsh if not present
- Configures GNU Stow to symlink dotfiles
- Provides setup summary and next steps

**Examples:**

```bash
# Standard installation
./scripts/setup.sh

# Force all tasks to run
./scripts/setup.sh --force

# Preview what would happen
./scripts/setup.sh --dry-run
```

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
- Checks Oh My Zsh installation
- Validates Git configuration
- Tests SSH key setup
- Ensures Neovim configuration is working

### `sync.sh` - Dotfiles Synchronization

Synchronizes dotfiles across machines and handles updates.

**Usage:**

```bash
./scripts/sync.sh [OPTIONS]

Options:
  -h, --help     Show help message
  -n, --dry-run  Preview sync operations
  -v, --verbose  Enable verbose output
  -f, --force    Force sync operations
```

**What it does:**

- Pulls latest changes from Git repository
- Re-runs stow operations to ensure symlinks are current
- Updates package installations if needed
- Handles merge conflicts and symlink issues

### `utils.sh` - Shared Utilities

Common utility functions used by other scripts.

**Functions:**

- Logging and output formatting
- Operating system detection
- Error handling helpers
- File and directory utilities
- Color output functions

**Usage:**

```bash
# Source in other scripts
source "$(dirname "$0")/utils.sh"

# Use utility functions
log "Installation starting..."
detect_os
handle_error "Something went wrong"
```

### `doc-update-hook.sh` - Documentation Hook

Claude Code integration hook for automatic documentation updates.

**Purpose:**

- Automatically triggered when code changes are detected
- Updates relevant documentation to stay in sync with implementation
- Ensures README files and configuration docs remain accurate

**Setup:**

- Configured as a Claude Code hook in `.claude/settings.json`
- Runs automatically during development workflow
- Can be manually triggered for doc updates

## Dependencies

### External Dependencies

- **Bash 4.0+** - All scripts require modern Bash
- **curl** - For downloading external resources
- **git** - For repository operations
- **GNU Stow** - For symlink management (installed automatically)

### Internal Dependencies

- `utils.sh` is sourced by most other scripts
- Scripts assume they're run from the repository root
- Ansible playbooks are called by `setup.sh`

## Platform Support

All scripts support:

- **macOS** (including Apple Silicon)
- **Linux** (Debian/Ubuntu, RHEL/CentOS)  
- **WSL2** (Windows Subsystem for Linux)

Platform detection is automatic and handled by `utils.sh`.

## Error Handling

Scripts use comprehensive error handling:

- **Exit codes**: Non-zero exit codes indicate failures
- **Logging**: All operations are logged with timestamps
- **Rollback**: Failed operations attempt to rollback changes
- **Validation**: Input validation prevents common issues

## Best Practices

### Running Scripts

- Always run from repository root: `./scripts/script-name.sh`
- Use `--dry-run` first to preview changes
- Check exit codes: `./scripts/setup.sh && echo "Success!"`

### Development

- Follow existing code style and error handling patterns
- Add appropriate logging and validation
- Test on multiple platforms before committing
- Update this README when adding new scripts

## Troubleshooting

### Common Issues

**Permission denied:**

```bash
chmod +x scripts/*.sh
```

**Script not found:**

```bash
# Ensure you're in repository root
cd ~/dotfiles
./scripts/setup.sh
```

**Stow conflicts:**

```bash
# Use force mode to override
./scripts/setup.sh --force
```

### Getting Help

- Use `--help` flag with any script for detailed usage
- Check log output for specific error messages
- Run `validate-setup.sh` to diagnose system state
- Review CLAUDE.md for project context

## File Structure

```
scripts/
├── README.md           # This file
├── setup.sh           # Main installation script  
├── validate-setup.sh   # System validation
├── sync.sh            # Dotfiles synchronization
├── utils.sh           # Shared utility functions
└── doc-update-hook.sh # Documentation automation hook
```
