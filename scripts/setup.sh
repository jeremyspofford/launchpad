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

# --- Colors for output ---
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# --- Logging Functions ---
log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; exit 1; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
header() { echo -e "\n${BOLD}${MAGENTA}==>${NC} ${BOLD}$1${NC}\n"; }

# --- Helper Functions ---
command_exists() { command -v "$1" >/dev/null 2>&1; }

# --- Show help ---
show_help() {
    cat << EOF
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
            error "Unknown option: $1"
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
            error "Unsupported OS: $(uname -s)"
            ;;
    esac
    export OS_TYPE
    log "Detected OS: $OS_TYPE"
}

# --- Run platform-specific installation ---
run_installation() {
    header "Installing Dependencies"

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
    header "Symlinking Dotfiles"

    cd "$DOTFILES_DIR"

    # Check for conflicts
    log "Checking for conflicts..."
    if ! stow -n home 2>&1 | grep -q "WARNING"; then
        log "No conflicts detected"
    else
        warn "Potential conflicts detected. You may need to backup existing files."
        stow -n home 2>&1 | grep "WARNING" || true
    fi

    # Run stow
    log "Running stow..."
    stow --restow home

    success "Dotfiles symlinked"
}

# --- Setup Git identity ---
setup_git_identity() {
    header "Git Identity Setup"

    local identity_file="$HOME/.config/git/identity.gitconfig"
    local template_file="$DOTFILES_DIR/home/.config/git/identity.gitconfig.template"

    if [[ -f "$identity_file" ]]; then
        success "Git identity already configured"
        return
    fi

    if [[ ! -f "$template_file" ]]; then
        warn "Identity template not found, skipping Git identity setup"
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
        success "Git identity configured"
    else
        log "Skipping Git identity setup. You can set it up later by copying:"
        log "  $template_file -> $identity_file"
    fi
}

# --- Setup secrets ---
setup_secrets() {
    header "Secrets Setup"

    local secrets_file="$HOME/.secrets"
    local template_file="$DOTFILES_DIR/home/.secrets.template"

    if [[ -f "$secrets_file" ]]; then
        success "Secrets file already exists"
        return
    fi

    if [[ ! -f "$template_file" ]]; then
        warn "Secrets template not found, skipping secrets setup"
        return
    fi

    log "Creating secrets file from template..."
    cp "$template_file" "$secrets_file"
    chmod 600 "$secrets_file"

    success "Created $secrets_file (edit with your secrets or use 1Password)"
}

# --- Run mise install ---
run_mise_install() {
    header "Installing Development Tools"

    if ! command_exists mise; then
        warn "mise not installed, skipping tool installation"
        return
    fi

    local mise_config="$HOME/.config/mise/mise.toml"

    if [[ -f "$mise_config" ]]; then
        log "Installing tools from mise.toml..."
        mise install --yes || warn "Some mise tools may have failed to install"
        success "Development tools installed"
    else
        warn "mise.toml not found at $mise_config"
    fi
}

# --- Main ---
main() {
    header "Dotfiles Setup"

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

    success "🎉 Setup complete!"
    echo ""
    echo "Next steps:"
    echo "  • Restart your shell: exec zsh"
    echo "  • Install tmux plugins: prefix + I (in tmux)"
    if [[ ! -f "$HOME/.config/git/identity.gitconfig" ]]; then
        echo "  • Set up Git identity in ~/.config/git/identity.gitconfig"
    fi
    echo "  • Edit ~/.secrets with your API keys"
}

main
