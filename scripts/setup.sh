#!/usr/bin/env bash

# ============================================================================ #
# Universal Dotfiles Setup Script
# ============================================================================ #
# This script handles both initial bootstrap and regular setup:
# - Detects if running on a fresh system or existing setup
# - Installs Homebrew if needed (macOS)
# - Installs Ansible if needed
# - Runs the Ansible playbook to configure everything
# 
# Can be run via curl for new machines:
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/yourusername/dotfiles/main/scripts/setup.sh)"
# ============================================================================ #

set -euo pipefail

# --- Colors for output ---
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m' 
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# --- Logging Functions ---
log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
header() { echo -e "\n${BOLD}${MAGENTA}==>${NC} ${BOLD}$1${NC}\n"; }

# --- Helper Functions ---
command_exists() { command -v "$1" >/dev/null 2>&1; }

main() {
    header "Dotfiles Setup"
    
    detect_os
    ensure_repository
    bootstrap_system
    run_ansible_playbook
    
    success "🎉 Setup complete! Your dotfiles environment is ready."
    echo ""
    echo "Next steps:"
    if [[ "$OS_TYPE" == "macos" ]]; then
        echo "  • Restart your shell: exec zsh"
    else
        echo "  • Restart your shell: exec bash"
    fi
    echo "  • Test SSH: ssh -T git@github.com"
    if [[ "$OS_TYPE" == "macos" ]]; then
        echo "  • Check modern Bash: bash --version"
    fi
}

detect_os() {
    log "Detecting operating system..."
    case "$(uname -s)" in
        Darwin) 
            OS_TYPE="macos"
            log "Detected macOS."
            ;;
        Linux)
            # Check if running in WSL
            if grep -qi microsoft /proc/version 2>/dev/null; then
                OS_TYPE="wsl"
                log "Detected WSL (Windows Subsystem for Linux)."
                # WSL typically uses bash by default
                export PREFERRED_SHELL="bash"
            else
                OS_TYPE="linux"
                log "Detected Linux."
            fi
            ;;
        *) 
            error "Unsupported OS: $(uname -s). This script supports macOS, Linux, and WSL." 
            ;;
    esac
}

ensure_repository() {
    header "Ensuring dotfiles repository"
    
    # Check if we're already in a dotfiles repo
    if [[ -f "ansible/playbook.yml" ]] && [[ -d "home" ]]; then
        log "Already in dotfiles repository at $(pwd)"
        return
    fi
    
    # Check if dotfiles exists in expected location
    if [[ -d "$HOME/workspace/dotfiles" ]]; then
        log "Found dotfiles at ~/workspace/dotfiles"
        cd "$HOME/workspace/dotfiles"
        git pull || warn "Could not update repository"
        return
    fi
    
    # Need to clone the repository
    log "Dotfiles repository not found. Setting up..."
    
    # Install GitHub CLI if needed
    if ! command_exists gh; then
        if [[ "$OS_TYPE" == "macos" ]]; then
            ensure_homebrew
            brew install gh || error "Failed to install GitHub CLI"
        elif [[ "$OS_TYPE" == "wsl" ]] || [[ "$OS_TYPE" == "linux" ]]; then
            log "Installing GitHub CLI..."
            # Install GitHub CLI on Debian/Ubuntu-based systems
            curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
            sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
            sudo apt update
            sudo apt install gh -y || error "Failed to install GitHub CLI"
        fi
    fi
    
    # Authenticate if needed
    if ! gh auth status >/dev/null 2>&1; then
        log "Please authenticate with GitHub..."
        gh auth login || error "GitHub authentication failed"
    fi
    
    # Clone repository
    # Use environment variable or try to detect repository from git remote
    DOTFILES_REPO="${DOTFILES_REPO:-jeremyspofford/dotfiles}"
    mkdir -p "$HOME/workspace"
    cd "$HOME/workspace"
    gh repo clone "$DOTFILES_REPO" || error "Failed to clone dotfiles repository: $DOTFILES_REPO"
    cd dotfiles
    success "Dotfiles repository ready."
}

ensure_homebrew() {
    if command_exists brew; then
        return
    fi
    
    log "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || error "Failed to install Homebrew"
    
    # Add Homebrew to PATH for current session
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        # Add to shell profile
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    
    success "Homebrew installed."
}

bootstrap_system() {
    header "Bootstrapping System"
    
    if command_exists ansible; then
        success "Ansible already installed."
    else
        log "Installing Ansible..."
        
        if [[ "$OS_TYPE" == "macos" ]]; then
            ensure_homebrew
            brew install ansible || error "Failed to install Ansible via Homebrew"
        elif [[ "$OS_TYPE" == "wsl" ]] || [[ "$OS_TYPE" == "linux" ]]; then
            sudo apt-get update -qq || warn "Failed to update apt list"
            sudo apt-get install -y ansible python3-pip || error "Failed to install Ansible via apt"
        fi
        
        success "Ansible installed."
    fi
    
    # Install Ansible collections
    if [[ -f "ansible/requirements.yml" ]]; then
        log "Installing Ansible collections..."
        ansible-galaxy collection install -r ansible/requirements.yml || warn "Some collections may have failed to install"
        success "Ansible collections processed."
    fi
}

run_ansible_playbook() {
    header "Running Ansible Playbook"
    
    if [[ ! -f "ansible/playbook.yml" ]]; then
        error "Ansible playbook not found at ansible/playbook.yml"
    fi
    
    log "Executing main Ansible playbook..."
    log "You may be prompted for your sudo password."
    
    # Run the playbook with privilege escalation
    ansible-playbook ansible/playbook.yml --ask-become-pass || error "Ansible playbook execution failed"
    
    success "Ansible playbook completed successfully."
}

# --- Execution ---
main
