#!/usr/bin/env bash
# ============================================================================ #
# macOS Installation Script
# ============================================================================ #
# Installs macOS-specific tools and applications.
# This script is sourced by the main setup.sh script.
# ============================================================================ #

set -euo pipefail

# Source common utilities if not already loaded
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if ! type log &>/dev/null; then
    source "$SCRIPT_DIR/common.sh"
fi

# --- Install Homebrew ---
install_homebrew() {
    if command_exists brew; then
        success "Homebrew already installed"
        return
    fi

    log "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for current session
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi

    success "Homebrew installed"
}

# --- Install macOS casks ---
install_casks() {
    log "Installing macOS applications..."

    local casks=(
        "ghostty"
        "font-jetbrains-mono-nerd-font"
    )

    for cask in "${casks[@]}"; do
        if brew list --cask "$cask" &>/dev/null; then
            success "$cask already installed"
        else
            log "Installing $cask..."
            brew install --cask "$cask" || warn "Failed to install $cask"
        fi
    done

    success "macOS applications installed"
}

# --- Install TPM (Tmux Plugin Manager) ---
install_tpm() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"

    if [[ -d "$tpm_dir" ]]; then
        success "TPM already installed"
        return
    fi

    log "Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
    success "TPM installed (run prefix + I in tmux to install plugins)"
}

# --- Main macOS installation ---
install_macos() {
    install_homebrew
    install_casks
    install_tpm
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_macos
fi
