#!/bin/bash

# Ansible setup script for dotfiles
# This script installs required Ansible collections and roles

set -euo pipefail

echo "🔧 Setting up Ansible environment for dotfiles..."

# Check if ansible is installed
if ! command -v ansible &> /dev/null; then
    echo "❌ Ansible is not installed. Please install it first:"
    echo "   macOS: brew install ansible"
    echo "   Ubuntu/Debian: sudo apt install ansible"
    echo "   CentOS/RHEL: sudo yum install ansible"
    exit 1
fi

echo "✅ Ansible found: $(ansible --version | head -n1)"

# Install collections from requirements.yml
if [ -f "requirements.yml" ]; then
    echo "📦 Installing Ansible collections from requirements.yml..."
    ansible-galaxy collection install -r requirements.yml
    echo "✅ Collections installed successfully"
else
    echo "⚠️  No requirements.yml found, skipping collection installation"
fi

# Install any role dependencies
if [ -d "roles" ]; then
    echo "🎭 Installing role dependencies..."
    ansible-galaxy install -r roles/requirements.yml 2>/dev/null || echo "ℹ️  No role requirements found"
fi

echo "🧪 Testing playbook syntax..."
for playbook in *.yml; do
    if [ -f "$playbook" ]; then
        echo "  Testing $playbook..."
        ansible-playbook --syntax-check "$playbook" >/dev/null 2>&1 || {
            echo "❌ Syntax error in $playbook"
            exit 1
        }
    fi
done

echo "✅ All playbooks passed syntax check"
echo ""
echo "🎉 Ansible setup complete! You can now run:"
echo "   ansible-playbook install_gcloud.yml    # Install Google Cloud CLI"
echo "   ansible-playbook uninstall_gcloud.yml  # Uninstall Google Cloud CLI"
echo "   ansible-playbook playbook.yml          # Bootstrap system packages"
