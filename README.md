# 🚀 Modern Dotfiles

Cross-platform dotfiles for macOS, Linux, and WSL. Automated setup with interactive or non-interactive installation.

## ⚡ Quick Start

**One-line installation**:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/jeremyspofford/dotfiles/main/scripts/bootstrap.sh)
```

This downloads the repository and runs the interactive setup. You'll be prompted to:
1. Configure personal settings (name, email, editor preference)
2. Select which applications to install via checkbox menu
3. Confirm before any system changes

**Already cloned?** Just run:
```bash
cd ~/workspace/dotfiles
./scripts/setup.sh
```

**Automated/Non-interactive**:
```bash
# Edit .config to set preferences first
vim .config
./scripts/setup.sh --non-interactive
```

### 🖥️ Server/Minimal Profile

For headless servers and compute nodes (no GUI apps):
```bash
cd ~/workspace/dotfiles
cp .config.server .config
./scripts/setup.sh
```

This installs only:
- Zsh + Oh My Zsh
- Tmux
- Neovim
- Mise (with tools commented out - uncomment what you need in `~/.config/mise/config.toml`)

## ✨ What's Included

### Core Tools
| Category | What You Get |
|----------|--------------|
| **Shell** | Zsh + Oh My Zsh, bash, custom aliases, completions |
| **Terminal** | Ghostty (TokyoNight theme) |
| **Multiplexer** | tmux (Catppuccin theme) + TPM |
| **Editor** | Neovim (LazyVim) with Copilot, Avante, Aider |
| **Git** | Multi-identity SSH, delta diff, GitHub CLI |
| **Runtime Manager** | mise (manages 40+ dev tools, see config.toml) |
| **Package Manager** | GNU Stow for dotfiles |

### Available Applications (16)
Select during setup or configure in `.config`:

**System Tools**: Zsh, Tmux, Neovim, mise, mdview (Markdown viewer)

**Terminals & IDEs**: Ghostty, Cursor (AI IDE), Antigravity (Google IDE), VS Code

**Browsers**: Google Chrome, Brave

**Productivity**: Obsidian (notes), Notion, 1Password, Claude Desktop

**Development**: Orca Slicer (3D printing)

## 🔄 How It Works

1. **Bootstrap** - Downloads repo to `~/workspace/dotfiles`
2. **Configuration** - Prompts for personal settings (name, email, preferences)
3. **Backup** - Saves existing dotfiles to `~/.dotfiles-backup/TIMESTAMP/`
4. **Application Selection** - Interactive checkbox menu or automated via `.config`
5. **Installation** - Installs selected tools and applications
6. **Symlinking** - Uses GNU Stow to symlink `home/` → `~/`
7. **Tool Setup** - Configures git, generates SSH keys, installs mise tools

**Key Features**:
- ✅ **Idempotent** - Safe to run multiple times
- ✅ **Non-destructive** - Always backs up before changes
- ✅ **Flexible** - Interactive or automated modes
- ✅ **Reversible** - `--revert` restores from backup

## 📁 Repository Structure

```
dotfiles/
├── scripts/
│   ├── setup.sh                   # Main entry point (interactive/non-interactive)
│   ├── unified_app_manager.sh     # Application installer (16 apps)
│   ├── bootstrap.sh               # One-line remote installer
│   ├── lib/                       # Shared libraries (logger, config)
│   └── install/                   # Platform-specific installers
├── home/                          # Dotfiles (stowed to ~/)
│   ├── .zshrc, .bashrc            # Shell configurations
│   ├── .tmux.conf                 # Tmux with Catppuccin theme
│   ├── .gitconfig                 # Git with delta diff viewer
│   ├── .secrets.template          # API keys template (not tracked)
│   ├── .zshrc.local.template      # Machine-specific overrides
│   └── .config/
│       ├── ghostty/config         # Terminal (TokyoNight theme)
│       ├── nvim/                  # LazyVim + AI plugins
│       ├── mise/config.toml       # Tool versions (40+ tools)
│       ├── git/identity.gitconfig.template  # Git identity (not tracked)
│       └── Code/                  # VS Code/Cursor settings
├── .config.template               # User preferences template
├── .config                        # Your settings (not tracked)
└── docs/cheatsheets/              # Quick reference guides
    ├── git-identities.md          # Multi-account SSH setup
    ├── neovim.md, neovim-ai.md    # Editor shortcuts
    └── tmux.md                    # Multiplexer commands
```

## 🔧 Customization

The setup script creates `.config` from `.config.template` on first run. Edit this file to control all aspects of your setup.

### Configuration File

**Location**: `~/workspace/dotfiles/.config` (not tracked in git)

**First-time setup**: The script will prompt you for essential values:
- Git name and email
- Preferred editor (nvim, cursor, vscode, vim)
- Default shell (zsh, bash)
- Which applications to install

**Manual editing**:
```bash
cd ~/workspace/dotfiles
cp .config.template .config  # If doesn't exist
vim .config
```

**Key settings in `.config`**:
- `GIT_USER_NAME`, `GIT_USER_EMAIL` - Git identity
- `PREFERRED_EDITOR`, `DEFAULT_SHELL` - Tool preferences
- `INSTALL_ZSH="true"` - Control which apps install
- `NODE_VERSION`, `PYTHON_VERSION` - Runtime versions
- `PREFERRED_TERMINAL`, `COLOR_SCHEME` - UI preferences

### Git Identity

For multi-account setups (personal/work):

```bash
cp ~/.config/git/identity.gitconfig.template ~/.config/git/identity.gitconfig
vim ~/.config/git/identity.gitconfig
```

See [Multi-Identity SSH](#-multi-identity-ssh) section below.

### Secrets

Store API keys and sensitive data:

```bash
cp ~/.secrets.template ~/.secrets
vim ~/.secrets
```

Add to your shell: `source ~/.secrets`

### Local Overrides

Machine-specific shell config (not tracked):

```bash
cp ~/.zshrc.local.template ~/.zshrc.local
vim ~/.zshrc.local
```

Automatically sourced by `.zshrc` if present.

### Application Selection

Control which applications get installed:

**Interactive Mode** (default):
```bash
./scripts/setup.sh
# Shows checkbox menu with apps pre-selected based on .config
```

**Non-Interactive Mode** (for automation):
```bash
# Edit .config to set INSTALL_* variables
vim .config

# Run without interactive prompts
./scripts/setup.sh --non-interactive
```

**Configuration Variables**:
All applications have `INSTALL_*` variables in `.config`:
- `INSTALL_ZSH="true"` - Zsh shell
- `INSTALL_NEOVIM="true"` - Neovim editor
- `INSTALL_GHOSTTY="true"` - Ghostty terminal
- `INSTALL_CHROME="true"` - Google Chrome
- See `.config.template` for complete list

**Note**: Non-interactive mode only installs apps, never uninstalls. Use interactive mode to uninstall.

## 🔑 Multi-Identity SSH

Use different SSH keys for personal/work:

```bash
# Clone with work key
git clone git@github.com-work:org/repo.git

# Clone with personal key (default)
git clone git@github.com:user/repo.git
```

See [docs/cheatsheets/git-identities.md](docs/cheatsheets/git-identities.md) for setup.

## 📚 Cheatsheets

- [Tmux](docs/cheatsheets/tmux.md) - Sessions, windows, panes
- [Neovim](docs/cheatsheets/neovim.md) - LazyVim keybindings
- [Neovim AI](docs/cheatsheets/neovim-ai.md) - Copilot, Avante, Aider
- [Git Identities](docs/cheatsheets/git-identities.md) - Multi-account setup

## 🔄 Syncing Changes

**After editing dotfiles**:
```bash
cd ~/workspace/dotfiles
git add .
git commit -m "Update dotfiles"
git push
```

**On another machine**:
```bash
cd ~/workspace/dotfiles
git pull
./scripts/setup.sh --update  # Re-stow symlinks without reinstalling
```

The `--update` flag only re-creates symlinks, skipping package installation.

## 🛠️ Commands Reference

### Setup Script

```bash
./scripts/setup.sh                    # Interactive setup (prompts for config)
./scripts/setup.sh --non-interactive  # Automated setup (uses .config)
./scripts/setup.sh --update           # Re-stow dotfiles without reinstalling
./scripts/setup.sh --revert           # Restore from latest backup
./scripts/setup.sh --revert=20260113  # Restore from specific backup
./scripts/setup.sh --minimal          # Dotfiles only, skip packages
./scripts/setup.sh --help             # Show all options
```

### Application Manager

```bash
./scripts/unified_app_manager.sh                    # Interactive app selection
./scripts/unified_app_manager.sh --non-interactive  # Install from .config
```

### Manual Dotfile Management

```bash
cd ~/workspace/dotfiles
stow --restow home           # Re-create all symlinks
stow --delete home           # Remove all symlinks
stow --adopt home            # Pull system files into repo
```

## 🌐 Platform Support

| Platform | Status |
|----------|--------|
| macOS | ✅ Full support (Homebrew, Ghostty) |
| Linux | ✅ Debian/Ubuntu (apt) - others experimental |
| WSL | ✅ With clipboard integration |

## 📄 License

MIT
