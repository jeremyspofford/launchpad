#!/usr/bin/env bash

################################################################################
# Uninstall Docker Engine
#
# This script removes Docker Engine packages installed by remove-docker-desktop.sh
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

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Uninstalling Docker Engine"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# Stop Docker service
if systemctl is-active --quiet docker; then
    log_info "Stopping Docker service..."
    sudo systemctl stop docker
    sudo systemctl disable docker
fi

# Remove Docker packages
log_info "Removing Docker Engine packages..."
sudo apt-get remove -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin 2>&1 || log_warning "Some packages may not have been installed"

# Clean up unused dependencies
log_info "Cleaning up unused dependencies..."
sudo apt-get autoremove -y

# Remove Docker repository (optional)
if [ -f /etc/apt/sources.list.d/docker.list ]; then
    log_warning "Docker repository still exists at /etc/apt/sources.list.d/docker.list"
    log_info "Remove it with: sudo rm /etc/apt/sources.list.d/docker.list"
fi

# Remove user from docker group
log_info "Removing user from docker group..."
sudo deluser $USER docker 2>/dev/null || log_warning "User was not in docker group"

echo
log_info "✅ Docker Engine uninstalled successfully!"
log_info "You may need to log out and back in for group changes to take effect"
echo
