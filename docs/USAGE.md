# Usage Guide

This guide covers different ways to run the dotfiles setup scripts from any location.

## Quick Start

### New Machine Setup

```bash
# Install curl (only prerequisite)
sudo apt-get update && sudo apt-get install -y curl

# Run bootstrap from anywhere
bash <(curl -fsSL https://raw.githubusercontent.com/jeremyspofford/dotfiles/main/scripts/bootstrap.sh)
```

This clones to `~/workspace/dotfiles` and runs setup automatically.

---

## Running from Different Locations

The scripts are **location-agnostic** - they work from any directory.

### Option 1: Run from Cloned Repo

```bash
# Clone to any location
git clone https://github.com/jeremyspofford/dotfiles.git /tmp/dotfiles
cd /tmp/dotfiles

# Run setup from repo directory
./scripts/setup.sh
```

**How it works:** Script detects it's in a git repo and uses that location.

### Option 2: Run with Absolute Path

```bash
# Clone to default location
git clone https://github.com/jeremyspofford/dotfiles.git ~/workspace/dotfiles

# Run from anywhere
cd ~
~/workspace/dotfiles/scripts/setup.sh

cd /tmp
~/workspace/dotfiles/scripts/setup.sh
```

**How it works:** Script finds repo location from script path.

### Option 3: Run with Custom Location

```bash
# Clone to custom location
git clone https://github.com/jeremyspofford/dotfiles.git /opt/my-dotfiles

# Tell script where to find dotfiles
DOTFILES_DIR=/opt/my-dotfiles /opt/my-dotfiles/scripts/setup.sh
```

**How it works:** `DOTFILES_DIR` environment variable overrides default.

### Option 4: Bootstrap with Custom Location

```bash
# Bootstrap to custom location
DOTFILES_DIR=~/my-configs bash <(curl -fsSL https://raw.githubusercontent.com/jeremyspofford/dotfiles/main/scripts/bootstrap.sh)
```

**Result:** Clones to `~/my-configs` instead of `~/workspace/dotfiles`.

---

## Common Workflows

### First-Time Setup

```bash
# Simplest approach - bootstrap handles everything
bash <(curl -fsSL https://raw.githubusercontent.com/jeremyspofford/dotfiles/main/scripts/bootstrap.sh)

# Interactive prompts will guide you through:
# 1. Tool selection (zsh, tmux, neovim, etc.)
# 2. System restore point (optional Timeshift)
# 3. Installation and configuration
```

### Testing Before Commit

```bash
# Clone to temporary location
git clone https://github.com/jeremyspofford/dotfiles.git /tmp/test-dotfiles
cd /tmp/test-dotfiles

# Make changes
vim home/.zshrc

# Test the changes
./scripts/setup.sh --minimal

# If good, commit and push
git add .
git commit -m "Update zshrc"
git push

# Clean up
cd ~
rm -rf /tmp/test-dotfiles
```

### Updating After Changes

```bash
# Pull latest changes
cd ~/workspace/dotfiles
git pull

# Re-apply dotfiles (no package reinstall)
./scripts/setup.sh --update
```

### Running on Multiple Machines

**Machine 1 (development):**
```bash
# Clone and customize
git clone git@github.com:YOUR_USERNAME/dotfiles.git ~/workspace/dotfiles
cd ~/workspace/dotfiles

# Make changes
vim home/.zshrc

# Test
./scripts/setup.sh --update

# Commit
git add .
git commit -m "Add custom aliases"
git push
```

**Machine 2 (pulling changes):**
```bash
# Bootstrap with your fork
bash <(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/scripts/bootstrap.sh)

# Or if already set up, just pull and update
cd ~/workspace/dotfiles
git pull
./scripts/setup.sh --update
```

---

## Environment Variables

### DOTFILES_DIR

Override the default dotfiles location.

**Default:** `~/workspace/dotfiles`

**Usage:**
```bash
# Temporary override
DOTFILES_DIR=/custom/path ./scripts/setup.sh

# Persistent override (add to your shell profile)
export DOTFILES_DIR=/opt/dotfiles
./scripts/setup.sh
```

**When to use:**
- You prefer a different directory structure
- Testing in a temporary location
- Managing multiple dotfile repos
- Running in CI/CD environments

---

## Script Behavior

### Location Detection

The scripts use this logic to find the dotfiles directory:

1. **If running from within repo:** Use repo location
   ```bash
   cd /tmp/dotfiles
   ./scripts/setup.sh
   # Uses: /tmp/dotfiles
   ```

2. **If DOTFILES_DIR is set:** Use that
   ```bash
   DOTFILES_DIR=/custom/path ./scripts/setup.sh
   # Uses: /custom/path
   ```

3. **Otherwise:** Use default
   ```bash
   # Uses: ~/workspace/dotfiles
   ```

### Working Directory

Scripts work regardless of your current directory:

```bash
# From home
cd ~
~/workspace/dotfiles/scripts/setup.sh  # ✅ Works

# From /tmp
cd /tmp
~/workspace/dotfiles/scripts/setup.sh  # ✅ Works

# From repo
cd ~/workspace/dotfiles
./scripts/setup.sh  # ✅ Works

# From scripts directory
cd ~/workspace/dotfiles/scripts
./setup.sh  # ✅ Works
```

---

## Advanced Usage

### Automated/CI Installation

```bash
# Non-interactive installation with defaults
DOTFILES_DIR=/opt/dotfiles \
  bash <(curl -fsSL https://raw.githubusercontent.com/jeremyspofford/dotfiles/main/scripts/bootstrap.sh) \
  --non-interactive \
  --skip-restore-prompt \
  --minimal
```

### Development Workflow

```bash
# Clone to dev location
git clone git@github.com:jeremyspofford/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles

# Create feature branch
git checkout -b feature/new-aliases

# Test changes
./scripts/setup.sh --update

# Revert if issues
./scripts/setup.sh --revert

# Iterate until satisfied
vim home/.zshrc
./scripts/setup.sh --update

# Commit when done
git add .
git commit -m "Add new aliases"
git push
```

### Multiple Dotfile Repos

```bash
# Work dotfiles
DOTFILES_DIR=~/dotfiles-work ~/dotfiles-work/scripts/setup.sh

# Personal dotfiles
DOTFILES_DIR=~/dotfiles-personal ~/dotfiles-personal/scripts/setup.sh

# Or use symlinks
ln -s ~/dotfiles-work ~/workspace/dotfiles
./scripts/setup.sh  # Uses work dotfiles

ln -sf ~/dotfiles-personal ~/workspace/dotfiles
./scripts/setup.sh  # Uses personal dotfiles
```

---

## Troubleshooting

### "Cannot find dotfiles directory"

**Problem:** Script can't locate the dotfiles repo.

**Solution:**
```bash
# Explicitly set location
DOTFILES_DIR=/path/to/dotfiles ./scripts/setup.sh

# Or run from within the repo
cd /path/to/dotfiles
./scripts/setup.sh
```

### "Stow conflicts"

**Problem:** Files already exist and aren't symlinks.

**Solution:**
```bash
# Let script back them up
./scripts/setup.sh  # Backups happen automatically

# Or manually back up and remove
mv ~/.zshrc ~/.zshrc.backup
./scripts/setup.sh
```

### "Running from wrong location"

**Problem:** Script is using wrong dotfiles directory.

**Solution:**
```bash
# Check which directory script will use
grep DOTFILES_DIR ~/workspace/dotfiles/scripts/setup.sh

# Or just look at the output
./scripts/setup.sh --help
# Shows: Dotfiles: /path/to/dotfiles
```

### "Want to test without affecting system"

**Solution:**
```bash
# Use --minimal flag (only stow, no installs)
./scripts/setup.sh --minimal

# Or use a container
docker run -it ubuntu:24.04
# Then run bootstrap inside container
```

---

## Best Practices

### 1. Use Standard Location

Stick with `~/workspace/dotfiles` unless you have a specific reason to change.

**Pros:**
- Scripts use it by default
- Consistent across machines
- Easy to remember

### 2. Run from Repo Directory

```bash
cd ~/workspace/dotfiles
./scripts/setup.sh
```

**Pros:**
- No path confusion
- See git status easily
- Quick to edit files

### 3. Test in Temp Location First

```bash
# Test changes
git clone https://github.com/jeremyspofford/dotfiles.git /tmp/test
cd /tmp/test
# Make changes
./scripts/setup.sh --minimal

# If good, apply to main
cd ~/workspace/dotfiles
git pull
./scripts/setup.sh --update
```

### 4. Use --update for Quick Changes

```bash
# After editing dotfiles
vim ~/workspace/dotfiles/home/.zshrc

# Quick re-apply (no package reinstall)
cd ~/workspace/dotfiles
./scripts/setup.sh --update
```

### 5. Document Custom Locations

If you use non-standard locations, document them:

```bash
# In your ~/.bashrc or ~/.zshrc
export DOTFILES_DIR=/custom/location

# Or create an alias
alias dotfiles-update='cd $DOTFILES_DIR && git pull && ./scripts/setup.sh --update'
```

---

## Examples

### Example 1: Quick Test

```bash
# Clone to temp, test, clean up
git clone https://github.com/jeremyspofford/dotfiles.git /tmp/dotfiles-test
cd /tmp/dotfiles-test
./scripts/setup.sh --minimal
# Check if configs look good
cd ~ && rm -rf /tmp/dotfiles-test
```

### Example 2: Development Machine

```bash
# Clone with SSH for push access
git clone git@github.com:jeremyspofford/dotfiles.git ~/workspace/dotfiles
cd ~/workspace/dotfiles

# Make it yours
git remote set-url origin git@github.com:YOUR_USERNAME/dotfiles.git

# Develop
vim home/.zshrc
./scripts/setup.sh --update

# Commit
git add .
git commit -m "Customize for dev machine"
git push
```

### Example 3: Server Setup

```bash
# Bootstrap to /opt (system-wide location)
sudo mkdir -p /opt/dotfiles
sudo chown $USER:$USER /opt/dotfiles

DOTFILES_DIR=/opt/dotfiles bash <(curl -fsSL https://raw.githubusercontent.com/jeremyspofford/dotfiles/main/scripts/bootstrap.sh) \
  --non-interactive \
  --skip-restore-prompt \
  --minimal

# Verify
ls -la ~/
# Should see symlinks to /opt/dotfiles/home/*
```

### Example 4: CI/CD Pipeline

```yaml
# .github/workflows/test-dotfiles.yml
name: Test Dotfiles
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          path: dotfiles
      
      - name: Run setup
        run: |
          cd dotfiles
          ./scripts/setup.sh \
            --non-interactive \
            --skip-restore-prompt \
            --minimal
      
      - name: Verify
        run: |
          ls -la ~/
          test -L ~/.zshrc
```

---

## Summary

**Key Points:**
- ✅ Scripts work from any directory
- ✅ Auto-detect repo location
- ✅ Override with `DOTFILES_DIR` if needed
- ✅ Default location: `~/workspace/dotfiles`
- ✅ Use `--minimal` for testing
- ✅ Use `--update` for quick changes

**Most Common Usage:**
```bash
# First time
bash <(curl -fsSL https://raw.githubusercontent.com/jeremyspofford/dotfiles/main/scripts/bootstrap.sh)

# Updates
cd ~/workspace/dotfiles && git pull && ./scripts/setup.sh --update
```

That's it! The scripts are designed to "just work" regardless of where you run them from.
