#!/usr/bin/env bash

################################################################################
# Bootstrap Script for Dotfiles
# 
# This script:
# 1. Clones the dotfiles repository (HTTPS for read-only access)
# 2. Runs the main setup script
# 3. Provides instructions for SSH setup (if you forked the repo)
#
# Usage:
#   bash <(curl -fsSL https://raw.githubusercontent.com/jeremyspofford/dotfiles/main/scripts/bootstrap.sh)
#
################################################################################

set -e

# Configuration
DOTFILES_REPO="https://github.com/jeremyspofford/dotfiles.git"
DOTFILES_DIR="$HOME/workspace/dotfiles"
GITHUB_USER="jeremyspofford"
REPO_NAME="dotfiles"

################################################################################
# Load logger functions
################################################################################

# If running from curl, download logger.sh temporarily
if [ ! -f "$(dirname "$0")/logger.sh" ]; then
    TEMP_LOGGER=$(mktemp)
    curl -fsSL https://raw.githubusercontent.com/jeremyspofford/dotfiles/main/scripts/logger.sh > "$TEMP_LOGGER"
    source "$TEMP_LOGGER"
    trap "rm -f $TEMP_LOGGER" EXIT
else
    # Running from cloned repo
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$SCRIPT_DIR/logger.sh"
fi

################################################################################
# Note: SSH conversion removed to support public use
# Users who fork this repo can manually set SSH URL:
#   cd ~/workspace/dotfiles
#   git remote set-url origin git@github.com:YOUR_USERNAME/dotfiles.git
################################################################################

################################################################################
# Check Prerequisites
################################################################################

check_prerequisites() {
    log_section "Checking Prerequisites"
    
    # Check for git
    if ! command_exists git; then
        log_error "Git is not installed"
        log_info "Installing Git..."
        sudo apt-get update && sudo apt-get install -y git
    else
        log_success "✅ Git is installed ($(git --version))"
    fi
    
    # Check for curl
    if ! command_exists curl; then
        log_error "curl is not installed"
        log_info "Installing curl..."
        sudo apt-get update && sudo apt-get install -y curl
    else
        log_success "✅ curl is installed"
    fi
    
    echo
}

################################################################################
# Clone Repository
################################################################################

clone_repository() {
    log_section "Cloning Dotfiles Repository"
    
    # Create workspace directory if it doesn't exist
    if [ ! -d "$HOME/workspace" ]; then
        log_info "Creating workspace directory..."
        mkdir -p "$HOME/workspace"
    fi
    
    # Clone or update repository
    if [ -d "$DOTFILES_DIR" ]; then
        log_warning "Dotfiles directory already exists at $DOTFILES_DIR"
        log_info "Pulling latest changes..."
        cd "$DOTFILES_DIR"
        git pull
    else
        log_info "Cloning repository to $DOTFILES_DIR..."
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
        cd "$DOTFILES_DIR"
        log_success "✅ Repository cloned successfully"
    fi
    
    echo
}

################################################################################
# Run Setup Script
################################################################################

run_setup() {
    log_section "Running Setup Script"
    
    cd "$DOTFILES_DIR"
    
    if [ ! -f "scripts/setup.sh" ]; then
        error_exit "Setup script not found at scripts/setup.sh"
    fi
    
    # Make setup script executable
    chmod +x scripts/setup.sh
    
    # Run setup script
    log_info "Running setup script..."
    echo
    ./scripts/setup.sh "$@"
    
    echo
}

################################################################################
# Post-Install Instructions
################################################################################

show_post_install() {
    log_section "Setup Complete!"
    
    log_heredoc "${GREEN}" << 'EOF'

✅ Dotfiles repository cloned and setup complete

EOF
    
    log_heredoc "${YELLOW}" << 'EOF'
⚠️  Next Steps:

1. Set up SSH keys for GitHub (if not already done):
   
   ssh-keygen -t ed25519 -C "your_email@example.com"
   
   Then add the public key to GitHub:
   cat ~/.ssh/id_ed25519.pub
   # Copy output and add to https://github.com/settings/keys

2. If you forked this repo and want to push changes:
   
   cd ~/workspace/dotfiles
   git remote set-url origin git@github.com:YOUR_USERNAME/dotfiles.git
   
   # Verify the change
   git remote -v

3. Test SSH connection to GitHub:
   
   ssh -T git@github.com
   # Should see: "Hi USERNAME! You've successfully authenticated..."

4. Configure your Git identity:
   
   cd ~/workspace/dotfiles
   cp home/.config/git/identity.gitconfig.template home/.config/git/identity.gitconfig
   vim home/.config/git/identity.gitconfig

5. Configure secrets (API keys, tokens):
   
   cp ~/.secrets.template ~/.secrets
   vim ~/.secrets

6. Log out and back in for shell changes to take effect

EOF
    
    log_kv "📝 Dotfiles location" "$DOTFILES_DIR"
    echo
    log_info "To revert these changes:"
    log_info "   cd ~/workspace/dotfiles"
    log_info "   ./scripts/setup.sh --revert"
    echo
    
    log_section "Happy Hacking! 🚀"
}

################################################################################
# Main
################################################################################

main() {
    log_section "Dotfiles Bootstrap"
    echo "This script will set up your dotfiles environment"
    echo
    
    check_prerequisites
    clone_repository
    run_setup "$@"
    show_post_install
}

main "$@"
