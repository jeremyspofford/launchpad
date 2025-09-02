#!/usr/bin/env bash

set -euo pipefail

# ============================================================================ #
# Modern Dotfiles Installer - Clean, Fast, Cross-Platform
# ============================================================================ #

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="${SCRIPT_DIR}/install.log"

# Global CI mode flag
CI_MODE=false

# Security: Set secure umask
umask 022

# Error handling function
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        error "Installation failed with exit code $exit_code"
        log "Check the log file for details: $LOG_FILE"
    fi
    # Clean up any temporary files
    if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Set up trap for cleanup
trap cleanup EXIT

# Security function for verified downloads
secure_download() {
    local url="$1"
    local output="$2"
    local expected_checksum="${3:-}"
    
    log "Downloading from: $url"
    if curl -fsSL "$url" -o "$output"; then
        if [[ -n "$expected_checksum" ]]; then
            local actual_checksum
            actual_checksum=$(sha256sum "$output" | cut -d' ' -f1)
            if [[ "$actual_checksum" != "$expected_checksum" ]]; then
                error "Checksum verification failed for $output"
                return 1
            else
                log "Checksum verification passed"
            fi
        else
            warn "Download completed without checksum verification"
        fi
        return 0
    else
        error "Failed to download from $url"
        return 1
    fi
}

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

# Input validation functions
validate_email() {
    local email="$1"
    if [[ "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

validate_username() {
    local username="$1"
    if [[ "$username" =~ ^[A-Za-z0-9]([A-Za-z0-9]|-[A-Za-z0-9])*$ ]]; then
        return 0
    else
        return 1
    fi
}

# Secure input function
secure_read() {
    local prompt="$1"
    local validator="$2"
    local value
    
    while true; do
        read -p "$prompt" value
        if [[ -n "$value" ]] && $validator "$value"; then
            echo "$value"
            return 0
        else
            warn "Invalid input. Please try again."
        fi
    done
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
        # Download to temporary file for security
        local temp_homebrew_script
        temp_homebrew_script=$(mktemp)
        curl -fsSL "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh" -o "$temp_homebrew_script" || error "Failed to download Homebrew installer"
        # Note: Homebrew script includes its own integrity checks
        bash "$temp_homebrew_script" || error "Homebrew installation failed"
        rm "$temp_homebrew_script"
        
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
                # zsh 
		# tmux 
		neovim
                fzf ripgrep bat eza fd tldr
                jq yq tree
                node npm
                gh  # GitHub CLI
                # chezmoi
                # starship
                gnu-sed coreutils
                # Linting tools for code quality
                shellcheck
                yamllint
                # Cloud CLI tools
                # azure-cli
            )
            
            for pkg in "${packages[@]}"; do
                if brew list "$pkg" &>/dev/null; then
                    success "$pkg already installed"
                else
                    log "Installing $pkg..."
                    brew install "$pkg"
                fi
            done
            
            # Install Google Cloud SDK as a cask
            if ! brew list --cask google-cloud-sdk &>/dev/null; then
                log "Installing Google Cloud SDK..."
                brew install --cask google-cloud-sdk
            else
                success "Google Cloud SDK already installed"
            fi
            ;;
            
        linux|wsl)
            local packages=(
                build-essential
                git 
		curl 
		wget
                # zsh 
		# tmux 
                fzf 
		ripgrep 
		bat 
		fd-find
                jq 
		yq 
		tree
                nodejs 
		npm
                unzip 
		python3-pip
		fontconfig
            )
            
            log "Installing packages..."
            sudo apt-get install -y "${packages[@]}"
            
            # Install exa/eza (not in standard repos)
            if ! command_exists eza && ! command_exists exa; then
                log "Installing eza..."
                local eza_url="https://github.com/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-gnu.tar.gz"
                local temp_eza_file
                temp_eza_file=$(mktemp)
                
                if curl -fsSL "$eza_url" -o "$temp_eza_file"; then
                    sudo tar xzf "$temp_eza_file" -C /usr/local/bin --no-same-owner
                    rm "$temp_eza_file"
                else
                    warn "Failed to download eza, continuing without it..."
                    rm -f "$temp_eza_file"
                fi
            fi

	    # Install Neovim
	    if ! command_exists nvim; then
               log "Installing Neovim..."
	       curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
               sudo rm -rf /opt/nvim
	       sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
	       rm nvim-linux-x86_64.tar.gz
	       echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.bashrc
	       echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.zshrc
	    fi

	    # Install nvm
	    if ! command_exists nvm; then
		log "Installing nvm..."
                curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
	    fi

            # Install tldr and linting tools
            if ! command_exists tldr; then
                npm install -g tldr
		# pip3 install tldr --break-system-packages
            fi
            
            # Install linting tools for code quality
            log "Installing linting tools..."
            sudo apt-get install -y shellcheck yamllint
            
            # Install chezmoi
            if ! command_exists chezmoi; then
                log "Installing chezmoi..."
                local temp_chezmoi_script
                temp_chezmoi_script=$(mktemp)
                curl -fsSL "https://get.chezmoi.io" -o "$temp_chezmoi_script" || error "Failed to download chezmoi installer"
                sh "$temp_chezmoi_script" -b ~/.local/bin || error "Chezmoi installation failed"
                rm "$temp_chezmoi_script"
            fi
            
            # Install starship
            if ! command_exists starship; then
                log "Installing starship..."
                local temp_starship_script
                temp_starship_script=$(mktemp)
                curl -fsSL "https://starship.rs/install.sh" -o "$temp_starship_script" || error "Failed to download starship installer"
                sh "$temp_starship_script" --yes || error "Starship installation failed"
                rm "$temp_starship_script"
            fi
            
            # Install GitHub CLI
            if ! command_exists gh; then
                log "Installing GitHub CLI..."
                local temp_gh_key
                temp_gh_key=$(mktemp)
                
                if curl -fsSL "https://cli.github.com/packages/githubcli-archive-keyring.gpg" -o "$temp_gh_key"; then
                    sudo dd if="$temp_gh_key" of="/usr/share/keyrings/githubcli-archive-keyring.gpg" bs=1M
                    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
                    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
                    if sudo apt update; then
                        sudo apt install gh -y || warn "GitHub CLI installation failed, continuing..."
                    else
                        warn "Failed to update package list for GitHub CLI, skipping installation"
                    fi
                    rm "$temp_gh_key"
                else
                    warn "Failed to download GitHub CLI GPG key, skipping installation"
                    rm -f "$temp_gh_key"
                fi
            fi
            
            # Install AWS CLI v2
            if ! command_exists aws; then
                log "Installing AWS CLI v2..."
                local temp_dir
                temp_dir=$(mktemp -d)
                cd "$temp_dir"
                curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" || error "Failed to download AWS CLI"
                unzip awscliv2.zip
                sudo ./aws/install || error "AWS CLI installation failed"
                cd - >/dev/null
                rm -rf "$temp_dir"
            fi
            
            # Install Azure CLI
            # if ! command_exists az; then
            #    log "Installing Azure CLI..."
            #    local temp_azure_script
            #    temp_azure_script=$(mktemp)
            #    curl -fsSL "https://aka.ms/InstallAzureCLIDeb" -o "$temp_azure_script" || error "Failed to download Azure CLI installer"
            #    sudo bash "$temp_azure_script" || error "Azure CLI installation failed"
            #    rm "$temp_azure_script"
            # fi
            
            # Install Google Cloud SDK
            if ! command_exists gcloud; then
                log "Installing Google Cloud SDK..."
                # Use modern GPG key management with proper error handling
                if curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg; then
                    sudo chmod 644 /usr/share/keyrings/cloud.google.gpg
                    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list > /dev/null
                    if sudo apt-get update; then
                        sudo apt-get install google-cloud-cli -y || warn "Google Cloud CLI installation failed, continuing..."
                    else
                        warn "Failed to update package list for Google Cloud SDK, skipping installation"
                    fi
                else
                    warn "Failed to add Google Cloud GPG key, skipping Google Cloud SDK installation"
                fi
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
    local temp_dir
    temp_dir=$(mktemp -d)
    local temp_font_file
    temp_font_file=$(mktemp --suffix=.tar.xz)
    
    if curl -fsSL "$font_url" -o "$temp_font_file"; then
        if tar xJf "$temp_font_file" -C "$temp_dir"; then
            log "Font archive extracted successfully"
        else
            error "Failed to extract font archive"
            return 1
        fi
        rm "$temp_font_file"
    else
        error "Failed to download font"
        return 1
    fi
    
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
        log "Installing mise..."
        local temp_mise_script
        temp_mise_script=$(mktemp)
        curl -fsSL "https://mise.run" -o "$temp_mise_script" || error "Failed to download mise installer"
        sh "$temp_mise_script" || error "mise installation failed"
        rm "$temp_mise_script"
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    success "mise installed"
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
    
    # Get user data for chezmoi templates
    local git_email=$(git config --global user.email)
    local git_name=$(git config --global user.name)
    
    if [[ -z "$git_email" ]]; then
        if [[ "$CI_MODE" == "true" ]]; then
            git_email="ci-test@example.com"
        else
            # git_email=$(secure_read "Enter your email address: " validate_email)
            github_username="23528024+jeremyspofford@users.noreply.github.com"
        fi
    fi
    if [[ -z "$git_name" ]]; then
        if [[ "$CI_MODE" == "true" ]]; then
            git_name="CI Test User"
        else
            read -p "Enter your full name: " git_name
        fi
    fi
    
    if [[ "$CI_MODE" == "true" ]]; then
        github_username="ci-test-user"
    else
        # github_username=$(secure_read "Enter your GitHub username: " validate_username)
        github_username="23528024+jeremyspofford@users.noreply.github.com"
    fi
    
    # Create chezmoi config with the data
    mkdir -p ~/.config/chezmoi
    local work_email=""
    cat > ~/.config/chezmoi/chezmoi.toml <<EOF
[data]
    email = "$git_email"
    name = "$git_name"
    github_username = "$github_username"
    work_email = "$work_email"

[git]
    autoCommit = false
    autoPush = false
EOF
    
    # Initialize chezmoi with this repository
    if [[ ! -d "$HOME/.local/share/chezmoi" ]]; then
        log "Initializing chezmoi..."
        chezmoi init --apply "$SCRIPT_DIR"
    else
        log "Updating chezmoi configuration..."
        chezmoi apply
    fi
    
    success "Dotfiles configured with chezmoi"
}

configure_git() {
    header "Configuring Git"
    
    # Prompt for user info if not set
    if [[ -z "$(git config --global user.name)" ]]; then
        if [[ "$CI_MODE" == "true" ]]; then
            git_name="CI Test User"
        else
	    git_name="Jeremy Spofford"
        fi
        git config --global user.name "$git_name"
    fi
    
    if [[ -z "$(git config --global user.email)" ]]; then
        if [[ "$CI_MODE" == "true" ]]; then
            git_email="ci-test@example.com"
        else
            # git_email=$(secure_read "Enter your email for Git: " validate_email)
	    git_email="23528024+jeremyspofford@users.noreply.github.com"
        fi
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

install_ai() {
    local app="Cursor Agent CLI"
    header "Installing ${app}"
    if ! command_exists cursor-agent; then
        log "Installing ${app}..."
        curl https://cursor.com/install -fsSL | bash
        success "${app} installed"
    fi

    local app="Gemini CLI"
    header "Installing ${app}"
    if ! command_exists gemini; then
        log "Installing ${app}..."
        npm install -g @google/gemini-cli
        success "${app} installed"
    fi
    
    local app="Claude CLI"
    header "Installing ${app}"
    if ! command_exists claude; then
        log "Installing ${app}..."
	npm install -g @anthropic-ai/claude-code
        success "${app} installed"
    fi

    local app="Amazon Q CLI"
    header "Installing ${app}"
    if ! command_exists q; then
        log "Installing ${app}..."
	sudo apt-get install -y libayatana-appindicator3-1 libwebkit2gtk-4.1-0
        wget https://desktop-release.q.us-east-1.amazonaws.com/latest/amazon-q.deb
	sudo dpkg -i amazon-q.deb
        sudo apt-get install -f
        success "${app} installed"
    fi
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
    # Parse command line arguments for CI/automation
    local minimal_mode=false
    local no_backup=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --yes|--ci)
                CI_MODE=true
                shift
                ;;
            --minimal)
                minimal_mode=true
                shift
                ;;
            --no-backup)
                no_backup=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    
    # Skip UI in CI mode
    if [[ "$CI_MODE" == "false" ]]; then
        clear
        echo -e "${BOLD}${CYAN}"
        echo "╔══════════════════════════════════════════╗"
        echo "║     Modern Dotfiles Installer v2.0       ║"
        echo "║         Fast • Simple • Reliable         ║"
        echo "╚══════════════════════════════════════════╝"
        echo -e "${NC}"
    fi
    
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
    setup_neovim
    configure_git
    setup_chezmoi
    configure_shell
    install_ai
    
    # Show completion message
    show_post_install_message
    
    success "Installation log saved to: $LOG_FILE"
}

# Run main if not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
