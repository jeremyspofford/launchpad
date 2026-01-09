#!/usr/bin/env bash
# ============================================================================ #
# WSL Installation Script
# ============================================================================ #
# Installs and configures WSL-specific tweaks on top of Linux setup.
# This script is sourced by the main setup.sh script.
# ============================================================================ #

set -euo pipefail

# Source common utilities if not already loaded
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if ! type log &>/dev/null; then
    source "$SCRIPT_DIR/common.sh"
fi

# --- Configure WSL interop ---
configure_wsl_interop() {
    log "Configuring WSL interop..."

    # Ensure WSL interop is enabled
    if [[ -f /proc/sys/fs/binfmt_misc/WSLInterop ]]; then
        success "WSL interop is enabled"
    else
        warn "WSL interop may not be properly configured"
    fi

    # Set up WSLENV for sharing environment variables
    if [[ -z "${WSLENV:-}" ]]; then
        log "Setting up WSLENV..."
        export WSLENV="PATH/l:USERPROFILE/pu"
    fi
}

# --- Configure clipboard integration ---
configure_clipboard() {
    log "Configuring clipboard integration..."

    # Check if clip.exe is available
    if command -v clip.exe &>/dev/null; then
        success "Windows clipboard (clip.exe) is available"
    else
        warn "clip.exe not found - clipboard integration may not work"
    fi

    # Check if powershell.exe is available for paste
    if command -v powershell.exe &>/dev/null; then
        success "PowerShell is available for clipboard operations"
    else
        warn "powershell.exe not found - paste operations may not work"
    fi
}

# --- Configure Windows home directory access ---
configure_winhome() {
    log "Configuring Windows home directory..."

    if command -v wslpath &>/dev/null && command -v cmd.exe &>/dev/null; then
        local win_userprofile
        win_userprofile=$(cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')
        if [[ -n "$win_userprofile" ]]; then
            export WINHOME
            WINHOME=$(wslpath "$win_userprofile")
            success "Windows home: $WINHOME"
        fi
    else
        warn "Could not determine Windows home directory"
    fi
}

# --- Install wslu utilities ---
install_wslu() {
    if command_exists wslview; then
        success "wslu utilities already installed"
        return
    fi

    log "Installing wslu utilities..."
    if command_exists apt-get; then
        sudo apt-get update -qq
        sudo apt-get install -y wslu || warn "wslu not available in repos"
    fi
}

# --- Main WSL installation ---
install_wsl() {
    # First run the Linux installation
    source "$SCRIPT_DIR/linux.sh"
    install_linux

    # Then apply WSL-specific configurations
    log "Applying WSL-specific configurations..."
    configure_wsl_interop
    configure_clipboard
    configure_winhome
    install_wslu

    success "WSL configuration complete"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_wsl
fi
