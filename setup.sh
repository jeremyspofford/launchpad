#!/usr/bin/env bash

# ============================================================================ #
# Modern Dotfiles Development Environment Setup Script
# ============================================================================ #
# This script automates the installation of essential tools for developing
# and testing Ansible dotfiles, including Ansible itself.
# It is designed to be idempotent and provide clear feedback.
# ============================================================================ #

set -euo pipefail

# --- Colors for output ---
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
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

# --- State Tracking ---
OS_TYPE=""
ANSIBLE_STATUS="Not found"
PIP_STATUS="Not found"
COLLECTIONS_STATUS="Not applicable"

# --- Main Logic ---

main() {
    header "Starting Dotfiles Development Environment Setup"
    detect_os
    check_initial_status
    ensure_ansible
    ensure_pip
    install_collections
    print_summary
    success "Setup script finished."
}

detect_os() {
    log "Detecting operating system..."
    case "$(uname -s)" in
        Darwin) OS_TYPE="macos"; log "Detected macOS." ;;
        Linux) OS_TYPE="linux"; log "Detected Linux." ;;
        *) error "Unsupported OS: $(uname -s). This script supports macOS and Linux." ;;
    esac
}

check_initial_status() {
    log "Checking initial tool status..."
    if command_exists ansible; then ANSIBLE_STATUS="Already present"; fi
    if command_exists pip3; then PIP_STATUS="Already present"; fi
    success "Initial status checked."
}

ensure_homebrew() {
    if [[ "$OS_TYPE" == "macos" ]] && ! command_exists brew;
    then
        log "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        success "Homebrew installed."
    else
        log "Homebrew already present or not on macOS."
    fi
}

ensure_ansible() {
    header "Ensuring Ansible is installed"
    if [[ "$ANSIBLE_STATUS" == "Not found" ]]; then
        log "Ansible not found. Installing Ansible..."
        if [[ "$OS_TYPE" == "macos" ]]; then
            ensure_homebrew
            brew install ansible || error "Failed to install Ansible via Homebrew."
        elif [[ "$OS_TYPE" == "linux" ]]; then
            log "Updating apt package list..."
            sudo apt-get update -qq || warn "Failed to update apt list. Continuing anyway."
            sudo apt-get install -y ansible || error "Failed to install Ansible via apt."
        fi
        ANSIBLE_STATUS="Installed"
        success "Ansible installed."
    else
        log "Ansible is already present."
    fi
}

ensure_pip() {
    header "Ensuring pip (Python package installer) is installed"
    if [[ "$PIP_STATUS" == "Not found" ]]; then
        log "pip3 not found. Installing pip..."
        if [[ "$OS_TYPE" == "linux" ]]; then
            sudo apt-get install -y python3-pip || error "Failed to install python3-pip via apt."
        elif [[ "$OS_TYPE" == "macos" ]]; then
            # On macOS, pip3 usually comes with Python 3, installed by Homebrew's ansible dependency
            log "On macOS, pip3 is typically installed with Python 3 via Homebrew. Verifying..."
            if ! command_exists pip3;
            then
                error "pip3 not found after Ansible installation. Please ensure Python 3 and pip3 are installed."
            fi
        fi
        PIP_STATUS="Installed"
        success "pip installed."
    else
        log "pip is already present."
    fi
}

install_collections() {
    header "Installing Ansible Collections"
    if [ -f "ansible/requirements.yml" ]; then
        log "Found ansible/requirements.yml. Installing collections..."
        ansible-galaxy collection install -r ansible/requirements.yml > /dev/null || error "Failed to install Ansible collections."
        COLLECTIONS_STATUS="Updated"
        success "Ansible collections installed/updated."
    else
        warn "ansible/requirements.yml not found. Skipping collection installation."
        COLLECTIONS_STATUS="requirements.yml not found"
    fi
}

print_summary() {
    header "Setup Summary"
    echo "Ansible:      $ANSIBLE_STATUS"
    echo "pip:          $PIP_STATUS"
    echo "Collections:  $COLLECTIONS_STATUS"
    echo "------------------------------------------------------------"
}

# --- Execution ---
main
