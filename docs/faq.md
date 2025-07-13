# Frequently Asked Questions

## General Questions

### Q: What is the difference between this dotfiles setup and others?

**A:** This setup focuses on:
- **Cross-platform compatibility** (macOS, Linux, Windows)
- **Modern tooling** (chezmoi instead of stow, starship, mise, fabric)
- **Automated setup** (Ansible for packages, comprehensive install scripts)
- **AI integration** (200+ fabric patterns for enhanced productivity)
- **Template-based configuration** (dynamic configs based on system/user)

### Q: Why did you migrate from GNU Stow to chezmoi?

**A:** chezmoi provides several advantages:
- **Templates**: Dynamic configuration based on OS, hostname, user preferences
- **Cross-platform support**: Better handling of platform differences
- **Secret management**: Secure handling of sensitive configuration
- **Git integration**: Built-in version control integration
- **State management**: Knows what files it manages and their state

### Q: Can I use only specific parts of this configuration?

**A:** Yes! The configuration is modular:
- Skip components during installation prompts
- Use `chezmoi add` to manage only specific files
- Customize the Ansible playbook to install only desired packages
- Edit `.chezmoi.toml` to change default behaviors

## Installation Questions

### Q: What happens to my existing dotfiles?

**A:** The installation process:
1. Creates timestamped backups (e.g., `backup_20250113_143022/`)
2. Only backs up actual files (not symlinks)
3. Prompts whether to remove backups after successful installation
4. You can skip backup with `./install.sh --no-backup`

### Q: Do I need administrator privileges?

**A:** It depends on your system:
- **Package installation**: Usually requires sudo (via Ansible)
- **Homebrew on macOS**: May need admin for initial setup
- **User configuration**: No admin needed for dotfiles themselves
- **Windows**: Some applications may require administrator privileges

### Q: Can I run the installation multiple times?

**A:** Yes, the installation is idempotent:
- Existing tools won't be reinstalled unnecessarily
- chezmoi will update configurations to match the repository
- Ansible playbook checks if packages are already installed
- You can safely re-run after failures or interruptions

## Configuration Questions

### Q: How do I customize the configuration for my needs?

**A:** Several approaches:
1. **Edit in place**: `chezmoi edit <file>` and modify directly
2. **Fork the repository**: Create your own version with custom defaults
3. **Template variables**: Modify `.chezmoi.toml` to add custom prompts
4. **Local overrides**: Create local configuration files that aren't managed

### Q: How do I add my own shell aliases or functions?

**A:** Add them to the appropriate configuration files:
```bash
# For zsh
chezmoi edit ~/.config/zsh/aliases.zsh

# For bash
chezmoi edit ~/.bash_aliases

# Apply changes
chezmoi apply
```

### Q: Can I use a different shell than zsh?

**A:** Yes:
1. The configuration includes bash support
2. Don't switch to zsh during installation
3. Manually set your preferred shell: `chsh -s /bin/bash`
4. The dotfiles include configuration for both shells

## Tool-Specific Questions

### Q: How do I update the fabric AI patterns?

**A:** Update patterns regularly:
```bash
# Update all patterns
fabric --updatepatterns

# Or manually update the git repository
cd ~/.config/fabric && git pull
```

### Q: How do I manage different versions of programming languages?

**A:** Use mise (formerly rtx):
```bash
# Install specific versions
mise install node@18.0.0 python@3.11.0

# Set global defaults
mise global node 18.0.0

# Set project-specific versions
cd myproject && mise local python 3.11.0
```

### Q: Can I use my own Neovim configuration?

**A:** Yes:
1. **Replace entirely**: `chezmoi forget ~/.config/nvim` and use your own
2. **Modify existing**: `chezmoi edit ~/.config/nvim/init.lua`
3. **Layer on top**: The config is designed to be extensible

### Q: How do I add more applications to the Windows installer?

**A:** Edit `install.ps1`:
1. Add package IDs to the appropriate functions
2. Find package IDs with: `winget search <app_name>`
3. Test the installation manually first
4. Consider creating optional installation groups

## Troubleshooting Questions

### Q: The installation failed partway through. What should I do?

**A:** 
1. **Identify the failure point** from error messages
2. **Fix the specific issue** (missing dependencies, permissions, etc.)
3. **Re-run the installation** - it's safe to run multiple times
4. **Check the troubleshooting guide** for common solutions
5. **Open an issue** if the problem persists

### Q: Some commands aren't found after installation

**A:** Check your PATH and shell configuration:
```bash
# Reload shell configuration
source ~/.zshrc  # or ~/.bashrc

# Check if tools are installed
which fzf rg fd mise starship

# Verify PATH includes necessary directories
echo $PATH

# Manually add to PATH if needed
export PATH="$HOME/.local/bin:$PATH"
```

### Q: Git/SSH authentication isn't working

**A:** Verify SSH key setup:
```bash
# Check if keys exist
ls -la ~/.ssh/personal_id_ed25519*

# Test GitHub connection
ssh -T git@github.com

# Add key to GitHub if not done
cat ~/.ssh/personal_id_ed25519.pub
# Copy and add at: https://github.com/settings/ssh/new
```

## Advanced Questions

### Q: How do I contribute custom patterns to fabric?

**A:** 
1. Create patterns in `~/.config/fabric/patterns/`
2. Test them locally
3. Consider contributing to the main fabric repository
4. Share useful patterns with the community

### Q: Can I use this configuration in a Docker container?

**A:** Yes, with modifications:
1. **Skip GUI applications** and system packages
2. **Focus on shell and CLI tools**
3. **Use the Ansible playbook** selectively
4. **Consider creating a Dockerfile** based on the setup

### Q: How do I sync configurations across multiple machines?

**A:** chezmoi handles this:
```bash
# On machine 1: push changes
chezmoi git add .
chezmoi git commit -m "Update configuration"
chezmoi git push

# On machine 2: pull changes
chezmoi update
```

### Q: Can I use this with corporate environments/proxies?

**A:** Usually yes, but may require configuration:
1. **Set proxy environment variables** before running installation
2. **Configure git/curl** to use corporate certificates
3. **Modify package sources** if necessary
4. **Test connectivity** to required services first

## Migration Questions

### Q: I'm coming from oh-my-zsh. How do I migrate?

**A:** The configuration is compatible:
1. **Backup your existing config**: `cp ~/.zshrc ~/.zshrc.backup`
2. **Run the installation**: It will integrate well with oh-my-zsh
3. **Merge custom configurations**: Add your aliases/functions to the new structure
4. **Test thoroughly**: Ensure all your workflows still work

### Q: How do I migrate from my existing dotfiles repository?

**A:** 
1. **Backup everything**: `cp -r ~ ~/full_backup`
2. **Identify unique configurations**: What's custom in your setup?
3. **Install this configuration**: Start fresh
4. **Gradually migrate**: Add your customizations piece by piece
5. **Use chezmoi templates**: Convert hardcoded values to templates

### Q: Can I migrate back to my old setup if I don't like this?

**A:** Yes:
1. **Restore from backup**: Use the backup created during installation
2. **Remove chezmoi**: `rm -rf ~/.local/share/chezmoi`
3. **Uninstall packages**: Use your system's package manager
4. **Reset shell**: `chsh -s /bin/bash` (or your preferred shell)

For more specific questions, please check the documentation or open an issue on GitHub.