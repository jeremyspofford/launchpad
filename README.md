# 🚀 Modern Dotfiles

A streamlined, cross-platform dotfiles setup that gets you productive immediately. Clone, run one command, and start working.

## ✨ What's Included

- **🐚 Modern Shell**: Zsh with starship prompt and essential plugins
- **📝 Neovim**: Kickstart.nvim configuration for immediate productivity
- **🤖 Claude CLI**: AI assistant in your terminal
- **🔧 Essential Tools**: fzf, ripgrep, bat, eza, tldr, and more
- **📦 Version Management**: mise for managing Node, Python, Ruby versions
- **🎨 JetBrainsMono Nerd Font**: Beautiful terminal font with icons
- **🔄 Easy Syncing**: Chezmoi for managing and syncing dotfiles across machines
- **🌳 Smart Git Config**: Conditional includes for work/personal projects
- **🐙 GitHub CLI**: Full GitHub integration in your terminal

## 🚀 Quick Install

### One Command Setup

```bash
# Clone and install everything
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
~/dotfiles/install-new.sh
```

That's it! The installer will:
1. Install all essential packages
2. Set up Neovim with kickstart.nvim
3. Configure your shell with modern tools
4. Install JetBrainsMono Nerd Font
5. Set up Claude CLI
6. Configure git with smart defaults

### Minimal Prompts

You'll only be asked for:
- Your name (for git)
- Your email (for git)
- Your GitHub username
- Work email (optional)
- Machine type (personal/work/shared)

## 📁 Repository Structure

```
dotfiles/
├── install-new.sh          # Main installer script
├── home/                   # Chezmoi-managed dotfiles
│   ├── dot_zshrc          # Zsh configuration
│   ├── dot_gitconfig.tmpl # Git config template
│   └── dot_tmux.conf      # Tmux configuration
├── ansible/               # System package installation
└── .chezmoi.toml.tmpl    # Chezmoi configuration
```

## 🔧 Daily Usage

### Dotfile Management

```bash
# Edit any config file
chezmoi edit ~/.zshrc

# Apply changes
chezmoi apply

# Pull latest changes from repo
chezmoi update

# Add a new config file
chezmoi add ~/.newconfig

# See what would change
chezmoi diff
```

### Version Management with mise

```bash
# Install Node.js
mise use node@20

# Install Python
mise use python@3.11

# Install Ruby
mise use ruby@3.2

# List installed versions
mise list
```

### Quick Aliases

- `ll` - List files with icons
- `cm` - Chezmoi shortcut
- `v` - Open Neovim
- `gac "message"` - Git add all and commit
- `z` - Smart directory jumping with zoxide

## 🎯 Platform Support

### macOS
- Uses Homebrew for package management
- Configures macOS-specific git credentials
- Installs command-line tools via brew

### Linux (Ubuntu/Debian/WSL2)
- Uses apt for system packages
- Downloads binaries for tools not in repos
- Configures Linux-specific settings

### WSL2 Specific
- Optimized for Windows Subsystem for Linux
- Proper clipboard integration
- Windows Terminal compatible

## 🔄 Syncing Across Machines

Chezmoi makes it easy to keep your dotfiles in sync:

1. Make changes on any machine
2. Commit and push to your repo
3. On other machines, run `chezmoi update`

### Auto-sync Setup

The configuration includes auto-commit and auto-push:

```bash
# Any time you edit with chezmoi, changes are committed
chezmoi edit ~/.zshrc

# Push changes to remote
chezmoi git push
```

## 🎨 Git Configuration

### Directory-based Email Switching

Your git email automatically changes based on the directory:

- `~/work/*` - Uses work email
- `~/personal/*` - Uses personal email
- `~/opensource/*` - Uses personal email

Configure work email in `~/.gitconfig.work`:
```ini
[user]
    email = your.name@company.com
```

## 🛠️ Customization

### Local Overrides

Create `~/.zshrc.local` for machine-specific settings:

```bash
# ~/.zshrc.local
export WORK_SPECIFIC_VAR="value"
alias myalias="my command"
```

### Adding Tools

Install additional tools with mise:

```bash
# Examples
mise use golang@latest
mise use rust@stable
mise use deno@latest
```

## 🐛 Troubleshooting

### Fonts Not Showing

After installation, you may need to:
1. Restart your terminal
2. Select "JetBrainsMono Nerd Font" in terminal preferences
3. On WSL2, configure Windows Terminal to use the font

### Command Not Found

Ensure `~/.local/bin` is in your PATH:

```bash
echo $PATH | grep .local/bin
# If missing, restart your shell
exec zsh
```

### Neovim First Run

On first launch, Neovim will install plugins:

```bash
nvim
# Wait for plugins to install
# Quit and reopen
```

## 🔑 Next Steps After Installation

1. **Configure Claude CLI**: Run `claude login`
2. **Configure GitHub CLI**: Run `gh auth login`
3. **Set up SSH keys**: Generate if needed for GitHub
4. **Customize work email**: Edit `~/.gitconfig.work`
5. **Install language versions**: Use mise for your projects
6. **Explore the tools**: Try `tldr <command>` for quick help

## 📚 Included Tools Reference

| Tool | Purpose | Usage |
|------|---------|-------|
| `fzf` | Fuzzy finder | `Ctrl-R` for history, `Ctrl-T` for files |
| `ripgrep` | Fast grep | `rg "pattern"` |
| `bat` | Better cat | `bat file.txt` |
| `eza` | Modern ls | `ll` for detailed list |
| `fd` | Better find | `fd "pattern"` |
| `tldr` | Simple man pages | `tldr git` |
| `zoxide` | Smart cd | `z project` jumps to ~/dev/project |
| `delta` | Better git diff | Automatic with git |
| `mise` | Version manager | `mise use node@20` |
| `gh` | GitHub CLI | `gh pr create`, `gh repo clone` |

## 🤝 Contributing

Feel free to fork and customize for your needs! The goal is a simple, fast, reliable setup that works everywhere.

## 📄 License

MIT - Use freely and customize to your heart's content!