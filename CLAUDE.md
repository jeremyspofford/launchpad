# Project Context for AI Assistants

## Overview

Cross-platform dotfiles repository for macOS, Linux, and WSL. Uses GNU Stow for symlink management and shell scripts for installation.

## Repository Structure

```
dotfiles/
├── scripts/
│   ├── setup.sh              # Main entry point
│   └── install/              # Platform-specific installers
│       ├── common.sh         # Cross-platform (mise, stow, Oh My Zsh)
│       ├── macos.sh          # Homebrew, casks, fonts
│       ├── linux.sh          # apt/dnf/pacman
│       └── wsl.sh            # WSL-specific tweaks
├── home/                     # Dotfiles (mirrors ~/ via stow)
│   ├── .zshrc, .bashrc       # Shell configs
│   ├── .tmux.conf            # Tmux with Catppuccin
│   ├── .gitconfig            # Git with delta
│   ├── .ssh/config           # Multi-identity SSH
│   └── .config/
│       ├── ghostty/          # Terminal config
│       ├── nvim/             # LazyVim + AI plugins
│       ├── mise/             # Runtime versions
│       ├── git/              # Identity templates
│       └── Code/             # VS Code/Cursor settings
└── docs/cheatsheets/         # Quick reference guides
```

## Key Features

- **Shell-based setup** - No Ansible dependency, pure bash scripts
- **Multi-platform** - macOS, Linux (apt/dnf/pacman), WSL
- **Theme** - Catppuccin with auto dark/light mode
- **AI tools** - Neovim with Copilot, Avante, Aider
- **Multi-identity Git/SSH** - Personal and work accounts

## Important Files

| File | Purpose |
|------|---------|
| `scripts/setup.sh` | Single entry point for installation |
| `home/.config/mise/mise.toml` | Runtime versions (27+ tools) |
| `home/.secrets.template` | 1Password secrets template |
| `home/.config/git/identity.gitconfig.template` | Git identity (not tracked) |

## Development Commands

```bash
./scripts/setup.sh          # Full setup
./scripts/setup.sh --stow   # Only symlink dotfiles
stow --restow home          # Re-symlink after changes
```

## Security Notes

- Never commit secrets to the repository
- `.secrets` and identity configs are in `.gitignore`
- SSH private keys (`id_*`) are excluded
- Use templates for sensitive configuration
