#!/usr/bin/env bash

################################################################################
# Remove Docker Desktop and Install Docker Engine
#
# This script removes Docker Desktop and installs Docker Engine instead.
# Docker Engine is lighter, native to Linux, and the standard approach.
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
echo "  Removing Docker Desktop & Installing Docker Engine"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# Remove Docker Desktop
if dpkg -l 2>/dev/null | grep -q docker-desktop; then
    log_info "Removing Docker Desktop..."
    sudo dpkg --remove --force-remove-reinstreq docker-desktop 2>/dev/null || true
    sudo apt-get autoremove -y
    log_info "✅ Docker Desktop removed"
else
    log_info "Docker Desktop not installed, skipping removal"
fi

# Check if Docker Engine already installed
if command -v docker &> /dev/null && ! dpkg -l 2>/dev/null | grep -q docker-desktop; then
    log_info "✅ Docker Engine already installed"
    docker --version
    exit 0
fi

# Add Docker's official GPG key and repository
log_info "Setting up Docker Engine repository..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
fi

# Add Docker repository
if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
fi

# Install Docker Engine
log_info "Installing Docker Engine..."
sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# Add user to docker group
log_info "Adding current user to docker group..."
sudo usermod -aG docker $USER

# Enable and start Docker service
log_info "Enabling Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

echo
log_info "✅ Docker Engine installed successfully!"
echo
docker --version
docker compose version
echo
log_warning "IMPORTANT: Log out and back in for group membership to take effect"
log_info "After logging back in, test with: docker run hello-world"
echo
