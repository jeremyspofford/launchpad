#!/usr/bin/env bash

# ============================================================================ #
# Dotfiles Setup Validation Script
# ============================================================================ #
# Validates that the dotfiles setup completed successfully by checking:
# - Stow symlinks are correctly created
# - Shell configurations load without errors
# - Essential tools are installed and accessible
# - SSH keys have correct permissions
# - Git configuration is properly set up
# ============================================================================ #

set -euo pipefail

# --- Colors for output ---
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m' 
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# --- Logging Functions ---
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }
header() { echo -e "\n${BOLD}${BLUE}==>${NC} ${BOLD}$1${NC}\n"; }

# --- Validation counters ---
PASSED=0
FAILED=0
WARNINGS=0

check_passed() { PASSED=$((PASSED + 1)); success "$1"; }
check_failed() { FAILED=$((FAILED + 1)); error "$1"; }
check_warning() { WARNINGS=$((WARNINGS + 1)); warn "$1"; }

# --- Helper Functions ---
command_exists() { command -v "$1" >/dev/null 2>&1; }

main() {
    header "🔍 Dotfiles Setup Validation"
    
    validate_stow_symlinks
    validate_shell_config
    validate_essential_tools
    validate_ssh_setup
    validate_git_config
    validate_permissions
    
    show_summary
}

validate_stow_symlinks() {
    header "Checking Stow Symlinks"
    
    # Key files that should be symlinked
    local files=(
        ".zshrc"
        ".bashrc"
        ".gitconfig"
        ".commonrc"
        ".vimrc"
    )
    
    for file in "${files[@]}"; do
        if [[ -L "$HOME/$file" ]]; then
            local target=$(readlink "$HOME/$file")
            if [[ "$target" =~ dotfiles/home ]]; then
                check_passed "$file is correctly symlinked to $target"
            else
                check_warning "$file is symlinked but not to dotfiles directory: $target"
            fi
        elif [[ -f "$HOME/$file" ]]; then
            check_failed "$file exists but is not a symlink (may conflict with stow)"
        else
            check_warning "$file does not exist"
        fi
    done
    
    # Check .config/git files
    if [[ -L "$HOME/.config/git/personal.gitconfig" ]]; then
        check_passed ".config/git/personal.gitconfig is correctly symlinked"
    else
        check_warning ".config/git/personal.gitconfig is not symlinked"
    fi
    
    if [[ -L "$HOME/.config/git/work.gitconfig" ]]; then
        check_passed ".config/git/work.gitconfig is correctly symlinked"
    else
        check_warning ".config/git/work.gitconfig is not symlinked"
    fi
}

validate_shell_config() {
    header "Testing Shell Configuration"
    
    # Test zsh loads without errors
    if command_exists zsh; then
        if zsh -c 'source ~/.zshrc' 2>/dev/null; then
            check_passed "Zsh configuration loads without errors"
        else
            check_failed "Zsh configuration has errors"
        fi
    else
        check_warning "Zsh is not installed"
    fi
    
    # Test bash loads without errors
    if command_exists bash; then
        if bash -c 'source ~/.bashrc' 2>/dev/null; then
            check_passed "Bash configuration loads without errors"
        else
            check_failed "Bash configuration has errors"
        fi
    fi
    
    # Test common config
    if [[ -f "$HOME/.commonrc" ]]; then
        if bash -c 'source ~/.commonrc' 2>/dev/null; then
            check_passed "Common configuration loads without errors"
        else
            check_failed "Common configuration has errors"
        fi
    else
        check_failed ".commonrc file is missing"
    fi
}

validate_essential_tools() {
    header "Checking Essential Tools"
    
    # Tools that should be installed
    local tools=(
        "git"
        "stow"
        "fzf"
        "bat"
        "delta"
    )
    
    for tool in "${tools[@]}"; do
        if command_exists "$tool"; then
            check_passed "$tool is installed and accessible"
        else
            check_failed "$tool is not installed or not in PATH"
        fi
    done
    
    # Check Oh My Zsh installation
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        check_passed "Oh My Zsh is installed"
    else
        check_warning "Oh My Zsh is not installed"
    fi
    
    # Check Homebrew (macOS)
    if [[ "$(uname)" == "Darwin" ]]; then
        if command_exists brew; then
            check_passed "Homebrew is installed and accessible"
        else
            check_failed "Homebrew is not installed or not in PATH"
        fi
    fi
}

validate_ssh_setup() {
    header "Checking SSH Configuration"
    
    # Check SSH config file
    if [[ -f "$HOME/.ssh/config" ]]; then
        check_passed "SSH config file exists"
        
        # Check permissions (follow symlinks)
        local perms=$(stat -L -c "%a" "$HOME/.ssh/config" 2>/dev/null || stat -L -f "%A" "$HOME/.ssh/config" 2>/dev/null || echo "unknown")
        if [[ "$perms" == "600" ]]; then
            check_passed "SSH config has correct permissions (600)"
        else
            check_warning "SSH config permissions are $perms (should be 600)"
        fi
    else
        check_warning "SSH config file does not exist"
    fi
    
    # Check for SSH keys
    local key_found=false
    for key_file in "$HOME"/.ssh/id_*; do
        if [[ -f "$key_file" && ! "$key_file" =~ \.pub$ ]]; then
            key_found=true
            local perms=$(stat -L -c "%a" "$key_file" 2>/dev/null || stat -L -f "%A" "$key_file" 2>/dev/null || echo "unknown")
            if [[ "$perms" == "600" ]]; then
                check_passed "SSH private key $(basename "$key_file") has correct permissions"
            else
                check_failed "SSH private key $(basename "$key_file") has incorrect permissions: $perms (should be 600)"
            fi
        fi
    done
    
    if ! $key_found; then
        check_warning "No SSH private keys found"
    fi
}

validate_git_config() {
    header "Checking Git Configuration"
    
    # Check git user configuration (effective config, not just global)
    local git_name=$(git config user.name 2>/dev/null || echo "")
    local git_email=$(git config user.email 2>/dev/null || echo "")
    
    if [[ -n "$git_name" ]]; then
        check_passed "Git user.name is configured: $git_name"
    else
        check_failed "Git user.name is not configured"
    fi
    
    if [[ -n "$git_email" ]]; then
        check_passed "Git user.email is configured: $git_email"
    else
        check_failed "Git user.email is not configured"
    fi
    
    # Check git pager configuration
    local git_pager=$(git config core.pager 2>/dev/null || echo "")
    if [[ "$git_pager" == "delta" ]]; then
        if command_exists delta; then
            check_passed "Git pager is set to delta and delta is available"
        else
            check_failed "Git pager is set to delta but delta is not installed"
        fi
    elif [[ -n "$git_pager" ]]; then
        check_warning "Git pager is set to: $git_pager"
    else
        check_warning "Git pager is not configured"
    fi
    
    # Check if SSH is configured for Git
    local github_url=$(git config url."git@github.com:".insteadof 2>/dev/null || echo "")
    if [[ "$github_url" == "https://github.com/" ]]; then
        check_passed "Git is configured to use SSH for GitHub"
    else
        check_warning "Git is not configured to force SSH for GitHub"
    fi
}

validate_permissions() {
    header "Checking File Permissions"
    
    # Check sensitive directories
    if [[ -d "$HOME/.ssh" ]]; then
        local ssh_perms=$(stat -L -c "%a" "$HOME/.ssh" 2>/dev/null || stat -L -f "%A" "$HOME/.ssh" 2>/dev/null || echo "unknown")
        if [[ "$ssh_perms" == "700" ]]; then
            check_passed ".ssh directory has correct permissions (700)"
        else
            check_warning ".ssh directory permissions are $ssh_perms (should be 700)"
        fi
    fi
    
    # Check for world-writable files in home directory
    local world_writable=$(find "$HOME" -maxdepth 2 -type f -perm -o+w 2>/dev/null | head -5)
    if [[ -n "$world_writable" ]]; then
        check_warning "Found world-writable files in home directory"
        echo "$world_writable" | while read -r file; do
            info "  $file"
        done
    else
        check_passed "No world-writable files found in home directory"
    fi
}

show_summary() {
    header "📊 Validation Summary"
    
    echo -e "${GREEN}✓ Passed: ${BOLD}$PASSED${NC}"
    echo -e "${RED}✗ Failed: ${BOLD}$FAILED${NC}"
    echo -e "${YELLOW}⚠ Warnings: ${BOLD}$WARNINGS${NC}"
    echo ""
    
    local total=$((PASSED + FAILED + WARNINGS))
    local success_rate=$(( PASSED * 100 / total ))
    
    if [[ $FAILED -eq 0 ]]; then
        if [[ $WARNINGS -eq 0 ]]; then
            echo -e "${GREEN}${BOLD}🎉 Perfect! All validations passed.${NC}"
            exit 0
        else
            echo -e "${YELLOW}${BOLD}✅ Good! All critical validations passed with minor warnings.${NC}"
            exit 0
        fi
    else
        echo -e "${RED}${BOLD}❌ Issues found! $FAILED critical problems need attention.${NC}"
        echo ""
        echo "Recommendations:"
        if [[ $FAILED -gt 0 ]]; then
            echo "• Fix the failed checks above before using the dotfiles"
            echo "• Consider re-running the setup script with --force flag"
        fi
        exit 1
    fi
}

# --- Execution ---
main "$@"