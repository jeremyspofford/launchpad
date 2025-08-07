#!/usr/bin/env bash

set -euo pipefail

# ============================================================================ #
# Modern Dotfiles Installer - Clean, Fast, Cross-Platform
# ============================================================================ #

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="${SCRIPT_DIR}/install.log"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# ============================================================================ #
# Utility Functions
# ============================================================================ #

log() { 
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}[✓]${NC} $1" | tee -a "$LOG_FILE"
}

error() { 
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
    exit 1
}

warn() { 
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
}

header() {
    echo -e "\n${BOLD}${MAGENTA}==>${NC} ${BOLD}$1${NC}\n"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

detect_os() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)
            if grep -q Microsoft /proc/version 2>/dev/null; then
                echo "wsl"
            else
                echo "linux"
            fi
            ;;
        *) echo "unknown" ;;
    esac
}

detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "${ID:-unknown}"
    else
        echo "unknown"
    fi
}

detect_arch() {
    case "$(uname -m)" in
        x86_64) echo "amd64" ;;
        aarch64|arm64) echo "arm64" ;;
        *) echo "unknown" ;;
    esac
}

# ============================================================================ #
# Package Managers
# ============================================================================ #

install_homebrew() {
    if ! command_exists brew; then
        log "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for this session
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
    success "Homebrew is installed"
}

update_package_manager() {
    local os_type="$1"
    
    case "$os_type" in
        macos)
            brew update
            ;;
        linux|wsl)
            sudo apt-get update -qq
            ;;
    esac
}

# ============================================================================ #
# Core Tools Installation
# ============================================================================ #

install_essential_packages() {
    local os_type="$1"
    header "Installing Essential Packages"
    
    case "$os_type" in
        macos)
            local packages=(
                git curl wget
                zsh tmux neovim
                fzf ripgrep bat eza fd tldr
                jq yq tree
                node npm
                gh  # GitHub CLI
                chezmoi
                starship
                gnu-sed coreutils
                # Linting tools for code quality
                shellcheck
                yamllint
            )
            
            for pkg in "${packages[@]}"; do
                if brew list "$pkg" &>/dev/null; then
                    success "$pkg already installed"
                else
                    log "Installing $pkg..."
                    brew install "$pkg"
                fi
            done
            ;;
            
        linux|wsl)
            local packages=(
                build-essential
                git curl wget
                zsh tmux neovim
                fzf ripgrep bat fd-find
                jq yq tree
                nodejs npm
                unzip fontconfig
            )
            
            log "Installing packages via apt..."
            sudo apt-get install -y "${packages[@]}"
            
            # Install exa/eza (not in standard repos)
            if ! command_exists eza && ! command_exists exa; then
                log "Installing eza..."
                local eza_url="https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz"
                curl -sL "$eza_url" | sudo tar xz -C /usr/local/bin
            fi
            
            # Install tldr and linting tools
            if ! command_exists tldr; then
                npm install -g tldr
            fi
            
            # Install linting tools for code quality
            log "Installing linting tools..."
            sudo apt-get install -y shellcheck yamllint
            
            # Install chezmoi
            if ! command_exists chezmoi; then
                log "Installing chezmoi..."
                sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
            fi
            
            # Install starship
            if ! command_exists starship; then
                log "Installing starship..."
                curl -sS https://starship.rs/install.sh | sh -s -- --yes
            fi
            
            # Install GitHub CLI
            if ! command_exists gh; then
                log "Installing GitHub CLI..."
                curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
                && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
                && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
                && sudo apt update \
                && sudo apt install gh -y
            fi
            ;;
    esac
    
    success "Essential packages installed"
}

# ============================================================================ #
# Nerd Font Installation
# ============================================================================ #

install_nerd_font() {
    header "Installing JetBrainsMono Nerd Font"
    
    local font_name="JetBrainsMono"
    local font_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_name}.tar.xz"
    local os_type="$1"
    
    case "$os_type" in
        macos)
            local font_dir="$HOME/Library/Fonts"
            ;;
        linux|wsl)
            local font_dir="$HOME/.local/share/fonts"
            mkdir -p "$font_dir"
            ;;
    esac
    
    # Check if font already installed
    if ls "$font_dir"/*JetBrains* >/dev/null 2>&1; then
        success "JetBrainsMono Nerd Font already installed"
        return 0
    fi
    
    log "Downloading JetBrainsMono Nerd Font..."
    local temp_dir=$(mktemp -d)
    curl -sL "$font_url" | tar xJ -C "$temp_dir"
    
    log "Installing font files..."
    find "$temp_dir" -name "*.ttf" -exec cp {} "$font_dir/" \;
    
    # Update font cache on Linux
    if [[ "$os_type" == "linux" ]] || [[ "$os_type" == "wsl" ]]; then
        fc-cache -fv >/dev/null 2>&1
    fi
    
    rm -rf "$temp_dir"
    success "JetBrainsMono Nerd Font installed"
}

# ============================================================================ #
# Development Tools
# ============================================================================ #

install_mise() {
    header "Installing mise (version manager)"
    
    if ! command_exists mise; then
        curl https://mise.run | sh
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    success "mise installed"
}

install_claude_cli() {
    header "Installing Claude CLI"
    
    if ! command_exists claude; then
        log "Installing Claude CLI via npm..."
        npm install -g @anthropic-ai/claude-cli
    fi
    
    success "Claude CLI installed"
}

setup_neovim() {
    header "Setting up Neovim with Kickstart"
    
    local nvim_config_dir="$HOME/.config/nvim"
    
    # Create .config directory if it doesn't exist
    mkdir -p "$(dirname "$nvim_config_dir")"
    
    # Handle existing config more robustly - check for ANY existing path
    if [[ -L "$nvim_config_dir" ]]; then
        # It's a symlink (broken or not)
        warn "Removing existing symlink at $nvim_config_dir"
        rm "$nvim_config_dir"
    elif [[ -d "$nvim_config_dir" ]]; then
        # It's a directory
        warn "Backing up existing Neovim config..."
        mv "$nvim_config_dir" "${nvim_config_dir}.backup.$(date +%Y%m%d_%H%M%S)"
    elif [[ -f "$nvim_config_dir" ]]; then
        # It's a regular file
        warn "Removing existing file at $nvim_config_dir"
        rm "$nvim_config_dir"
    elif [[ -e "$nvim_config_dir" ]]; then
        # Some other type of file system object
        warn "Removing existing object at $nvim_config_dir"
        rm -rf "$nvim_config_dir"
    fi
    
    # Clone kickstart.nvim (directory should be clear now)
    log "Installing kickstart.nvim..."
    if git clone https://github.com/nvim-lua/kickstart.nvim.git "$nvim_config_dir"; then
        success "kickstart.nvim installed successfully"
    else
        error "Failed to clone kickstart.nvim"
        return 1
    fi
    
    success "Neovim configured with kickstart.nvim"
}

# ============================================================================ #
# Dotfiles Setup
# ============================================================================ #

setup_chezmoi() {
    header "Setting up dotfiles with chezmoi"
    
    # Initialize chezmoi with this repository
    if [[ ! -d "$HOME/.local/share/chezmoi" ]]; then
        log "Initializing chezmoi..."
        chezmoi init --apply "$SCRIPT_DIR"
    else
        log "Updating chezmoi configuration..."
        chezmoi update
    fi
    
    # Configure auto-commit and push
    chezmoi git add .
    chezmoi git commit -m "Update dotfiles" || true
    
    success "Dotfiles configured with chezmoi"
}

configure_git() {
    header "Configuring Git"
    
    # Prompt for user info if not set
    if [[ -z "$(git config --global user.name)" ]]; then
        read -p "Enter your full name for Git: " git_name
        git config --global user.name "$git_name"
    fi
    
    if [[ -z "$(git config --global user.email)" ]]; then
        read -p "Enter your email for Git: " git_email
        git config --global user.email "$git_email"
    fi
    
    # Set up conditional includes for different environments
    cat > "$HOME/.gitconfig.work" <<EOF
[user]
    email = work@example.com  # Update this
EOF
    
    cat > "$HOME/.gitconfig.personal" <<EOF
[user]
    email = $(git config --global user.email)
EOF
    
    # Add conditional includes to main gitconfig
    git config --global includeIf."gitdir:~/work/".path ~/.gitconfig.work
    git config --global includeIf."gitdir:~/personal/".path ~/.gitconfig.personal
    
    success "Git configured with conditional includes"
}

configure_shell() {
    header "Configuring Shell"
    
    # Change default shell to zsh if not already
    if [[ "$SHELL" != *"zsh"* ]]; then
        log "Changing default shell to zsh..."
        chsh -s "$(which zsh)"
    fi
    
    success "Shell configured"
}

# ============================================================================ #
# Post-Installation
# ============================================================================ #

show_post_install_message() {
    echo
    echo -e "${BOLD}${GREEN}✨ Installation Complete!${NC}"
    echo
    echo -e "${CYAN}Next steps:${NC}"
    echo "  1. Restart your terminal or run: exec zsh"
    echo "  2. Configure Claude CLI: claude login"
    echo "  3. Configure GitHub CLI: gh auth login"
    echo "  4. Set up Git work email in ~/.gitconfig.work"
    echo "  5. Open Neovim and let plugins install: nvim"
    echo
    echo -e "${CYAN}Dotfiles Management:${NC}"
    echo "  • Edit configs: chezmoi edit ~/.zshrc"
    echo "  • Apply changes: chezmoi apply"
    echo "  • Update from repo: chezmoi update"
    echo "  • Add new file: chezmoi add ~/.newconfig"
    echo
    echo -e "${CYAN}Version Management:${NC}"
    echo "  • Install Node version: mise use node@20"
    echo "  • Install Python: mise use python@3.11"
    echo
}

# ============================================================================ #
# Main Installation Flow
# ============================================================================ #

main() {
    clear
    echo -e "${BOLD}${CYAN}"
    echo "╔══════════════════════════════════════════╗"
    echo "║     Modern Dotfiles Installer v2.0       ║"
    echo "║         Fast • Simple • Reliable         ║"
    echo "╚══════════════════════════════════════════╝"
    echo -e "${NC}"
    
    # Initialize log
    : > "$LOG_FILE"
    
    # Detect system
    local os_type=$(detect_os)
    local distro=$(detect_distro)
    local arch=$(detect_arch)
    
    log "System: $os_type | Distro: $distro | Arch: $arch"
    
    # Ensure ~/.local/bin is in PATH
    export PATH="$HOME/.local/bin:$PATH"
    
    # Install Homebrew on macOS
    if [[ "$os_type" == "macos" ]]; then
        install_homebrew
    fi
    
    # Update package manager
    update_package_manager "$os_type"
    
    # Install everything
    install_essential_packages "$os_type"
    install_nerd_font "$os_type"
    install_mise
    install_claude_cli
    setup_neovim
    setup_chezmoi
    configure_git
    configure_shell
    
    # Show completion message
    show_post_install_message
    
    success "Installation log saved to: $LOG_FILE"
}

# Run main if not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi