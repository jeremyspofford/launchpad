#!/usr/bin/env bash

set -euo pipefail

# ============================================================================ #
# Post-Installation Verification Script
# ============================================================================ #

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly VERIFICATION_LOG="${SCRIPT_DIR}/verification.log"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Test results
declare -a PASSED_TESTS=()
declare -a FAILED_TESTS=()
declare -a WARNING_TESTS=()

# ============================================================================ #
# Utility Functions
# ============================================================================ #

log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo -e "${BLUE}$msg${NC}" | tee -a "$VERIFICATION_LOG"
}

success() {
    local msg="✅ $1"
    echo -e "${GREEN}$msg${NC}" | tee -a "$VERIFICATION_LOG"
    PASSED_TESTS+=("$1")
}

fail() {
    local msg="❌ $1"
    echo -e "${RED}$msg${NC}" | tee -a "$VERIFICATION_LOG"
    FAILED_TESTS+=("$1")
}

warn() {
    local msg="⚠️  $1"
    echo -e "${YELLOW}$msg${NC}" | tee -a "$VERIFICATION_LOG"
    WARNING_TESTS+=("$1")
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

version_check() {
    local tool="$1"
    local expected_pattern="$2"
    
    if command_exists "$tool"; then
        local version
        version=$($tool --version 2>/dev/null | head -n1 || echo "unknown")
        if [[ "$version" =~ $expected_pattern ]]; then
            success "$tool is installed (version: $version)"
        else
            warn "$tool is installed but version pattern doesn't match (got: $version)"
        fi
    else
        fail "$tool is not installed or not in PATH"
    fi
}

file_check() {
    local file="$1"
    local description="$2"
    
    if [[ -f "$file" ]]; then
        success "$description exists at $file"
    else
        fail "$description missing at $file"
    fi
}

directory_check() {
    local dir="$1"
    local description="$2"
    
    if [[ -d "$dir" ]]; then
        success "$description exists at $dir"
    else
        fail "$description missing at $dir"
    fi
}

symlink_check() {
    local link="$1"
    local description="$2"
    
    if [[ -L "$link" ]]; then
        local target
        target=$(readlink "$link")
        success "$description is properly symlinked to $target"
    else
        fail "$description is not a symlink"
    fi
}

# ============================================================================ #
# Verification Tests
# ============================================================================ #

test_system_tools() {
    log "Testing system tools..."
    
    # Core system tools
    version_check "git" "git version"
    version_check "curl" "curl [0-9]"
    version_check "zsh" "zsh [0-9]"
    
    # Modern CLI tools
    version_check "fzf" "[0-9]"
    version_check "rg" "ripgrep [0-9]"
    version_check "fd" "fd [0-9]"
    version_check "bat" "bat [0-9]"
    version_check "exa" "exa v[0-9]"
    version_check "zoxide" "zoxide [0-9]"
    
    # Development tools
    version_check "tmux" "tmux [0-9]"
    version_check "jq" "jq-[0-9]"
}

test_version_managers() {
    log "Testing version managers..."
    
    version_check "mise" "mise [0-9]"
    version_check "starship" "starship [0-9]"
    
    # Test mise functionality
    if command_exists mise; then
        if mise list >/dev/null 2>&1; then
            success "mise list command works"
        else
            warn "mise is installed but list command failed"
        fi
    fi
}

test_chezmoi() {
    log "Testing chezmoi setup..."
    
    version_check "chezmoi" "chezmoi version [0-9]"
    
    # Check chezmoi directories
    directory_check "$HOME/.local/share/chezmoi" "chezmoi source directory"
    file_check "$HOME/.local/share/chezmoi/.chezmoi.toml.tmpl" "chezmoi config template"
    
    # Test chezmoi commands
    if command_exists chezmoi; then
        if chezmoi status >/dev/null 2>&1; then
            success "chezmoi status command works"
        else
            warn "chezmoi is installed but status command failed"
        fi
        
        if chezmoi diff --no-pager >/dev/null 2>&1; then
            success "chezmoi diff command works"
        else
            warn "chezmoi diff command failed"
        fi
    fi
}

test_shell_configuration() {
    log "Testing shell configuration..."
    
    # Check current shell
    if [[ "$SHELL" =~ zsh$ ]]; then
        success "Default shell is zsh"
    else
        warn "Default shell is not zsh (current: $SHELL)"
    fi
    
    # Check shell configuration files
    file_check "$HOME/.zshrc" "zsh configuration"
    file_check "$HOME/.config/zsh/aliases.zsh" "zsh aliases"
    file_check "$HOME/.config/zsh/env.zsh" "zsh environment"
    
    # Check if starship is configured
    if grep -q "starship init" "$HOME/.zshrc" 2>/dev/null; then
        success "starship prompt is configured in zsh"
    else
        warn "starship prompt not found in zsh configuration"
    fi
}

test_git_configuration() {
    log "Testing git configuration..."
    
    file_check "$HOME/.gitconfig" "git configuration"
    
    # Check git user configuration
    local git_user_name git_user_email
    git_user_name=$(git config --global user.name 2>/dev/null || echo "")
    git_user_email=$(git config --global user.email 2>/dev/null || echo "")
    
    if [[ -n "$git_user_name" ]]; then
        success "git user.name is configured: $git_user_name"
    else
        fail "git user.name is not configured"
    fi
    
    if [[ -n "$git_user_email" ]]; then
        success "git user.email is configured: $git_user_email"
    else
        fail "git user.email is not configured"
    fi
}

test_ssh_configuration() {
    log "Testing SSH configuration..."
    
    # Check SSH key files
    file_check "$HOME/.ssh/personal_id_ed25519" "SSH private key"
    file_check "$HOME/.ssh/personal_id_ed25519.pub" "SSH public key"
    
    # Check SSH key permissions
    if [[ -f "$HOME/.ssh/personal_id_ed25519" ]]; then
        local perms
        perms=$(stat -c %a "$HOME/.ssh/personal_id_ed25519" 2>/dev/null || stat -f %A "$HOME/.ssh/personal_id_ed25519" 2>/dev/null)
        if [[ "$perms" == "600" ]]; then
            success "SSH private key has correct permissions (600)"
        else
            warn "SSH private key has incorrect permissions ($perms, should be 600)"
        fi
    fi
    
    # Test SSH connection to GitHub
    if ssh -T git@github.com -o ConnectTimeout=5 -o BatchMode=yes 2>&1 | grep -q "successfully authenticated"; then
        success "SSH connection to GitHub works"
    else
        warn "SSH connection to GitHub failed (key may not be added to GitHub)"
    fi
}

test_development_tools() {
    log "Testing development tools..."
    
    # Check if fabric is available
    if command_exists fabric; then
        success "fabric AI tool is installed"
        
        # Test fabric patterns
        if fabric --list >/dev/null 2>&1; then
            local pattern_count
            pattern_count=$(fabric --list 2>/dev/null | wc -l)
            success "fabric has $pattern_count patterns available"
        else
            warn "fabric is installed but pattern list failed"
        fi
    else
        warn "fabric AI tool is not installed"
    fi
    
    # Check VS Code configuration
    file_check "$HOME/.config/Code/User/settings.json" "VS Code settings"
    file_check "$HOME/.config/Code/User/keybindings.json" "VS Code keybindings"
}

test_environment_variables() {
    log "Testing environment variables..."
    
    # Check important environment variables
    if [[ -n "${EDITOR:-}" ]]; then
        success "EDITOR is set to: $EDITOR"
    else
        warn "EDITOR environment variable is not set"
    fi
    
    if [[ -n "${FZF_DEFAULT_COMMAND:-}" ]]; then
        success "FZF_DEFAULT_COMMAND is configured"
    else
        warn "FZF_DEFAULT_COMMAND is not set"
    fi
    
    if [[ "$PATH" =~ \.local/bin ]]; then
        success "~/.local/bin is in PATH"
    else
        warn "~/.local/bin is not in PATH"
    fi
}

test_shell_aliases() {
    log "Testing shell aliases..."
    
    # Source the aliases to test them
    if [[ -f "$HOME/.config/zsh/aliases.zsh" ]]; then
        # shellcheck source=/dev/null
        source "$HOME/.config/zsh/aliases.zsh" 2>/dev/null || true
        
        # Test some important aliases
        if alias ll >/dev/null 2>&1; then
            success "ll alias is defined"
        else
            warn "ll alias is not defined"
        fi
        
        if alias cm >/dev/null 2>&1; then
            success "cm (chezmoi) alias is defined"
        else
            warn "cm (chezmoi) alias is not defined"
        fi
        
        if alias fab >/dev/null 2>&1; then
            success "fab (fabric) alias is defined"
        else
            warn "fab (fabric) alias is not defined"
        fi
    else
        fail "aliases.zsh file not found"
    fi
}

test_file_permissions() {
    log "Testing file permissions..."
    
    # Check script permissions
    if [[ -x "$SCRIPT_DIR/install.sh" ]]; then
        success "install.sh is executable"
    else
        warn "install.sh is not executable"
    fi
    
    if [[ -x "$SCRIPT_DIR/verify.sh" ]]; then
        success "verify.sh is executable"
    else
        warn "verify.sh is not executable"
    fi
}

# ============================================================================ #
# Main Verification Logic
# ============================================================================ #

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Verify the dotfiles installation and configuration.

OPTIONS:
    -h, --help          Show this help message
    -v, --verbose       Show verbose output
    --quick             Run only essential tests
    --log-file FILE     Use custom log file location

EXAMPLES:
    $0                  # Run all verification tests
    $0 --quick          # Run only essential tests
    $0 --verbose        # Show detailed output

EOF
}

run_verification() {
    local quick_mode="$1"
    
    log "🔍 Starting dotfiles verification..."
    log "Verification log: $VERIFICATION_LOG"
    echo
    
    # Essential tests (always run)
    test_system_tools
    test_chezmoi
    test_shell_configuration
    test_git_configuration
    
    # Extended tests (skip in quick mode)
    if [[ "$quick_mode" != "true" ]]; then
        test_version_managers
        test_ssh_configuration
        test_development_tools
        test_environment_variables
        test_shell_aliases
        test_file_permissions
    fi
}

show_summary() {
    echo
    log "📊 Verification Summary"
    echo "=========================="
    echo -e "${GREEN}✅ Passed: ${#PASSED_TESTS[@]}${NC}"
    echo -e "${YELLOW}⚠️  Warnings: ${#WARNING_TESTS[@]}${NC}"
    echo -e "${RED}❌ Failed: ${#FAILED_TESTS[@]}${NC}"
    echo
    
    if [[ ${#FAILED_TESTS[@]} -gt 0 ]]; then
        echo -e "${RED}Failed tests:${NC}"
        for test in "${FAILED_TESTS[@]}"; do
            echo "  - $test"
        done
        echo
    fi
    
    if [[ ${#WARNING_TESTS[@]} -gt 0 ]]; then
        echo -e "${YELLOW}Warnings:${NC}"
        for test in "${WARNING_TESTS[@]}"; do
            echo "  - $test"
        done
        echo
    fi
    
    # Overall result
    if [[ ${#FAILED_TESTS[@]} -eq 0 ]]; then
        if [[ ${#WARNING_TESTS[@]} -eq 0 ]]; then
            echo -e "${GREEN}🎉 All tests passed! Your dotfiles setup is working perfectly.${NC}"
        else
            echo -e "${YELLOW}⚠️  Setup is mostly working, but there are some warnings to address.${NC}"
        fi
        return 0
    else
        echo -e "${RED}❌ Some tests failed. Please check the issues above and run the verification again.${NC}"
        return 1
    fi
}

main() {
    # Initialize log file
    : > "$VERIFICATION_LOG"
    
    local quick_mode=false
    local verbose=false
    
    # Parse command line options
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            --quick)
                quick_mode=true
                shift
                ;;
            --log-file)
                VERIFICATION_LOG="$2"
                shift 2
                ;;
            *)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Run verification
    run_verification "$quick_mode"
    
    # Show summary
    show_summary
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi