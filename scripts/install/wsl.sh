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

    # Create clipboard helper scripts
    local bin_dir="$HOME/.local/bin"
    mkdir -p "$bin_dir"

    # Create a cross-platform copy script
    cat > "$bin_dir/cb-copy" << 'EOF'
#!/bin/bash
# Cross-platform clipboard copy for WSL
if command -v clip.exe &>/dev/null; then
    clip.exe
elif command -v xclip &>/dev/null; then
    xclip -selection clipboard
elif command -v pbcopy &>/dev/null; then
    pbcopy
else
    cat  # fallback: just output
fi
EOF
    chmod +x "$bin_dir/cb-copy"

    # Create a cross-platform paste script
    cat > "$bin_dir/cb-paste" << 'EOF'
#!/bin/bash
# Cross-platform clipboard paste for WSL
if command -v powershell.exe &>/dev/null; then
    powershell.exe -command "Get-Clipboard" | tr -d '\r'
elif command -v xclip &>/dev/null; then
    xclip -selection clipboard -o
elif command -v pbpaste &>/dev/null; then
    pbpaste
else
    echo "No clipboard tool available" >&2
fi
EOF
    chmod +x "$bin_dir/cb-paste"

    log_success "Created clipboard helpers: cb-copy, cb-paste"
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
            
            # Create convenient symlink
            if [[ ! -L "$HOME/winhome" ]] && [[ -d "$WINHOME" ]]; then
                ln -sf "$WINHOME" "$HOME/winhome"
                log_success "Created symlink: ~/winhome -> $WINHOME"
            fi
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

# --- Configure WSL settings ---
configure_wsl_conf() {
    log_info "Checking WSL configuration..."

    local wsl_conf="/etc/wsl.conf"
    
    if [[ -f "$wsl_conf" ]]; then
        log_info "Existing wsl.conf found:"
        cat "$wsl_conf"
    else
        log_info "No wsl.conf found. Recommended settings:"
        log_heredoc "${CYAN}" << 'EOF'
# /etc/wsl.conf - Recommended settings
# Run: sudo nano /etc/wsl.conf

[automount]
enabled = true
options = "metadata,umask=22,fmask=11"

[interop]
enabled = true
appendWindowsPath = true

[network]
generateResolvConf = true

[boot]
systemd = true
EOF
        echo
        log_warning "To apply these settings, create /etc/wsl.conf and restart WSL"
        log_info "Restart WSL with: wsl.exe --shutdown (from Windows)"
    fi
}

# --- Configure Neovim clipboard for WSL ---
configure_nvim_clipboard() {
    log_info "Configuring Neovim clipboard for WSL..."
    
    # Create neovim WSL-specific config
    local nvim_wsl_config="$HOME/.config/nvim/lua/config/wsl.lua"
    mkdir -p "$(dirname "$nvim_wsl_config")"
    
    cat > "$nvim_wsl_config" << 'EOF'
-- WSL-specific Neovim configuration
-- This file is auto-generated by dotfiles setup

if vim.fn.has("wsl") == 1 then
  -- Use Windows clipboard via clip.exe and powershell
  vim.g.clipboard = {
    name = "WslClipboard",
    copy = {
      ["+"] = "clip.exe",
      ["*"] = "clip.exe",
    },
    paste = {
      ["+"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      ["*"] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    },
    cache_enabled = false,
  }
end
EOF
    
    log_success "Created Neovim WSL clipboard config"
    log_info "Add: require('config.wsl') to your init.lua if not auto-loaded"
}

# --- Configure tmux clipboard for WSL ---
configure_tmux_clipboard() {
    log_info "Configuring tmux clipboard for WSL..."
    
    # Create tmux WSL-specific config
    local tmux_wsl_config="$HOME/.tmux.wsl.conf"
    
    cat > "$tmux_wsl_config" << 'EOF'
# WSL-specific tmux configuration
# Source this in your .tmux.conf: source-file ~/.tmux.wsl.conf

# Use Windows clipboard
set -g set-clipboard on

# Copy to Windows clipboard
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "clip.exe"
bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "clip.exe"

# Mouse selection copies to Windows clipboard
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "clip.exe"
EOF
    
    log_success "Created tmux WSL clipboard config: ~/.tmux.wsl.conf"
    log_info "Add: source-file ~/.tmux.wsl.conf to your .tmux.conf"
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
    configure_wsl_conf
    configure_nvim_clipboard
    configure_tmux_clipboard

    log_success "WSL configuration complete"
    echo
    log_info "WSL Tips:"
    log_info "  - Access Windows files: cd ~/winhome"
    log_info "  - Open file in Windows: wslview <file>"
    log_info "  - Copy to clipboard: echo 'text' | cb-copy"
    log_info "  - Paste from clipboard: cb-paste"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_wsl
fi
