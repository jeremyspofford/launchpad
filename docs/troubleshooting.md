# Troubleshooting Guide

This guide helps resolve common issues encountered when using the dotfiles configuration.

## Installation Issues

### Permission Denied Errors

**Problem**: Script fails with permission errors
```bash
./install.sh: Permission denied
```

**Solution**:
```bash
# Make the script executable
chmod +x install.sh

# Or run with bash explicitly
bash install.sh
```

### Missing Dependencies

**Problem**: Installation fails due to missing system dependencies

**Solution**:
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y git curl build-essential

# macOS - Install Xcode Command Line Tools
xcode-select --install

# Windows - Install Git and PowerShell
# Download from official websites or use package managers
```

### Ansible Playbook Fails

**Problem**: Ansible installation or execution fails

**Solution**:
```bash
# Install Ansible manually
# Ubuntu/Debian
sudo apt install -y ansible

# macOS
brew install ansible

# Verify installation
ansible --version

# Re-run the playbook
ansible-playbook -i ~/dotfiles/ansible/inventory.ini ~/dotfiles/ansible/playbook.yml
```

## chezmoi Issues

### Configuration Conflicts

**Problem**: chezmoi reports conflicts or doesn't apply changes

**Solution**:
```bash
# Check what would change
chezmoi diff

# Force apply changes
chezmoi apply --force

# Re-initialize if necessary
rm -rf ~/.local/share/chezmoi
cd ~/dotfiles && chezmoi init --apply .
```

### Template Errors

**Problem**: Template rendering fails

**Solution**:
```bash
# Check template syntax
chezmoi execute-template < .chezmoi.toml.tmpl

# View template variables
chezmoi data

# Re-run initialization to reset prompts
chezmoi init --prompt
```

### File Not Found Errors

**Problem**: chezmoi can't find source files

**Solution**:
```bash
# Verify source directory
chezmoi source-path

# Check .chezmoiroot file
cat ~/.local/share/chezmoi/.chezmoiroot

# Reinitialize with correct source
chezmoi init ~/dotfiles
```

## Shell Configuration Issues

### Zsh Not Loading Configuration

**Problem**: Zsh doesn't load the custom configuration

**Solution**:
```bash
# Check if zsh is the default shell
echo $SHELL

# Change default shell to zsh
chsh -s $(which zsh)

# Source configuration manually
source ~/.zshrc

# Restart terminal session
```

### Command Not Found Errors

**Problem**: Commands like `fzf`, `rg`, `fd` not found

**Solution**:
```bash
# Check if tools are installed
which fzf rg fd exa bat

# Re-run Ansible playbook
ansible-playbook -i ~/dotfiles/ansible/inventory.ini ~/dotfiles/ansible/playbook.yml

# Add to PATH manually if needed
export PATH="$HOME/.local/bin:$PATH"
```

### Starship Prompt Not Working

**Problem**: Starship prompt doesn't appear

**Solution**:
```bash
# Check if starship is installed
starship --version

# Verify initialization in shell config
grep starship ~/.zshrc

# Reinstall starship
curl -sS https://starship.rs/install.sh | sh
```

## Git and SSH Issues

### SSH Key Problems

**Problem**: Can't connect to GitHub via SSH

**Solution**:
```bash
# Check SSH key exists
ls -la ~/.ssh/personal_id_ed25519*

# Fix permissions
chmod 600 ~/.ssh/personal_id_ed25519
chmod 644 ~/.ssh/personal_id_ed25519.pub

# Add to ssh-agent
ssh-add ~/.ssh/personal_id_ed25519

# Test connection
ssh -T git@github.com
```

### Git Configuration Issues

**Problem**: Git user information not set correctly

**Solution**:
```bash
# Check current configuration
git config --list | grep user

# Set manually if needed
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Re-apply chezmoi templates
chezmoi apply
```

## Tool-Specific Issues

### mise Version Manager

**Problem**: mise not working or tools not found

**Solution**:
```bash
# Verify mise installation
mise --version

# Check PATH includes mise shims
echo $PATH | grep mise

# Reinstall tools
mise install

# Add to shell profile if missing
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
```

### Fabric AI Tools

**Problem**: Fabric patterns not working

**Solution**:
```bash
# Check fabric installation
fabric --version

# Verify patterns directory
ls ~/.config/fabric/patterns/

# Update patterns
fabric --updatepatterns

# Reinstall if necessary
go install github.com/danielmiessler/fabric@latest
```

## Performance Issues

### Slow Shell Startup

**Problem**: Terminal takes too long to start

**Solution**:
```bash
# Profile shell startup
time zsh -i -c exit

# Disable plugins temporarily
mv ~/.config/zsh/plugins.zsh ~/.config/zsh/plugins.zsh.bak

# Identify slow components
zsh -xvs
```

### High Resource Usage

**Problem**: Tools consuming too much CPU/memory

**Solution**:
```bash
# Check running processes
ps aux | grep -E "(zsh|mise|starship)"

# Disable resource-intensive features
# Edit ~/.config/zsh/plugins.zsh
# Comment out heavy plugins
```

## Recovery Procedures

### Complete Reset

If all else fails, perform a complete reset:

```bash
# Backup current state
cp -r ~ ~/backup_$(date +%Y%m%d_%H%M%S)

# Remove chezmoi data
rm -rf ~/.local/share/chezmoi

# Remove dotfiles
rm -f ~/.zshrc ~/.bashrc ~/.gitconfig

# Re-run installation
cd ~/dotfiles && ./install.sh
```

### Partial Reset

For specific components:

```bash
# Reset shell configuration only
chezmoi forget ~/.zshrc ~/.bash_profile
rm ~/.zshrc ~/.bash_profile
chezmoi apply

# Reset git configuration only
chezmoi forget ~/.gitconfig
rm ~/.gitconfig
chezmoi apply
```

## Getting Help

### Diagnostic Information

When reporting issues, include:

```bash
# System information
uname -a
echo $SHELL

# chezmoi information
chezmoi doctor
chezmoi --version

# Tool versions
mise --version
starship --version
git --version
```

### Log Files

Check relevant log files:

```bash
# Shell history
tail ~/.zsh_history

# System logs (Linux)
journalctl --user -f

# Installation logs
tail ~/dotfiles/install.log  # if created
```

### Community Support

- **GitHub Issues**: Report bugs and feature requests
- **Discussions**: Ask questions and share tips
- **Documentation**: Check the latest docs for updates