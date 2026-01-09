#!/usr/bin/env bash
# ============================================================================ #
# Dotfiles Setup Script
# ============================================================================ #
# Main entry point for setting up dotfiles on any platform.
#
# Usage:
#   ./scripts/setup.sh [OPTIONS]
#
# Options:
#   -h, --help     Show this help message
#   -s, --stow     Only run stow (skip installations)
# ============================================================================ #

set -euo pipefail

# --- Script location ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# --- Source shared logger ---
source "$SCRIPT_DIR/lib/logger.sh"

# --- Show help ---
show_help() {
    log_heredoc "${GREEN}" <<EOF
Dotfiles Setup Script

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -h, --help     Show this help message
    -s, --stow     Only run stow (skip installations)

DESCRIPTION:
    Sets up dotfiles on macOS, Linux, or WSL by:
    1. Installing required tools (mise, stow, etc.)
    2. Symlinking dotfiles via GNU Stow
    3. Configuring Git identity (optional)
    4. Creating secrets file from template

EXAMPLES:
    $0              # Full setup
    $0 --stow       # Only symlink dotfiles
EOF
}

# --- Parse arguments ---
STOW_ONLY=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -s|--stow)
            STOW_ONLY=true
            shift
            ;;
        *)
            error_exit "Unknown option: $1"
            ;;
    esac
done

# --- Detect OS ---
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

# --- Run platform-specific installation ---
run_installation() {
    log_section "Installing Dependencies"

    # Source and run common installation
    source "$SCRIPT_DIR/install/common.sh"
    install_common

    # Run platform-specific installation
    case "$OS_TYPE" in
        macos)
            source "$SCRIPT_DIR/install/macos.sh"
            install_macos
            ;;
        linux)
            source "$SCRIPT_DIR/install/linux.sh"
            install_linux
            ;;
        wsl)
            source "$SCRIPT_DIR/install/wsl.sh"
            install_wsl
            ;;
    esac
}

# --- Run GNU Stow ---
run_stow() {
    log_section "Symlinking Dotfiles"

    cd "$DOTFILES_DIR"

    # Check for conflicts
    log_info "Checking for conflicts..."
    if ! stow -n home 2>&1 | grep -q "WARNING"; then
        log_info "No conflicts detected"
    else
        log_warning "Potential conflicts detected. You may need to backup existing files."
        stow -n home 2>&1 | grep "WARNING" || true
    fi

    # Run stow
    log_info "Running stow..."
    stow --restow home

    log_success "Dotfiles symlinked"
}

# --- Setup Git identity ---
setup_git_identity() {
    log_section "Git Identity Setup"

    local identity_file="$HOME/.config/git/identity.gitconfig"
    local template_file="$DOTFILES_DIR/home/.config/git/identity.gitconfig.template"

    if [[ -f "$identity_file" ]]; then
        log_success "Git identity already configured"
        return
    fi

    if [[ ! -f "$template_file" ]]; then
        log_warning "Identity template not found, skipping Git identity setup"
        return
    fi

    echo ""
    echo "Would you like to set up your Git identity now? (y/n)"
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "Enter your full name:"
        read -r git_name
        echo "Enter your email:"
        read -r git_email

        mkdir -p "$(dirname "$identity_file")"
        cat > "$identity_file" << EOF
[user]
    name = "$git_name"
    email = "$git_email"
EOF
        log_success "Git identity configured"
    else
        log_info "Skipping Git identity setup. You can set it up later by copying:"
        log_kv "Template" "$template_file"
        log_kv "Target" "$identity_file"
    fi
}

# --- Setup secrets ---
setup_secrets() {
    log_section "Secrets Setup"

    local secrets_file="$HOME/.secrets"
    local template_file="$DOTFILES_DIR/home/.secrets.template"

    if [[ -f "$secrets_file" ]]; then
        log_success "Secrets file already exists"
        return
    fi

    if [[ ! -f "$template_file" ]]; then
        log_warning "Secrets template not found, skipping secrets setup"
        return
    fi

    log_info "Creating secrets file from template..."
    cp "$template_file" "$secrets_file"
    chmod 600 "$secrets_file"

    log_success "Created $secrets_file (edit with your secrets or use 1Password)"
}

# --- Run mise install ---
run_mise_install() {
    log_section "Installing Development Tools"

    if ! command_exists mise; then
        log_warning "mise not installed, skipping tool installation"
        return
    fi

    local mise_config="$HOME/.config/mise/mise.toml"

    if [[ -f "$mise_config" ]]; then
        log_info "Installing tools from mise.toml..."
        mise install --yes || log_warning "Some mise tools may have failed to install"
        log_success "Development tools installed"
    else
        log_warning "mise.toml not found at $mise_config"
    fi
}

# --- Main ---
main() {
    log_section "Dotfiles Setup"

    detect_os

    if [[ "$STOW_ONLY" == "true" ]]; then
        run_stow
    else
        run_installation
        run_stow
        setup_git_identity
        setup_secrets
        run_mise_install
    fi

    log_success "🎉 Setup complete!"
    echo ""
    log_info "Next steps:"
    log_kv "Restart shell" "exec zsh"
    log_kv "Install tmux plugins" "prefix + I (in tmux)"
    if [[ ! -f "$HOME/.config/git/identity.gitconfig" ]]; then
        log_kv "Set up Git identity" "~/.config/git/identity.gitconfig"
    fi
    log_kv "Edit secrets" "~/.secrets"
}

main
