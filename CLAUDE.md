# Project Context for AI Assistants

## Overview

Cross-platform dotfiles repository for macOS, Linux, and WSL. Uses GNU Stow for symlink management and shell scripts for installation.

## Repository Structure

```
dotfiles/
├── scripts/
│   ├── setup.sh                    # Main entry point
│   ├── unified_app_manager.sh      # Interactive app installer
│   ├── validate-setup.sh           # System validation
│   ├── bootstrap.sh                # Quick start from GitHub
│   ├── sync-secrets.sh             # 1Password integration
│   ├── remove-docker-desktop*.sh   # Docker management
│   ├── uninstall-docker-engine.sh  # Docker removal
│   └── install/                    # Platform-specific installers
│       ├── common.sh               # Cross-platform
│       ├── linux.sh                # apt/dnf/pacman
│       ├── macos.sh                # Homebrew
│       └── wsl.sh                  # WSL-specific
├── home/                           # Dotfiles (mirrors ~/ via stow)
│   ├── .zshrc                      # Zsh config with PATH
│   ├── .tmux.conf                  # Tmux with Catppuccin
│   ├── .gitconfig                  # Git with delta
│   ├── .ssh/config                 # Multi-identity SSH
│   ├── .secrets.template           # 1Password secrets template
│   └── .config/
│       ├── ghostty/                # Terminal config
│       ├── nvim/                   # LazyVim + AI plugins
│       ├── mise/                   # Runtime versions (27+ tools)
│       ├── git/                    # Identity templates
│       ├── Code/                   # VS Code/Cursor settings
│       └── .gemini/                # Gemini IDE config
├── docs/
│   ├── cheatsheets/                # Quick reference guides
│   ├── USAGE.md                    # Usage instructions
│   ├── RESTORE.md                  # Restore procedures
│   └── TERMINAL_FONT_SETUP.md      # Font installation guide
├── templates/                      # Reusable script templates
├── CLAUDE.md                       # This file
├── GEMINI.md                       # Gemini IDE context
└── README.md                       # User-facing documentation
```

## Key Features

- **Shell-based setup** - Pure bash scripts, no Ansible
- **Multi-platform** - macOS, Linux (apt/dnf/pacman), WSL
- **Interactive installer** - Whiptail menu for app selection
- **Automatic backups** - All dotfiles backed up before changes
- **Theme** - Catppuccin with auto dark/light mode
- **AI tools** - Neovim with Copilot, Avante, Aider
- **Multi-identity Git/SSH** - Personal and work accounts
- **1Password integration** - Secrets managed via 1Password CLI

## Important Files

| File | Purpose |
|------|---------|
| `scripts/setup.sh` | Single entry point for installation |
| `scripts/unified_app_manager.sh` | Interactive app installer (replaces old install_gui_apps.sh) |
| `home/.config/mise/mise.toml` | Runtime versions (27+ tools including Claude, Gemini) |
| `home/.secrets.template` | 1Password secrets template |
| `home/.config/git/identity.gitconfig.template` | Git identity (not tracked) |
| `home/.zshrc` | Shell config with ~/.local/bin in PATH |

## Development Commands

```bash
./scripts/setup.sh                  # Full setup
./scripts/setup.sh --update         # Re-stow dotfiles only
./scripts/setup.sh --revert         # Restore from backups
./scripts/unified_app_manager.sh    # Run app installer standalone
stow --restow home                  # Re-symlink after changes
```

## Application Management

Applications are managed via `unified_app_manager.sh`:
- System tools: Zsh, Tmux, Neovim, mise, mdview
- Terminals: Ghostty
- IDEs: Cursor, VS Code, Antigravity
- Browsers: Chrome, Brave
- Productivity: Obsidian, Notion, 1Password, Claude Desktop
- Development: Orca Slicer

**Note:** Docker is NOT in the unified manager. Install via mise or use provided removal scripts.

## Security Notes

- Never commit secrets to the repository
- `.secrets` and identity configs are in `.gitignore`
- SSH private keys (`id_*`) are excluded
- Claude credentials (`home/.claude/.credentials.json`) are excluded
- Use templates for sensitive configuration
- 1Password CLI integration for secrets management

## Recent Changes

- Removed `install_gui_apps.sh` (replaced by unified_app_manager.sh)
- Removed `sync.sh` (duplicate of setup.sh)
- Removed `ubuntu-setup-guide.md` (outdated)
- Removed Docker Desktop from unified manager (use mise or manual install)
- Added Orca Slicer with icon and desktop entry support
- Fixed stow symlink conflict handling
- Added ~/.local/bin to PATH for AppImages

## Common Issues

### Stow conflicts
Run `./scripts/setup.sh` - it now handles broken symlinks automatically.

### Docker Desktop won't open
Use `./scripts/remove-docker-desktop-only.sh` to remove it. Docker Desktop is unnecessary on Linux (runs in VM). Install Docker Engine via mise or apt instead.

### Missing icons for AppImages
The unified manager now downloads and installs icons automatically for supported apps (Orca Slicer, etc.).
