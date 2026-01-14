#!/usr/bin/env bash

################################################################################
# Fix Docker Desktop Installation
#
# This script fixes broken Docker Desktop installations by:
# 1. Removing the broken package
# 2. Installing required dependencies
# 3. Reinstalling Docker Desktop properly
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

log_info "Fixing Docker Desktop installation..."
echo

# Check if Docker Desktop is in broken state
if dpkg -l 2>/dev/null | grep -i docker-desktop | grep -qE "^[^ ]*(iU|iF)"; then
    log_warning "Found broken Docker Desktop installation"
    log_info "Removing broken package..."
    sudo dpkg --remove --force-remove-reinstreq docker-desktop
    log_info "Cleaning up..."
    sudo apt-get autoremove -y
else
    log_info "No broken Docker Desktop installation found"
fi

# Add Docker's official GPG key and repository
log_info "Setting up Docker repository..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    log_info "Docker GPG key added"
fi

# Add Docker repository
if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    log_info "Docker repository added"
fi

# Install required dependencies
log_info "Installing Docker Desktop dependencies..."
sudo apt-get install -y \
    qemu-system-x86 \
    pass \
    uidmap \
    docker-ce-cli \
    docker-buildx-plugin \
    docker-compose-plugin

log_info "Dependencies installed successfully"
echo

# Download and install Docker Desktop
log_info "Downloading Docker Desktop..."
TEMP_DEB="/tmp/docker-desktop.deb"
curl -L "https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb" -o "$TEMP_DEB"

log_info "Installing Docker Desktop..."
sudo dpkg -i "$TEMP_DEB"
sudo apt-get install -f -y

rm -f "$TEMP_DEB"

echo
log_info "✅ Docker Desktop installation fixed!"
log_warning "You may need to log out and back in for Docker Desktop to work properly"
echo
