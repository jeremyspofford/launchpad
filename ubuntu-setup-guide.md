# Ubuntu Machine Setup Guide

## Overview
This guide tracks the setup process for a new Ubuntu machine, focusing on foundational processes and development tooling.

**Date Started:** January 11, 2026  
**Distribution:** Ubuntu  
**Package Manager:** APT + mise for tool version management

---

## 1. System Foundation

### 1.1 Update System Packages
```bash
sudo apt-get update -y && sudo apt-get upgrade -y
```

**Purpose:** Ensure all system packages are up to date before installing new software.

### 1.2 Install Google Chrome
```bash
sudo apt-get install google-chrome-stable
```

**Note:** This requires the Google Chrome repository to be added first. If not already configured:
```bash
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
sudo apt-get update
sudo apt-get install google-chrome-stable
```

---

## 2. Development Tool Management

### 2.1 Install mise
mise is a polyglot tool version manager that replaces asdf, nvm, pyenv, etc.

**The setup script installs mise automatically**, but if you need to install manually:

```bash
curl https://mise.run | sh
```

**Post-installation:** Add mise to shell profile (handled by dotfiles)

### 2.2 CLI Tools via mise

The setup script installs modern CLI tools via mise instead of apt/brew:

**Tools installed:**
- **ripgrep** (`rg`) - Fast grep alternative
- **fd** - Fast find alternative  
- **fzf** - Fuzzy finder
- **bat** - Cat with syntax highlighting
- **eza** - Modern ls replacement

**Why mise instead of apt?**
- ✅ Same tools across Linux/macOS/WSL
- ✅ Easy version management
- ✅ No sudo required
- ✅ Per-project versions possible
- ✅ Faster updates

**Using mise:**
```bash
# List installed tools
mise list

# Install a new tool
mise use -g node@20
mise use -g python@3.12

# Upgrade all tools
mise upgrade

# Per-project versions
cd ~/my-project
mise use node@18.20.0  # Creates .mise.toml in project
```

**See your `mise.toml` for configuration options**

---

## 3. Shell Selection

### Shell Comparison: Bash vs Zsh vs Fish

**Recommendation: Zsh** (best balance for your use case)

| Feature | Bash | Zsh | Fish |
|---------|------|-----|------|
| **Compatibility** | Universal, POSIX-compliant | Mostly compatible, can emulate bash | Different syntax, not POSIX |
| **Plugin ecosystem** | Limited (requires manual setup) | Excellent (Oh My Zsh, Zinit, etc.) | Built-in features, smaller ecosystem |
| **Auto-completion** | Basic | Excellent (case-insensitive, fuzzy) | Excellent (out of box) |
| **Customization** | Requires heavy scripting | Easy with frameworks | Very easy, built-in config |
| **Performance** | Fast | Slightly slower (with plugins) | Fast |
| **Learning curve** | Low (you likely know it) | Low (familiar to bash users) | Medium (different syntax) |
| **Default features** | Minimal | Powerful (needs plugins) | Feature-rich out of box |

**Why Zsh for you:**
- You're already planning to use it
- Best plugin ecosystem (Oh My Zsh, Powerlevel10k themes, etc.)
- Great for AWS/DevOps work (auto-completion for AWS CLI, kubectl, etc.)
- Compatible with most bash scripts
- Excellent for git workflows
- Your dotfiles repo already includes `.zshrc`

**Fish considerations:**
- Amazing out-of-box experience
- Scripting syntax is different (`.fish` vs `.sh`)
- Can cause compatibility issues with some tools
- Worth trying but may require script rewrites

### 3.1 Install Zsh
```bash
sudo apt-get install zsh -y
```

### 3.2 Set Zsh as default shell
```bash
chsh -s $(which zsh)
```

**Note:** Log out and back in for this to take effect.

### 3.3 Install Oh My Zsh (optional but recommended)
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

---

## 4. Note-Taking & Documentation

### 4.1 Install Obsidian
```bash
# Download latest AppImage from Obsidian
wget -O ~/Downloads/Obsidian.AppImage https://github.com/obsidianmd/obsidian-releases/releases/download/v1.7.7/Obsidian-1.7.7.AppImage

# Make it executable
chmod +x ~/Downloads/Obsidian.AppImage

# Move to applications directory
sudo mkdir -p /opt/obsidian
sudo mv ~/Downloads/Obsidian.AppImage /opt/obsidian/

# Create desktop entry
cat > ~/.local/share/applications/obsidian.desktop << 'EOF'
[Desktop Entry]
Name=Obsidian
Exec=/opt/obsidian/Obsidian.AppImage
Icon=obsidian
Type=Application
Categories=Office;
EOF
```

**Alternative (via Snap):**
```bash
sudo snap install obsidian --classic
```

---

## 5. Dotfiles Setup

### Current Repository Analysis

**What you have:**
✅ Well-organized structure with `home/`, `scripts/`, `templates/`
✅ Already using **GNU Stow** for symlink management
✅ Setup script (`scripts/setup.sh`) with platform detection
✅ mise configuration (`mise.toml`)
✅ Comprehensive configs: Ghostty, Neovim (LazyVim), tmux, Git
✅ Claude Code integration (`.claude/` directory)
✅ Good documentation (README, CLAUDE.md, cheatsheets)

**Your current workflow (from README):**
```bash
git clone https://github.com/jeremyspofford/dotfiles.git ~/workspace/dotfiles
cd ~/workspace/dotfiles
./scripts/setup.sh
```

### Recommended Approach

**Bootstrap script (automated setup)**
Create a one-liner that anyone can run:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/jeremyspofford/dotfiles/main/scripts/bootstrap.sh)
```

This script will:
1. Clone repo to `~/workspace/dotfiles` (HTTPS for public access)
2. Run the main `setup.sh` script
3. Backup existing configs before symlinking
4. Provide rollback capability with `--revert` flag
5. Show instructions for SSH setup (if you've forked the repo)

**Note on Git remotes:**
- Default clone uses HTTPS (works for everyone)
- If you've forked the repo, manually convert to SSH:
  ```bash
  cd ~/workspace/dotfiles
  git remote set-url origin git@github.com:YOUR_USERNAME/dotfiles.git
  ```

### Suggestions for Your Dotfiles

**Strengths:**
- Clean structure with `home/` mirroring `~/`
- GNU Stow is the right choice (better than custom symlink scripts)
- mise integration for tool management
- Platform detection (macOS/Linux/WSL)
- Template files for secrets/local configs

**Key improvements to implement:**

1. **Backup and Revert System**
   
   Before symlinking, backup existing files with timestamps:
   ```bash
   BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"
   
   # Before stowing
   if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
       mkdir -p "$BACKUP_DIR"
       cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc"
       echo "$HOME/.zshrc" >> "$BACKUP_DIR/manifest.txt"
   fi
   ```
   
   **Revert functionality:**
   ```bash
   # Usage
   ./scripts/setup.sh --revert
   
   # What it does:
   # 1. Finds most recent backup in ~/.dotfiles-backup/
   # 2. Unstow all dotfiles (remove symlinks)
   # 3. Restore backed-up files from manifest
   # 4. Optional: Remove dotfiles repo
   ```
   
   **Revert workflow:**
   ```bash
   # List available backups
   ./scripts/setup.sh --list-backups
   
   # Revert to most recent backup
   ./scripts/setup.sh --revert
   
   # Revert to specific backup
   ./scripts/setup.sh --revert --backup=20260111_143022
   ```

2. **Manual SSH Conversion (If You Forked the Repo)**
   
   The bootstrap uses HTTPS by default for public access. If you've forked
   this repo and want to push changes, convert to SSH manually:
   
   ```bash
   cd ~/workspace/dotfiles
   
   # Convert to SSH with YOUR username
   git remote set-url origin git@github.com:YOUR_USERNAME/dotfiles.git
   
   # Verify the change
   git remote -v
   ```
   
   **Why HTTPS by default:**
   - Anyone can clone without SSH setup
   - Works immediately for trying out dotfiles
   - Pull updates work fine with HTTPS
   - Fork-friendly (users set their own SSH URL)
   
   **Set up SSH keys:**
   ```bash
   # Generate key
   ssh-keygen -t ed25519 -C "your_email@example.com"
   
   # Add to GitHub
   cat ~/.ssh/id_ed25519.pub
   # Copy output to https://github.com/settings/keys
   
   # Test connection
   ssh -T git@github.com
   ```

3. **Idempotency checks**
   
   Script should be safe to run multiple times:
   ```bash
   # Example checks
   if [ ! -d "$HOME/.oh-my-zsh" ]; then
       echo "Installing Oh My Zsh..."
       # Install
   else
       echo "✓ Oh My Zsh already installed"
   fi
   
   if ! command -v mise &> /dev/null; then
       echo "Installing mise..."
       # Install
   else
       echo "✓ mise already installed ($(mise --version))"
   fi
   ```

4. **Command-line flags**
   ```bash
   ./scripts/setup.sh                    # Full setup
   ./scripts/setup.sh --update          # Just re-stow dotfiles
   ./scripts/setup.sh --revert          # Restore backups
   ./scripts/setup.sh --list-backups    # Show available backups
   ./scripts/setup.sh --minimal         # Dotfiles only, skip packages
   ./scripts/setup.sh --help            # Show usage
   ```

5. **Post-install checklist**
   
   After setup, show what the user needs to do manually:
   ```
   ========================================
   🎉 Setup Complete!
   ========================================
   
   ✅ Dotfiles installed and symlinked
   ✅ Git remote converted to SSH
   ✅ Previous configs backed up to: ~/.dotfiles-backup/20260111_143022
   
   ⚠️  Manual steps needed:
   
   1. Log out and back in for shell change to take effect
   
   2. Set up SSH keys for GitHub:
      ssh-keygen -t ed25519 -C "your_email@example.com"
      # Add ~/.ssh/id_ed25519.pub to GitHub
   
   3. Configure secrets file:
      cp ~/.secrets.template ~/.secrets
      vim ~/.secrets
   
   4. Set up Git identity:
      vim ~/.config/git/identity.gitconfig
   
   5. Test Git SSH connection:
      ssh -T git@github.com
   
   ========================================
   📝 Backup location: ~/.dotfiles-backup/20260111_143022
   
   To revert these changes:
      cd ~/workspace/dotfiles
      ./scripts/setup.sh --revert
   ========================================
   ```

### Your dotfiles are already solid!

The main question is: **How automated do you want it?**

- **Current state**: User clones, then runs setup - this is fine!
- **More automated**: Bootstrap script that does everything
- **Most automated**: Single curl command that sets up entire system

For your use case (DevOps engineer, multiple machines), I'd recommend:
1. Keep your current two-step approach
2. Add idempotency to setup.sh
3. Add a `--update` flag that just re-stows dotfiles (for when you pull changes)
4. Document the "bare minimum" vs "full setup" clearly

---

## Next Steps
- [ ] Clone dotfiles repository
- [ ] Run dotfiles setup script
- [ ] Configure shell environment (Zsh)
- [ ] Install development tools via mise
- [ ] Set up terminal emulator (Ghostty)
- [ ] Configure Git and SSH keys
- [ ] Install IDE/editor (Neovim/VS Code)

---

## Notes
- Consider creating automation script from this guide once setup is finalized
- Migration from Notion to Obsidian in progress
- Dotfiles repo uses GNU Stow for symlink management - clean and maintainable approach
