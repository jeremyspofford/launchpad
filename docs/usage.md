# Usage Guide

This guide covers daily usage patterns and advanced operations for managing your dotfiles.

## Daily Operations

### Applying Changes

```bash
# Apply any pending changes
chezmoi apply

# See what would change before applying
chezmoi diff

# Apply changes verbosely
chezmoi apply -v
```

### Editing Configuration

```bash
# Edit a dotfile (opens in $EDITOR)
chezmoi edit ~/.zshrc

# Edit a dotfile and apply immediately
chezmoi edit --apply ~/.bashrc

# Open the entire dotfiles directory in your editor
chezmoi edit
```

### Updating from Repository

```bash
# Pull latest changes and apply them
chezmoi update

# Pull changes without applying
chezmoi git pull

# See what updates are available
chezmoi git -- log --oneline HEAD..origin/main
```

### Managing Files

```bash
# Add a new file to chezmoi management
chezmoi add ~/.newconfig

# Add and automatically edit a file
chezmoi add --autotemplate ~/.gitconfig

# Remove a file from chezmoi management
chezmoi forget ~/.oldconfig

# View current status
chezmoi status
```

## Version Management with mise

### Installing Tools

```bash
# Install all tools defined in .tool-versions
mise install

# Install a specific tool
mise install node@20.0.0

# Install latest version of a tool
mise install python@latest
```

### Managing Versions

```bash
# List installed tools
mise list

# List available versions of a tool
mise list-all node

# Set global version
mise global node 20.0.0

# Set local version for current project
mise local python 3.11.0
```

## Shell Features

### Modern CLI Tools

The configuration includes aliases for modern CLI tools:

```bash
# File listing with exa
ls        # aliased to exa
ll        # aliased to exa -la
tree      # aliased to exa --tree

# File searching with fd and ripgrep
find      # use fd instead: fd <pattern>
grep      # use rg instead: rg <pattern>

# File preview with bat
cat       # aliased to bat
```

### Directory Navigation

```bash
# Quick directory jumping with zoxide
z <pattern>     # Jump to directory matching pattern
zi              # Interactive directory selection

# Directory bookmarks
bookmark <name> # Bookmark current directory
goto <name>     # Go to bookmarked directory
```

### Fuzzy Finding with fzf

```bash
# History search
Ctrl+R          # Search command history

# File finder
Ctrl+T          # Insert file path at cursor

# Directory finder
Alt+C           # Change to selected directory
```

## Git Configuration

### Template Variables

The Git configuration uses chezmoi templates:

```bash
# View current git config
git config --list | grep user

# The following are set from chezmoi prompts:
# user.name = "Your Name"
# user.email = "your.email@example.com"
```

### SSH Key Management

```bash
# Generated SSH key location
~/.ssh/personal_id_ed25519      # Private key
~/.ssh/personal_id_ed25519.pub  # Public key

# Test SSH connection
ssh -T git@github.com

# Add key to ssh-agent
ssh-add ~/.ssh/personal_id_ed25519
```

## Fabric AI Patterns

The configuration includes an extensive library of AI patterns:

### Common Patterns

```bash
# Analyze code or text
fabric -p analyze_code < file.py
fabric -p extract_wisdom < article.txt

# Create documentation
fabric -p create_summary < document.md
fabric -p explain_code < script.js

# Development tasks
fabric -p create_git_diff_commit
fabric -p analyze_logs < application.log
```

### Pattern Discovery

```bash
# List all available patterns
fabric --list

# Get help for a specific pattern
fabric -p <pattern_name> --help

# Search patterns by keyword
fabric --list | grep analysis
```

## Advanced Operations

### Templating

chezmoi supports Go templates for dynamic configuration:

```bash
# Create a template file
chezmoi add --template ~/.example

# Use template variables
{{ .chezmoi.hostname }}     # Current hostname
{{ .chezmoi.os }}           # Operating system
{{ .email }}                # User email from .chezmoi.toml
```

### Scripts

```bash
# Run a chezmoi script
chezmoi execute-template < script.tmpl

# Run scripts during apply
# Scripts in .chezmoiscripts/ run automatically
```

### Secrets Management

```bash
# Using 1Password CLI (if configured)
chezmoi secret keyring get service account

# Using external files
{{ include "secrets/api_key" }}
```

## Troubleshooting

### Common Commands

```bash
# Verify chezmoi configuration
chezmoi doctor

# Reset to clean state
chezmoi apply --force

# View detailed logs
chezmoi apply --verbose

# Check for conflicts
chezmoi diff --no-pager
```

### Re-running Setup

```bash
# Re-run Ansible playbook
ansible-playbook -i ~/dotfiles/ansible/inventory.ini ~/dotfiles/ansible/playbook.yml

# Reinstall tools with mise
mise install --force

# Rebuild shell configuration
source ~/.zshrc
```