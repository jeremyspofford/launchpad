#!/usr/bin/env bash

################################################################################
# Remove Docker Desktop Only
#
# This script ONLY removes Docker Desktop from your system.
# It does NOT install Docker Engine or any other Docker tools.
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Removing Docker Desktop"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# Check if Docker Desktop is installed
if ! dpkg -l 2>/dev/null | grep -q docker-desktop; then
    log_info "Docker Desktop is not installed"
    exit 0
fi

log_info "Found Docker Desktop installation"

# Remove Docker Desktop
log_info "Removing Docker Desktop package..."
sudo dpkg --remove --force-remove-reinstreq docker-desktop 2>&1 || {
    log_error "Failed to remove with dpkg, trying with apt..."
    sudo apt-get remove -y docker-desktop 2>&1
}

# Clean up dependencies
log_info "Cleaning up unused dependencies..."
sudo apt-get autoremove -y

# Remove desktop entry if it exists
if [ -f /usr/share/applications/docker-desktop.desktop ]; then
    sudo rm -f /usr/share/applications/docker-desktop.desktop
    log_info "Removed desktop entry"
fi

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database ~/.local/share/applications/ 2>/dev/null || true
    log_info "Updated desktop database"
fi

echo
log_info "✅ Docker Desktop removed successfully!"
log_info "The application should disappear from your applications menu"
echo
