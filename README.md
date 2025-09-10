# 🚀 Modern Dotfiles

A streamlined, cross-platform dotfiles setup using GNU Stow. Clone, run one command, and start working.

## ✨ What's Included

- **🐚 Modern Shell**: Zsh with Oh My Zsh and custom configurations  
- **🔧 Essential Tools**: Configured via Ansible for consistent setup across platforms
- **🔄 Easy Syncing**: GNU Stow for managing and syncing dotfiles across machines
- **🌳 Smart Git Config**: Multiple conditional Git identities for work/personal projects
- **🎨 Terminal Configuration**: WeZTerm configuration included
- **⚡ Neovim Setup**: LazyVim configuration with modern plugins and LSP support

## 🚀 Quick Install

### One-Command Setup (Recommended)

```bash
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles
./scripts/setup.sh
```

**Advanced Usage:**
```bash
./scripts/setup.sh --help              # Show detailed help
./scripts/setup.sh --force             # Force all tasks to run
DOTFILES_REPO=myuser/dotfiles ./scripts/setup.sh  # Custom repository
```

This script will:
- Auto-detect your operating system (macOS, Linux, WSL)
- Install prerequisites (Homebrew on macOS, Ansible, etc.)
- Install Oh My Zsh and essential tools (bat, delta, fzf, etc.)
- Use GNU Stow to symlink all dotfiles from `home/` to your `~` directory
- Provide a summary of what was accomplished

### What Gets Installed

**Prerequisites that `setup.sh` installs automatically:**
- **macOS**: Homebrew, Ansible via brew
- **Linux/WSL**: Ansible via apt, GitHub CLI
- GNU Stow, Oh My Zsh, Ansible collections

**Essential tools via Ansible:**
- Modern CLI tools: `bat`, `delta`, `fzf`, `ripgrep`, `jq`
- Development tools: `neovim`, `tmux`, `shellcheck`
- Git enhancements with `delta` pager and syntax highlighting

**For updates after initial setup:**
```bash
cd ~/dotfiles
./scripts/setup.sh          # Normal update
./scripts/setup.sh --force  # Force all tasks
```

## 📁 Repository Structure

```
dotfiles/
├── scripts/
│   └── setup.sh            # One-time initial setup script
├── home/                   # Your dotfiles (mirrors ~/ structure)  
│   ├── .commonrc          # Shared configuration for bash/zsh
│   ├── .zshrc             # Zsh-specific configuration + Oh My Zsh
│   ├── .bashrc            # Bash-specific configuration
│   ├── .bash_profile      # Bash login shell setup
│   ├── .gitconfig         # Main git config with conditional includes
│   ├── .gitconfig.*       # Work/personal git identities
│   ├── .vimrc            # Vim configuration
│   ├── .wezterm.lua      # WeZTerm configuration
│   └── .config/          # Application configs
│       ├── nvim/         # LazyVim Neovim configuration
│       ├── git/          # Git conditional configs
│       └── zsh/          # Modular zsh configuration
├── ansible/              # System packages and updates
│   ├── playbook.yml
│   ├── requirements.yml
│   └── roles/
└── README.md
```

## 🔧 How It Works

**GNU Stow Structure:** The `home/` directory exactly mirrors your home directory (`~`). When you run `stow home`, it creates symlinks from `~/` to `~/dotfiles/home/` for each file.

**Streamlined Shell Configuration:** 
- `.commonrc` contains all shared configurations between bash and zsh
- `.zshrc` and `.bashrc` contain shell-specific settings and source `.commonrc`
- OS-specific aliases (e.g., `start` command) automatically adapt to your platform

**Initial Setup:** `scripts/setup.sh` handles the one-time setup (Ansible, Oh My Zsh, stow operation)
**Ongoing Updates:** Use the Ansible playbook for system packages and re-stowing

## 🔄 Daily Usage

### Editing Dotfiles
Edit files directly in `~/dotfiles/home/` - changes appear immediately via symlinks:

```bash
# Edit your zsh config
vim ~/dotfiles/home/.zshrc

# Changes are live immediately since ~/.zshrc is symlinked
```

### Syncing Across Machines
```bash
# Commit your changes
cd ~/dotfiles
git add .
git commit -m "Update dotfiles"
git push

# On another machine
cd ~/dotfiles  
git pull
./scripts/setup.sh  # Re-run to ensure everything is linked
```

### Managing Stow Packages
```bash
# Unstow (remove symlinks)
stow -D home

# Re-stow (create symlinks)  
stow home

# Dry run (see what would happen)
stow -n home
```

## 🎯 Platform Support

### macOS
- Uses Homebrew for package management
- **Modern Bash Installation**: Automatically installs Bash 5.x via Homebrew (macOS ships with ancient 3.2.57 from 2007)
- Includes macOS-specific shell configurations and aliases
- `bash` command automatically uses modern version after setup

### Linux (Ubuntu/Debian/WSL2)  
- Uses apt for system packages
- Includes Linux-specific optimizations

## 🎨 Git Configuration

Multiple Git identities managed via conditional includes:

**Main config** (`home/.gitconfig`):
```ini
[includeIf "gitdir:~/personal/"]
    path = ~/.gitconfig.personal
    
[includeIf "gitdir:~/work/company/"]  
    path = ~/.gitconfig.company
```

**Identity configs** (`home/.gitconfig.personal`, etc.):
```ini
[user]
    name = Your Name
    email = your.email@example.com
```

## 🐛 Troubleshooting  

### Stow Conflicts
If `setup.sh` fails with stow conflicts, you have existing files that aren't symlinks:

```bash
# Remove conflicting files first
rm ~/.zshrc ~/.bashrc  # etc.

# Then re-run setup
./scripts/setup.sh
```

### Tasks Not Running or Skipped
Use the force flag to ensure all tasks run:
```bash
./scripts/setup.sh --force
```

### Command Not Found
Restart your shell after installation:
```bash
exec zsh
```

### Need Help?
Get detailed usage information:
```bash
./scripts/setup.sh --help
```

### Security Considerations

**SSH Key Generation**: By default, SSH keys are generated **without passphrases** for automation convenience. This trade-off prioritizes ease of use over maximum security.

**Security measures in place:**
- Keys have 600 permissions (owner read/write only)
- macOS keychain integration for secure storage
- Ed25519 keys (modern, secure algorithm)

**For higher security environments:**
```bash
# Generate passphrase-protected keys manually
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_personal -C "user@hostname (personal)"
# Enter passphrase when prompted
```

## 🔑 Testing Your Setup

**Automated validation:**
```bash
./scripts/validate-setup.sh
```

**Manual verification:**

After running `scripts/setup.sh`, verify:

```bash
# Check symlinks exist
ls -la ~ | grep '\->'

# Verify shell loads correctly
exec zsh

# Test git config (will show default config since no work/personal dirs yet)
git config user.email  # Should show your default git email
```

## 📄 License

MIT - Use freely and customize to your heart's content!