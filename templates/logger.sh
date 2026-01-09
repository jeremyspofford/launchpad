#!/bin/bash
# Common logger for deployment scripts
# Source this file in your deployment scripts

# Color codes (using \033 for better macOS/zsh compatibility)
export RED='\033[31m'
export GREEN='\033[32m'
export YELLOW='\033[33m'
export BLUE='\033[34m'
export MAGENTA='\033[35m'
export CYAN='\033[36m'
export BOLD='\033[1m'
export CLEAR='\033[0m'

get_repo_dir() {
    echo "$(git rev-parse --show-toplevel)"
}

# Logging functions
log_info() {
    echo -e "${BLUE}$*${CLEAR}"
}

log_success() {
    echo -e "${GREEN}$*${CLEAR}"
}

log_warning() {
    echo -e "${YELLOW}$*${CLEAR}"
}

log_error() {
    echo -e "${RED}$*${CLEAR}"
}

log_section() {
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${CLEAR}"
    echo -e "${CYAN}${BOLD}  $*${CLEAR}"
    echo -e "${CYAN}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${CLEAR}"
}

log_kv() {
    # Logs a key-value pair with color formatting
    #
    # Arguments:
    #   $1  The key
    #   $2  The value
    #
    # Example:
    #   log_kv "Key" "Value"
    #
    # Output:
    #   (blue) Key:    (reset) Value
    local key="$1"
    local value="$2"
    printf "${BLUE}%-30s${CLEAR} %s\n" "${key}:" "${value}"
}

log_heredoc() {
    # Logs a heredoc string with color formatting
    #
    # Arguments:
    #   $1  The color code to use (e.g. ${GREEN})
    #   stdin  The heredoc content to log
    #
    # Example:
    #   show_help() {
    #       log_heredoc "${GREEN}" <<EOF
    #       This is some
    #       multi-line text
    #       that will be green
    #       EOF
    #   }
    local level=$1
    while IFS= read -r line; do
      echo -e "${level}${line}${CLEAR}"
    done
}

# Error handling
error_exit() {
    log_error "$1"
    exit "${2:-1}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Set verbose
set_verbose() {
    set -x # Show commands (debugging)
}

# Set Quiet
set_quiet() {
    set +x # Hide commands (clean output)
}

# Set strict error handling
set_strict() {
    set -euo pipefail # Exit on: error | undefined var | pipe failure
}

# Validate required commands
require_commands() {
    local missing=()
    for cmd in "$@"; do
        if ! command_exists "$cmd"; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        error_exit "Missing required commands: ${missing[*]}"
    fi
}

