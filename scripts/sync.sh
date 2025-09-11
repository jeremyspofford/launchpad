#!/usr/bin/env bash

# sync.sh - Simple script to apply dotfiles symlinks via GNU stow
# Based on the Ansible configuration from ansible/roles/common/tasks/main.yml

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Help function
show_help() {
    echo -e "${BLUE}sync.sh - Dotfiles synchronization script${NC}"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "OPTIONS:"
    echo "  -h, --help     Show this help message and exit"
    echo "  -v, --verbose  Run stow in verbose mode to see detailed output"
    echo "  -n, --dry-run  Perform a dry run (show what would be done without making changes)"
    echo "  -f, --force    Force restow (useful for fixing conflicts)"
    echo ""
    echo "DESCRIPTION:"
    echo "  This script uses GNU stow to create symlinks from the dotfiles"
    echo "  repository to your home directory. It symlinks everything in the"
    echo "  'home/' directory to '\$HOME'."
    echo ""
    echo "EXAMPLES:"
    echo "  $0             # Normal sync"
    echo "  $0 -v          # Verbose mode to see what's being linked"
    echo "  $0 -n          # Dry run to preview changes"
    echo "  $0 -f          # Force restow to fix conflicts"
    echo ""
    exit 0
}

# Parse command line arguments
STOW_FLAGS=""
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -v|--verbose)
            STOW_FLAGS="$STOW_FLAGS -v"
            shift
            ;;
        -n|--dry-run)
            STOW_FLAGS="$STOW_FLAGS -n"
            echo -e "${YELLOW}DRY RUN MODE - No changes will be made${NC}"
            shift
            ;;
        -f|--force)
            STOW_FLAGS="$STOW_FLAGS --restow"
            echo -e "${YELLOW}FORCE MODE - Restowing all symlinks${NC}"
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Get the dotfiles repository root (parent of scripts directory)
DOTFILES_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"

echo -e "${GREEN}Syncing dotfiles from:${NC} $DOTFILES_DIR"

# Check if stow is installed
if ! command -v stow &> /dev/null; then
    echo -e "${RED}Error: GNU stow is not installed!${NC}"
    echo "Please install stow first:"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "  brew install stow"
    else
        echo "  sudo apt-get install stow  # Debian/Ubuntu"
        echo "  sudo dnf install stow      # Fedora"
        echo "  sudo pacman -S stow        # Arch"
    fi
    exit 1
fi

# Change to the dotfiles directory
cd "$DOTFILES_DIR"

# Run stow to symlink the home directory contents to the user's home
# Using the same command structure as in the Ansible playbook
echo -e "${YELLOW}Running stow to create symlinks...${NC}"

# Temporarily disable set -e to handle stow errors gracefully
set +e
stow $STOW_FLAGS -t "$HOME" home
stow_exit_code=$?
set -e

# Check if stow succeeded
if [ $stow_exit_code -eq 0 ]; then
    echo -e "${GREEN}✓ Dotfiles synced successfully!${NC}"
else
    echo -e "${RED}✗ Failed to sync dotfiles${NC}"
    echo "You may need to resolve conflicts manually."
    echo "Try running: $0 -v"
    echo "to see verbose output and identify conflicts."
    exit 1
fi