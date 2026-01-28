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

# --- Detect macOS architecture ---
detect_arch() {
    local arch=$(uname -m)
    if [[ "$arch" == "arm64" ]]; then
        echo "arm64"
    else
        echo "x86_64"
    fi
}

# --- Get Homebrew path based on architecture ---
get_brew_path() {
    local arch=$(detect_arch)
    if [[ "$arch" == "arm64" ]]; then
        echo "/opt/homebrew"
    else
        echo "/usr/local"
    fi
}

# --- Install Homebrew ---
install_homebrew() {
    if command_exists brew; then
        log_success "Homebrew already installed"
        return
    fi

    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for current session
    local brew_path=$(get_brew_path)
    if [[ -f "$brew_path/bin/brew" ]]; then
        eval "$($brew_path/bin/brew shellenv)"
        log_success "Homebrew installed at $brew_path"
    else
        log_error "Homebrew installation may have failed"
        return 1
    fi

    log_success "Homebrew installed"
}

# --- Ensure Homebrew is in PATH ---
ensure_brew_in_path() {
    if ! command_exists brew; then
        local brew_path=$(get_brew_path)
        if [[ -f "$brew_path/bin/brew" ]]; then
            eval "$($brew_path/bin/brew shellenv)"
        fi
    fi
}

# --- Install base packages ---
install_base_packages() {
    ensure_brew_in_path
    log_info "Installing base packages..."

    local packages=(
        git
        stow
        curl
        unzip
        zsh
        tmux
        cmake
        neovim
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

# --- Install dialog for menus (whiptail alternative) ---
install_dialog() {
    ensure_brew_in_path
    
    if command_exists dialog; then
        log_success "dialog already installed"
        return
    fi

    log_info "Installing dialog for interactive menus..."
    brew install dialog || log_warning "Failed to install dialog"
    
    # Note: We can't create a whiptail alias that persists across scripts easily
    # Instead, the main setup.sh should detect the platform and use dialog directly
    log_info "Note: macOS uses 'dialog' instead of 'whiptail' for menus"
}

# --- Install macOS casks ---
install_casks() {
    ensure_brew_in_path
    log_info "Installing macOS applications..."

    # Core casks that are always installed
    local core_casks=(
        "font-jetbrains-mono-nerd-font"
    )

    # Optional casks (user can add via unified_app_manager)
    local optional_casks=(
        "ghostty"
    )

    # Install core casks
    for cask in "${core_casks[@]}"; do
        if brew list --cask "$cask" &>/dev/null; then
            log_success "$cask already installed"
        else
            log_info "Installing $cask..."
            brew install --cask "$cask" || log_warning "Failed to install $cask"
        fi
    done

    # Install optional casks if available
    for cask in "${optional_casks[@]}"; do
        if brew list --cask "$cask" &>/dev/null; then
            log_success "$cask already installed"
        else
            log_info "Installing $cask..."
            # Ghostty might not be in main cask repo yet
            brew install --cask "$cask" 2>/dev/null || {
                log_info "$cask not available in Homebrew, skipping"
            }
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

# --- Configure macOS defaults ---
configure_macos_defaults() {
    log_info "Configuring macOS defaults..."

    # Show hidden files in Finder
    defaults write com.apple.finder AppleShowAllFiles -bool true

    # Show file extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # Disable press-and-hold for keys in favor of key repeat
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

    # Fast key repeat
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15

    # Show path bar in Finder
    defaults write com.apple.finder ShowPathbar -bool true

    # Keep folders on top when sorting by name
    defaults write com.apple.finder _FXSortFoldersFirst -bool true

    log_success "macOS defaults configured"
    log_info "Note: Some changes require logout/restart to take effect"
}

# --- Main macOS installation ---
install_macos() {
    log_section "macOS Installation"
    log_kv "Architecture" "$(detect_arch)"
    log_kv "Homebrew path" "$(get_brew_path)"
    echo

    install_homebrew
    install_base_packages
    install_dialog
    install_casks
    install_tpm
    
    # Ask about macOS defaults
    if command_exists dialog; then
        if dialog --title "macOS Defaults" --yesno "Would you like to configure recommended macOS defaults?\n\n- Show hidden files\n- Show file extensions\n- Fast key repeat\n- etc." 12 50; then
            configure_macos_defaults
        fi
        clear
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_macos
fi
