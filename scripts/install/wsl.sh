#!/usr/bin/env bash
# ============================================================================ #
# WSL Installation Script
# ============================================================================ #
# Installs and configures WSL-specific tweaks on top of Linux setup.
# This script is sourced by the main setup.sh script.
# ============================================================================ #

set -euo pipefail

# Source shared logger
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/logger.sh"

# --- Configure WSL interop ---
configure_wsl_interop() {
    log_info "Configuring WSL interop..."

    # Ensure WSL interop is enabled
    if [[ -f /proc/sys/fs/binfmt_misc/WSLInterop ]]; then
        log_success "WSL interop is enabled"
    else
        log_warning "WSL interop may not be properly configured"
    fi

    # Set up WSLENV for sharing environment variables
    if [[ -z "${WSLENV:-}" ]]; then
        log_info "Setting up WSLENV..."
        export WSLENV="PATH/l:USERPROFILE/pu"
    fi
}

# --- Configure clipboard integration ---
configure_clipboard() {
    log_info "Configuring clipboard integration..."

    # Check if clip.exe is available
    if command -v clip.exe &>/dev/null; then
        log_success "Windows clipboard (clip.exe) is available"
    else
        log_warning "clip.exe not found - clipboard integration may not work"
    fi

    # Check if powershell.exe is available for paste
    if command -v powershell.exe &>/dev/null; then
        log_success "PowerShell is available for clipboard operations"
    else
        log_warning "powershell.exe not found - paste operations may not work"
    fi
}

# --- Configure Windows home directory access ---
configure_winhome() {
    log_info "Configuring Windows home directory..."

    if command -v wslpath &>/dev/null && command -v cmd.exe &>/dev/null; then
        local win_userprofile
        win_userprofile=$(cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')
        if [[ -n "$win_userprofile" ]]; then
            export WINHOME
            WINHOME=$(wslpath "$win_userprofile")
            log_success "Windows home: $WINHOME"
        fi
    else
        log_warning "Could not determine Windows home directory"
    fi
}

# --- Install wslu utilities ---
install_wslu() {
    if command_exists wslview; then
        log_success "wslu utilities already installed"
        return
    fi

    log_info "Installing wslu utilities..."
    if command_exists apt-get; then
        sudo apt-get update -qq
        sudo apt-get install -y wslu || log_warning "wslu not available in repos"
    fi
}

# --- Main WSL installation ---
install_wsl() {
    # First run the Linux installation
    source "$SCRIPT_DIR/linux.sh"
    install_linux

    # Then apply WSL-specific configurations
    log_section "Applying WSL-specific configurations"
    configure_wsl_interop
    configure_clipboard
    configure_winhome
    install_wslu

    log_success "WSL configuration complete"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_wsl
fi
