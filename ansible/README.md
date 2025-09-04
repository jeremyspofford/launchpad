# Ansible Configuration for Dotfiles

This directory contains Ansible playbooks and roles for managing system packages and tools across different operating systems.

## Quick Start

1. **Install Ansible** (if not already installed):
   ```bash
   # macOS
   brew install ansible
   
   # Ubuntu/Debian
   sudo apt install ansible
   
   # CentOS/RHEL
   sudo yum install ansible
   ```

2. **Run the setup script** to install required collections:
   ```bash
   ./setup.sh
   ```

3. **Run playbooks**:
   ```bash
   # Install Google Cloud CLI
   ansible-playbook install_gcloud.yml
   
   # Uninstall Google Cloud CLI
   ansible-playbook uninstall_gcloud.yml
   
   # Bootstrap system packages (zsh, tmux, neovim, etc.)
   ansible-playbook playbook.yml
   ```

## Automatic Collection Installation

### Method 1: Using the setup script (Recommended)
```bash
./setup.sh
```

### Method 2: Manual installation
```bash
ansible-galaxy collection install -r requirements.yml
```

### Method 3: In your CI/CD pipeline
```yaml
- name: Install Ansible collections
  command: ansible-galaxy collection install -r requirements.yml
```

### Method 4: Using ansible.cfg
Create an `ansible.cfg` file in the ansible directory:
```ini
[defaults]
collections_paths = ~/.ansible/collections:/usr/share/ansible/collections
collections_scan_sys_path = False

[galaxy]
collections_paths = ~/.ansible/collections:/usr/share/ansible/collections
```

## Playbooks

### `playbook.yml`
Main bootstrap playbook that installs essential packages:
- Shell and terminal tools (zsh, tmux, neovim)
- Modern CLI tools (fzf, ripgrep, bat, eza, etc.)
- Development tools (node, npm, gh)
- Code quality tools (shellcheck, yamllint)
- Cloud CLI tools (aws, azure, gcloud)

### `install_gcloud.yml`
Installs Google Cloud CLI on:
- macOS (via Homebrew)
- Debian/Ubuntu (via APT)
- RedHat/CentOS (via YUM/DNF)

### `uninstall_gcloud.yml`
Removes Google Cloud CLI from all supported systems.

## Roles

### `bootstrap`
Comprehensive system package installation role supporting:
- **macOS**: Uses Homebrew for package management
- **Debian/Ubuntu**: Uses APT with custom installations for tools not in repos
- **RedHat/CentOS**: Uses YUM/DNF (basic support)

### `gcloud_install`
Cross-platform Google Cloud CLI installation.

### `gcloud_uninstall`
Cross-platform Google Cloud CLI removal.

## Requirements

- Ansible 2.9+
- `community.general` collection (automatically installed via requirements.yml)

## Supported Operating Systems

- **macOS**: Full support via Homebrew
- **Debian/Ubuntu**: Full support via APT + custom installations
- **RedHat/CentOS**: Basic support via YUM/DNF

## Troubleshooting

### Collection not found errors
```bash
ansible-galaxy collection install community.general
```

### Permission errors on macOS
The playbooks use `become: false` for Homebrew operations since Homebrew typically runs as the user.

### Syntax check failures
```bash
ansible-playbook --syntax-check <playbook.yml>
```

## Development

To add new packages or tools:

1. **For system packages**: Edit `roles/bootstrap/tasks/main.yml`
2. **For new roles**: Use `ansible-galaxy init <role_name>`
3. **For new playbooks**: Follow the existing pattern with proper hosts configuration

## File Structure

```
ansible/
├── README.md                 # This file
├── setup.sh                 # Setup script for collections
├── requirements.yml         # Ansible collection requirements
├── inventory.ini           # Inventory file (localhost)
├── playbook.yml           # Main bootstrap playbook
├── install_gcloud.yml     # Google Cloud CLI installation
├── uninstall_gcloud.yml   # Google Cloud CLI removal
└── roles/
    ├── bootstrap/         # System package installation
    ├── gcloud_install/    # Google Cloud CLI installation
    └── gcloud_uninstall/  # Google Cloud CLI removal
```
