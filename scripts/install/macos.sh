#!/usr/bin/env bash
# ============================================================================ #
# macOS Installation Script
# ============================================================================ #
# Installs macOS-specific tools and applications.
# This script is sourced by the main setup.sh script.
# ============================================================================ #

set -euo pipefail

# Source shared logger
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/logger.sh"

# --- Install Homebrew ---
install_homebrew() {
    if command_exists brew; then
        log_success "Homebrew already installed"
        return
    fi

    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for current session
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    log_success "Homebrew installed"
}

# --- Install base packages ---
install_base_packages() {
    log_info "Installing base packages..."

    local packages=(
        git
        stow
        curl
        unzip
        zsh
        tmux
        cmake
    )

    for package in "${packages[@]}"; do
        if brew list --formula "$package" &>/dev/null; then
            log_success "$package already installed"
        else
            log_info "Installing $package..."
            brew install "$package" || log_warning "Failed to install $package"
        fi
    done

    log_success "Base packages installed"
}

# --- Install macOS casks ---
install_casks() {
    log_info "Installing macOS applications..."

    local casks=(
        "ghostty"
        "font-jetbrains-mono-nerd-font"
    )

    for cask in "${casks[@]}"; do
        if brew list --cask "$cask" &>/dev/null; then
            log_success "$cask already installed"
        else
            log_info "Installing $cask..."
            brew install --cask "$cask" || log_warning "Failed to install $cask"
        fi
    done

    log_success "macOS applications installed"
}

# --- Install TPM (Tmux Plugin Manager) ---
install_tpm() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"

    if [[ -d "$tpm_dir" ]]; then
        log_success "TPM already installed"
        return
    fi

    log_info "Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
    log_success "TPM installed (run prefix + I in tmux to install plugins)"
}

# --- Install Cursor IDE ---
install_cursor() {
    if command_exists cursor; then
        log_success "Cursor already installed"
        return
    fi

    log_info "Installing Cursor IDE..."
    if brew list --cask cursor &>/dev/null; then
        log_success "Cursor already installed via Homebrew"
    else
        brew install --cask cursor || {
            log_warning "Homebrew install failed, trying script..."
            curl -fsSL https://cursor.com/install | bash
        }
    fi
    log_success "Cursor installed"
}

# --- Main macOS installation ---
install_macos() {
    install_homebrew
    install_base_packages
    install_casks
    install_tpm
    install_cursor
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_macos
fi
