# 🚀 Modern Dotfiles

Cross-platform dotfiles for macOS, Linux, and WSL. Clone, run one command, start working.

## ⚡ Quick Start

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/jeremyspofford/dotfiles/main/scripts/bootstrap.sh)
./scripts/setup.sh
```

**First-time setup**: The script will prompt you for essential configuration (name, email, preferences). You can skip and edit `.config` manually later.

## ✨ What's Included

| Category | Tools |
|----------|-------|
| **Shell** | Zsh + Oh My Zsh, bash, common aliases |
| **Terminal** | Ghostty, tmux with TPM |
| **Editor** | Neovim (LazyVim) with AI plugins |
| **Git** | Multi-identity SSH, delta diff viewer |
| **Tools** | mise for runtimes, stow for symlinks |
| **Theme** | TokyoNight (auto dark/light mode) |

## 📁 Structure

```
dotfiles/
├── scripts/
│   ├── setup.sh              # Main entry point
│   └── install/              # Platform-specific scripts
├── home/                     # Dotfiles (mirrors ~/)
│   ├── .zshrc, .bashrc       # Shell configs
│   ├── .tmux.conf            # Tmux with Catppuccin
│   ├── .gitconfig            # Git with delta
│   └── .config/
│       ├── ghostty/          # Terminal config
│       ├── nvim/             # LazyVim + AI plugins
│       ├── mise/             # Runtime versions
│       └── Code/             # VS Code/Cursor settings
└── docs/cheatsheets/         # Quick reference guides
```

## 🔧 Customization

### Git Identity

Set up your Git identity (not tracked):

```bash
cp ~/.config/git/identity.gitconfig.template ~/.config/git/identity.gitconfig
vim ~/.config/git/identity.gitconfig
```

### Secrets

Store API keys and sensitive data:

```bash
cp ~/.secrets.template ~/.secrets
vim ~/.secrets
```

### Local Overrides

Machine-specific config (not tracked):

```bash
cp ~/.zshrc.local.template ~/.zshrc.local
```

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

```bash
cd ~/workspace/dotfiles
git add .
git commit -m "Update dotfiles"
git push
```

On another machine:
```bash
cd ~/workspace/dotfiles
git pull
./scripts/setup.sh --stow  # Just re-symlink
```

## 🛠️ Manual Commands

```bash
./scripts/setup.sh          # Full setup
./scripts/setup.sh --update # Re-stow after git pull
./scripts/setup.sh --revert # Restore from backups
./scripts/setup.sh --help   # Show all options
```

## 🌐 Platform Support

| Platform | Status |
|----------|--------|
| macOS | ✅ Full support (Homebrew, Ghostty) |
| Linux | ✅ Debian/Ubuntu (apt) - others experimental |
| WSL | ✅ With clipboard integration |

## 📄 License

MIT
