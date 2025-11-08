# 🚀 Modern Dotfiles

A streamlined, cross-platform dotfiles setup using GNU Stow. Clone, run one command, and start working.

## ✨ What's Included

- **🐚 Modern Shell**: Zsh with Oh My Zsh and custom configurations  
- **🔧 Essential Tools**: Configured via Ansible for consistent setup across platforms
- **🔄 Easy Syncing**: GNU Stow for managing and syncing dotfiles across machines
- **🌳 Smart Git Config**: Multiple conditional Git identities for work/personal projects
- **🎨 Terminal Configuration**: WeZTerm configuration included
- **⚡ Neovim Setup**: LazyVim configuration with modern plugins, LSP support, and AI assistance (Claude Code, GitLab Duo)
- **🔐 1Password Integration**: Secure secrets management with automatic shell sourcing
- **🛠️ Development Tools**: mise for runtime management, lazygit for Git workflow

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
- Runtime management: `mise` (replaces asdf/nvm/rbenv/pyenv)
- Git workflow: `lazygit` (interactive Git TUI)
- Git enhancements with `delta` pager and syntax highlighting
- 1Password CLI for secure secrets management

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
│   ├── setup.sh            # One-time initial setup script
│   ├── sync-secrets.sh     # 1Password secrets synchronization script
│   └── validate-setup.sh   # Validation script to check setup
├── home/                   # Your dotfiles (mirrors ~/ structure)  
│   ├── .commonrc          # Shared configuration for bash/zsh
│   ├── .zshrc             # Zsh-specific configuration + Oh My Zsh
│   ├── .bashrc            # Bash-specific configuration
│   ├── .bash_profile      # Bash login shell setup
│   ├── .gitconfig         # Main git config with conditional includes
│   ├── .gitignore         # Global git ignore patterns
│   ├── .vimrc            # Vim configuration
│   ├── .wezterm.lua      # WeZTerm configuration
│   ├── .secrets.template # 1Password secrets template (defines what to fetch)
│   ├── .ssh/config       # SSH configuration with multiple key support
│   └── .config/          # Application configs
│       ├── nvim/         # LazyVim Neovim configuration
│       └── git/          # Git conditional configs
│           ├── personal.gitconfig  # Personal Git identity
│           └── work.gitconfig      # Work Git identity
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
- `.zshrc` includes Oh My Zsh setup and sources `.commonrc`
- `.bashrc` contains bash-specific settings and sources `.commonrc`
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

## 🔐 1Password Secrets Management

This dotfiles setup includes secure secrets management using 1Password CLI, allowing you to fetch API keys, tokens, and other sensitive information directly from your 1Password vaults.

### Prerequisites

Install 1Password CLI:

```bash
# macOS
brew install --cask 1password-cli

# Linux
curl -sSO https://downloads.1password.com/linux/debian/amd64/stable/1password-cli-amd64-latest.deb
sudo dpkg -i 1password-cli-amd64-latest.deb

# Or download from: https://1password.com/downloads/command-line/
```

### How It Works

1. **Template Configuration**: Define which secrets to fetch in `home/.secrets.template`
2. **Script Execution**: Run `sync-secrets` to fetch secrets from 1Password
3. **Automatic Loading**: Secrets are automatically sourced in your shell via `.commonrc`

### Setting Up Secrets

1. **Configure 1Password References** in `home/.secrets.template`:

```bash
# GitLab Access Token
export GITLAB_ACCESS_TOKEN="op://Private/GitLab - VividCloud/PAT"

# GitHub Token
export GITHUB_TOKEN="op://Personal/GitHub/token"

# AWS Credentials
export AWS_ACCESS_KEY_ID="op://Work/AWS/access_key_id"
export AWS_SECRET_ACCESS_KEY="op://Work/AWS/secret_access_key"

# API Keys
export OPENAI_API_KEY="op://Personal/OpenAI/api_key"
export ANTHROPIC_API_KEY="op://Personal/Anthropic/api_key"
```

2. **Find 1Password References**:

```bash
# List your vaults
op vault list

# List items in a vault
op item list --vault "Personal"

# Get detailed info about an item
op item get "GitHub" --format json
```

3. **Sync Secrets**:

```bash
# Fetch all secrets from 1Password
sync-secrets

# The script creates ~/.secrets with your actual values
# This file is automatically sourced by your shell
```

### Usage Examples

**Initial Setup:**

```bash
# 1. First, sign in to 1Password
op signin

# 2. Sync your secrets
sync-secrets

# 3. Verify secrets are loaded
verify_secrets
```

**Daily Usage:**

```bash
# Update secrets when they change
sync-secrets

# Check what secrets are loaded (values hidden)
verify_secrets

# Use secrets in your applications
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user
```

**Automatic Loading:**

- Secrets are automatically loaded when you start a new shell session
- The `sync-secrets` function is available in all shells for easy updates
- Your actual `.secrets` file is never committed to git (it's in `.gitignore`)

### Security Features

- **Local Storage**: Secrets are stored locally in `~/.secrets` (600 permissions)
- **Git Protection**: `.secrets` file is in `.gitignore` and never committed
- **Template Only**: Only the template (with 1Password references) is version controlled
- **Automatic Updates**: Easy to refresh secrets when they change in 1Password
- **Verification**: Built-in function to list loaded secrets without exposing values

## 🛠️ Development Tools

### mise - Runtime Management

[mise](https://mise.jdx.dev/) is a universal runtime manager that replaces tools like asdf, nvm, rbenv, and pyenv with a single, fast tool.

**Key Features:**

- **Multi-language support**: Node.js, Python, Ruby, Go, Java, and more
- **Project-specific versions**: Automatically switch versions per project
- **Fast performance**: Written in Rust, significantly faster than alternatives
- **Compatible**: Works with existing `.nvmrc`, `.python-version`, etc. files

**Usage:**

```bash
# Install a runtime
mise install node@20
mise install python@3.11

# Set global versions
mise global node@20 python@3.11

# Set project-specific versions (creates .mise.toml)
mise local node@18 python@3.10

# Install tools from .mise.toml
mise install

# List available versions
mise list-remote node
```

### lazygit - Interactive Git TUI

[lazygit](https://github.com/jesseduffield/lazygit) provides a beautiful terminal UI for Git operations.

**Key Features:**

- **Visual Git workflow**: Stage, commit, push/pull with keyboard shortcuts
- **Branch management**: Create, switch, merge branches visually
- **Interactive staging**: Stage individual lines or hunks
- **Diff visualization**: Side-by-side diffs with syntax highlighting
- **Commit history**: Browse and search commit history

**Usage:**

```bash
# Launch lazygit
lazygit
```

**Key shortcuts in lazygit:**

- `space`: Stage/unstage files or hunks
- `c`: Commit staged changes
- `P`: Push to remote
- `p`: Pull from remote
- `tab`: Switch between panels
- `?`: Help menu with all shortcuts

### Neovim AI Plugins

The Neovim configuration includes modern AI-powered coding assistance plugins:

#### Claude Code Plugin

**Features:**

- **Direct Claude Integration**: Chat with Claude directly from Neovim
- **Code Generation**: Generate code based on natural language descriptions
- **Diff Management**: Accept/reject AI-suggested changes with visual diffs
- **Context Aware**: Add current buffer or selected text to Claude context
- **Model Selection**: Choose between different Claude models

**Key Bindings:**

- `<leader>cc`: Open Claude Code
- `<leader>ca`: Accept Claude suggestion
- `<leader>cr`: Reject Claude suggestion
- `<leader>ab`: Add current buffer to Claude context
- `<leader>as`: Send selected text to Claude (visual mode)
- `<leader>aa`: Accept diff
- `<leader>ad`: Deny diff

#### GitLab Duo Plugin

**Features:**

- **Code Suggestions**: AI-powered code completion for Go, JavaScript, Python, Ruby
- **GitLab Integration**: Seamless integration with GitLab's AI capabilities
- **Token-based Authentication**: Uses `GITLAB_ACCESS_TOKEN` environment variable
- **Statusline Integration**: Shows GitLab Duo status in Neovim statusline

**Setup:**

- Requires `GITLAB_ACCESS_TOKEN` environment variable (managed via 1Password)
- Automatically activates for supported file types
- Integrates with existing LazyVim configuration

**Supported Languages:**

- Go
- JavaScript/TypeScript
- Python
- Ruby

## 🎨 Git Configuration

Multiple Git identities managed via conditional includes:

**Main config** (`home/.gitconfig`):

```ini
# Personal projects (default for most directories)
[includeIf "gitdir:~/workspace/"]
    path = ~/.config/git/personal.gitconfig

# Work repositories
[includeIf "gitdir:~/workspace/vividcloud/"]
    path = ~/.config/git/work.gitconfig
    
[includeIf "gitdir:~/workspace/clients/"]
    path = ~/.config/git/work.gitconfig
```

**Identity configs** (`home/.config/git/personal.gitconfig`, etc.):

```ini
[user]
    name = Your Name
    email = your.email@example.com
```

### SSH Configuration

The SSH configuration (`home/.ssh/config`) supports multiple SSH keys for different services and identities:

**Multiple GitLab Keys:**

```bash
# GitLab (tries both keys in order)
Host gitlab.com
    HostName gitlab.com
    User git
    IdentityFile ~/.ssh/id_ed25519_vividcloud    # Work key tried first
    IdentityFile ~/.ssh/id_ed25519_personal      # Personal key as fallback
    
# Work-specific GitLab alias
Host gitlab-vividcloud
    HostName gitlab.com
    User git
    IdentityFile ~/.ssh/id_ed25519_vividcloud

# Usage: git clone git@gitlab-vividcloud:company/repo.git
```

**GitHub Configuration:**

```bash
# Personal GitHub (default)
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
```

**Key Features:**

- **Automatic Key Loading**: SSH agent automatically loads keys with macOS Keychain support
- **Multiple Identity Support**: Different keys for work, personal, and client projects
- **Host Aliases**: Use `gitlab-vividcloud` to force a specific key
- **Fallback Logic**: Primary key tried first, personal key as fallback

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

### 1Password Issues

**1Password CLI not found:**

```bash
# Install 1Password CLI
brew install --cask 1password-cli  # macOS

# Verify installation
op --version
```

**Sign-in issues:**

```bash
# Manual sign in
op signin

# Check account status
op account list
```

**Secrets not loading:**

```bash
# Verify template file exists
ls -la ~/dotfiles/home/.secrets.template

# Check permissions on secrets file
ls -la ~/.secrets

# Manually run sync
sync-secrets
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
