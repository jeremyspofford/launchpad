#!/usr/bin/env bash
# ============================================================================ #
# Common Installation Script - Cross-Platform
# ============================================================================ #
# Installs core tools needed for dotfiles management on any platform.
# This script is sourced by the main setup.sh script.
# ============================================================================ #

set -euo pipefail

# --- Source shared logger ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/logger.sh"

# --- Detect Operating System ---
detect_os() {
    case "$(uname -s)" in
        Darwin)
            OS_TYPE="macos"
            ;;
        Linux)
            if grep -qi microsoft /proc/version 2>/dev/null; then
                OS_TYPE="wsl"
            else
                OS_TYPE="linux"
            fi
            ;;
        *)
            error_exit "Unsupported OS: $(uname -s)"
            ;;
    esac
    export OS_TYPE
    log_info "Detected OS: $OS_TYPE"
}

# --- Install mise ---
install_mise() {
    if command_exists mise; then
        log_success "mise already installed"
        return
    fi

    log_info "Installing mise..."
    curl https://mise.run | sh

    # Add mise to PATH for current session
    export PATH="$HOME/.local/bin:$PATH"

    if command_exists mise; then
        log_success "mise installed successfully"
    else
        error_exit "Failed to install mise"
    fi
}

# --- Install stow ---
install_stow() {
    if command_exists stow; then
        log_success "stow already installed"
        return
    fi

    log_info "Installing stow..."
    case "$OS_TYPE" in
        macos)
            brew install stow
            ;;
        linux|wsl)
            if command_exists apt-get; then
                sudo apt-get update -qq
                sudo apt-get install -y stow
            elif command_exists dnf; then
                sudo dnf install -y stow
            elif command_exists pacman; then
                sudo pacman -S --noconfirm stow
            else
                error_exit "Could not detect package manager to install stow"
            fi
            ;;
    esac
    log_success "stow installed"
}

# --- Install Oh My Zsh ---
install_oh_my_zsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log_success "Oh My Zsh already installed"
        return
    fi

    log_info "Installing Oh My Zsh..."
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

    # Install zsh plugins
    local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    fi

    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    fi

    log_success "Oh My Zsh installed with plugins"
}

# --- Run mise install ---
run_mise_install() {
    local mise_config="$HOME/.config/mise/config.toml"

    if [[ ! -f "$mise_config" ]]; then
        log_warning "config.toml not found at $mise_config - skipping tool installation"
        return
    fi

    log_info "Installing tools from config.toml..."
    mise install --yes
    log_success "mise tools installed"
}

# --- Main common installation ---
install_common() {
    detect_os
    install_mise
    install_stow
    install_oh_my_zsh
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_common
fi
