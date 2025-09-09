#!/usr/bin/env bash

# Text colors
TXT_RED='\e[31m'
TXT_GREEN='\e[32m'
TXT_YELLOW='\e[33m'
TXT_BLUE='\e[34m'
TXT_CLEAR='\e[0m'

# Simple log function
log() {
    echo -e "${TXT_CLEAR}" "$*" "${TXT_CLEAR}"
}

log_info() {
    echo -e "${TXT_BLUE}" "$*" "${TXT_CLEAR}"
}

log_error() {
    echo -e "${TXT_RED}" "$*" "${TXT_CLEAR}"
}

log_warning() {
    echo -e "${TXT_YELLOW}" "$*" "${TXT_CLEAR}"
}

log_success() {
    echo -e "${TXT_GREEN}" "$*" "${TXT_CLEAR}"
}

# Heredoc log function
log_heredoc() {
    # Logs a heredoc string with color formatting
    #
    # Arguments:
    #   $1  The color code to use (e.g. ${TXT_GREEN})
    #   stdin  The heredoc content to log
    #
    # Example:
    #   show_help() {
    #       log_heredoc "${TXT_GREEN}" <<EOF
    #       This is some
    #       multi-line text
    #       that will be green
    #       EOF
    #   }

    local level=$1
    while IFS= read -r line; do
        echo -e "${level}${line}${TXT_CLEAR}"
    done
}

get_repo_root() {
    echo $(git rev-parse --show-toplevel)
}
