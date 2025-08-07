#!/usr/bin/env bash

set -euo pipefail

# Simple verification script for CI/CD testing
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

check_command() {
    local cmd="$1"
    local description="${2:-$cmd}"
    
    if command -v "$cmd" >/dev/null 2>&1; then
        log_info "$description is installed"
        return 0
    else
        log_warning "$description is not installed"
        return 1
    fi
}

main() {
    local quick_mode=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --quick)
                quick_mode=true
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    log_info "Starting verification (quick_mode: $quick_mode)"
    
    # Check essential tools
    local failed=0
    
    check_command "git" "Git" || ((failed++))
    check_command "curl" "cURL" || ((failed++))
    check_command "chezmoi" "chezmoi" || ((failed++))
    
    if [[ "$quick_mode" == "false" ]]; then
        check_command "mise" "mise" || ((failed++))
        check_command "starship" "starship" || ((failed++))
        check_command "fzf" "fzf" || ((failed++))
        check_command "rg" "ripgrep" || ((failed++))
        check_command "bat" "bat" || ((failed++))
        check_command "eza" "eza" || ((failed++))
    fi
    
    if [[ $failed -eq 0 ]]; then
        log_info "All verifications passed!"
        exit 0
    else
        log_error "$failed verification(s) failed"
        exit 1
    fi
}

main "$@"