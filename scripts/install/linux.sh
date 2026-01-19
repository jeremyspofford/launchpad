#!/usr/bin/env bash
# ============================================================================ #
# Linux Installation Script
# ============================================================================ #
# Installs Linux-specific packages based on the detected distribution.
# This script is sourced by the main setup.sh script.
# ============================================================================ #

set -euo pipefail

# Source shared logger
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/logger.sh"

# --- Detect Linux distribution ---
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        DISTRO_ID="${ID:-unknown}"
        DISTRO_LIKE="${ID_LIKE:-$ID}"
    else
        DISTRO_ID="unknown"
        DISTRO_LIKE="unknown"
    fi
    export DISTRO_ID DISTRO_LIKE
    log_info "Detected distribution: $DISTRO_ID (like: $DISTRO_LIKE)"
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

    if command_exists apt-get; then
        # Debian/Ubuntu
        sudo apt-get update -qq
        sudo apt-get install -y "${packages[@]}" build-essential
    elif command_exists dnf; then
        # Fedora/RHEL
        sudo dnf install -y "${packages[@]}" @development-tools
    elif command_exists pacman; then
        # Arch
        sudo pacman -Syu --noconfirm "${packages[@]}" base-devel
    else
        error_exit "Could not detect package manager (apt, dnf, or pacman)"
    fi

    log_success "Base packages installed"
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

# --- Install Nerd Font ---
install_nerd_font() {
    local font_dir="$HOME/.local/share/fonts"
    local font_name="JetBrainsMono"

    if fc-list | grep -qi "JetBrainsMono"; then
        log_success "JetBrainsMono Nerd Font already installed"
        return
    fi

    log_info "Installing JetBrainsMono Nerd Font..."
    mkdir -p "$font_dir"

    local font_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_name}.zip"
    local temp_zip="/tmp/${font_name}.zip"

    curl -fLo "$temp_zip" "$font_url"
    unzip -o "$temp_zip" -d "$font_dir/${font_name}"
    rm -f "$temp_zip"

    # Update font cache
    if command_exists fc-cache; then
        fc-cache -fv
    fi

    log_success "JetBrainsMono Nerd Font installed"
}

# --- Main Linux installation ---
install_linux() {
    detect_distro
    install_base_packages
    install_tpm
    install_nerd_font
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_linux
fi
