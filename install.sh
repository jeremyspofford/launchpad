#!/usr/bin/env bash

set -euo pipefail

# ============================================================================ #
# Constants and Configuration
# ============================================================================ #

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="${SCRIPT_DIR}/install.log"
readonly BACKUP_PREFIX="backup_$(date +%Y%m%d_%H%M%S)"

files_to_backup=(
  .bash_aliases
  .bash_profile
  .bashrc
  .gitconfig
  .profile
  .zshrc
  .zshenv
  .zsh_aliases
  .zprofile
  .vimrc
)

# Installation components
declare -A COMPONENTS=(
  ["system_packages"]="Install system packages via Ansible"
  ["mise"]="Install mise version manager"
  ["starship"]="Install starship prompt"
  ["chezmoi"]="Setup chezmoi dotfile management"
  ["shell_switch"]="Switch to zsh shell"
)

# ============================================================================ #
# Utility Functions
# ============================================================================ #

log() { 
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1"
    echo -e "\033[1;34m$msg\033[0m" | tee -a "$LOG_FILE"
}

warn() { 
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [WARN] $1"
    echo -e "\033[1;33m$msg\033[0m" | tee -a "$LOG_FILE"
}

error() { 
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1"
    echo -e "\033[1;31m$msg\033[0m" | tee -a "$LOG_FILE"
}

success() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [SUCCESS] $1"
    echo -e "\033[1;32m$msg\033[0m" | tee -a "$LOG_FILE"
}

detect_os() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux) echo "linux" ;;
    *) echo "unknown" ;;
  esac
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Rollback function for cleanup on failure
rollback() {
    error "Installation failed. Performing rollback..."
    
    # Restore backed up files if they exist
    if [[ -d "$HOME/$BACKUP_PREFIX" ]]; then
        log "Restoring backed up files..."
        cd "$HOME"
        for file in "${files_to_backup[@]}"; do
            if [[ -f "$BACKUP_PREFIX/$file" ]]; then
                mv "$BACKUP_PREFIX/$file" "$file"
                log "Restored $file"
            fi
        done
    fi
    
    # Remove partial chezmoi installation
    if [[ -d ~/.local/share/chezmoi ]]; then
        warn "Removing partial chezmoi installation"
        rm -rf ~/.local/share/chezmoi
    fi
    
    error "Rollback completed. Check $LOG_FILE for details."
    exit 1
}

# Set up error handling
trap 'rollback' ERR

# Prompt user for component selection
select_components() {
    log "Select installation components:"
    echo
    
    declare -g -A selected_components
    
    # Default to all components enabled
    for component in "${!COMPONENTS[@]}"; do
        selected_components["$component"]=true
    done
    
    # Allow user to deselect components
    while true; do
        echo "Current selection:"
        for component in "${!COMPONENTS[@]}"; do
            local status="❌"
            [[ "${selected_components[$component]}" == "true" ]] && status="✅"
            echo "  $status $component: ${COMPONENTS[$component]}"
        done
        
        echo
        echo "Options:"
        echo "  a) Install all (default)"
        echo "  s) Skip a component"
        echo "  c) Continue with current selection"
        echo
        read -p "Choose option [a/s/c]: " choice
        
        case "$choice" in
            a|A|"")
                for component in "${!COMPONENTS[@]}"; do
                    selected_components["$component"]=true
                done
                break
                ;;
            s|S)
                echo "Available components to skip:"
                local i=1
                local component_list=()
                for component in "${!COMPONENTS[@]}"; do
                    if [[ "${selected_components[$component]}" == "true" ]]; then
                        echo "  $i) $component"
                        component_list+=("$component")
                        ((i++))
                    fi
                done
                echo
                read -p "Enter component number to skip: " skip_num
                if [[ "$skip_num" =~ ^[0-9]+$ ]] && [[ "$skip_num" -le "${#component_list[@]}" ]] && [[ "$skip_num" -gt 0 ]]; then
                    local skip_component="${component_list[$((skip_num-1))]}"
                    selected_components["$skip_component"]=false
                    log "Disabled: $skip_component"
                else
                    warn "Invalid selection"
                fi
                ;;
            c|C)
                break
                ;;
            *)
                warn "Invalid option"
                ;;
        esac
    done
}

# ============================================================================ #
# Package Management Functions
# ============================================================================ #

install_ansible_macos() {
  if ! command_exists brew; then
    error "❌ Homebrew not found. Please install it from https://brew.sh"
    exit 1
  fi

  if ! command_exists ansible; then
    log "Installing Ansible via Homebrew..."
    brew install ansible || {
        error "Failed to install Ansible via Homebrew"
        return 1
    }
  fi
  success "Ansible is available"
}

install_ansible_ubuntu() {
  if ! command_exists ansible; then
    log "Installing Ansible via apt..."
    sudo apt update && sudo apt upgrade -y || {
        error "Failed to update package lists"
        return 1
    }
    sudo apt install -y software-properties-common || {
        error "Failed to install software-properties-common"
        return 1
    }
    sudo apt-add-repository --yes --update ppa:ansible/ansible || {
        error "Failed to add Ansible PPA"
        return 1
    }
    sudo apt install -y ansible || {
        error "Failed to install Ansible"
        return 1
    }
  fi
  success "Ansible is available"
}

detect_os_and_install_ansible() {
  local os_type
  os_type=$(detect_os)
  
  case "$os_type" in
    macos)
      log "Detected macOS"
      install_ansible_macos
      ;;
    linux)
      log "Detected Linux"
      install_ansible_ubuntu
      ;;
    *)
      error "Unsupported OS: $(uname -s)"
      exit 1
      ;;
  esac
}

# ============================================================================ #
# Core Setup Functions
# ============================================================================ #

backup_dotfiles() {
  if [[ "$backup" = true ]]; then
    log "Attempting to backup $HOME dotfiles"
    cd "$HOME"

    local backup_folder="$BACKUP_PREFIX"

    for file in "${files_to_backup[@]}"; do
      if [ -f "$file" ] && [ ! -L "$file" ]; then
        mkdir -p "$backup_folder"
        log "Backing up $file"
        cp "$file" "$backup_folder/$file" || {
            error "Failed to backup $file"
            return 1
        }
      else
        warn "Skipping $file because it's a symlink or doesn't exist"
      fi
    done

    if [ -d "$backup_folder" ]; then
      success "Dotfiles backup complete in $backup_folder"
    else
      log "No files needed backup"
    fi
  fi
}

setup_chezmoi() {
  log "Setting up chezmoi dotfiles manager"
  cd "$SCRIPT_DIR"
  
  # Initialize chezmoi with current repository
  if ! command_exists chezmoi; then
    error "chezmoi not found. Run system package installation first."
    return 1
  fi
  
  # Create necessary directories
  mkdir -p ~/.local/share/zsh
  mkdir -p ~/.local/share/less
  mkdir -p ~/.cache
  
  # Initialize chezmoi with this repository
  if [[ ! -d ~/.local/share/chezmoi ]]; then
    log "Initializing chezmoi with dotfiles repository"
    chezmoi init --apply "$(pwd)" || {
        error "Failed to initialize chezmoi"
        return 1
    }
  else
    log "Updating existing chezmoi configuration"
    chezmoi apply || {
        error "Failed to apply chezmoi configuration"
        return 1
    }
  fi
  
  success "chezmoi setup complete"
}

run_ansible_and_continue() {
  if [[ "${selected_components[system_packages]}" != "true" ]]; then
    log "Skipping system package installation"
    return 0
  fi

  if command_exists ansible; then
    log "Running Ansible playbook..."
    if ansible-playbook -i "$SCRIPT_DIR/ansible/inventory.ini" "$SCRIPT_DIR/ansible/playbook.yml" --ask-become-pass; then
      success "Ansible playbook completed successfully"
    else
      error "Ansible playbook encountered issues"
      return 1
    fi
  else
    warn "Ansible not found, skipping playbook execution"
  fi
}

install_mise() {
  if [[ "${selected_components[mise]}" != "true" ]]; then
    log "Skipping mise installation"
    return 0
  fi

  if ! command_exists mise; then
    log "Installing mise..."
    curl -fsSL https://mise.run | sh || {
        error "Failed to install mise"
        return 1
    }
  else
    log "✓ mise already installed"
  fi
  success "mise installation complete"
}

install_starship() {
  if [[ "${selected_components[starship]}" != "true" ]]; then
    log "Skipping starship installation"
    return 0
  fi

  if ! command_exists starship; then
    log "Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- --yes || {
        error "Failed to install starship"
        return 1
    }
  else
    log "✓ starship already installed"
  fi
  success "starship installation complete"
}

finalize() {
  log "Finalizing setup..."
  
  local os_type
  os_type=$(detect_os)
  
  # Only run apt commands on Linux
  if [[ "$os_type" == "linux" ]] && command_exists apt; then
    sudo apt autoremove -y || warn "Failed to autoremove packages"
  fi

  # Prompt user about backup folder
  if ls "$HOME"/${BACKUP_PREFIX} 1> /dev/null 2>&1; then
    echo -n "Backup folder found. Would you like to remove it? [y/N]: "
    read -r remove_backup
    if [[ "$remove_backup" =~ ^[Yy]$ ]]; then
      rm -rf "$HOME"/${BACKUP_PREFIX}
      log "Backup folder removed"
    fi
  fi
  
  # Switch to zsh if available and selected
  if [[ "${selected_components[shell_switch]}" == "true" ]] && command_exists zsh; then
    log "Switching to zsh shell"
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        chsh -s "$(which zsh)" || warn "Failed to change shell to zsh"
    fi
    success "Shell configuration complete"
  else
    log "Staying in current shell"
  fi
}

# ============================================================================ #
# Main Script Logic
# ============================================================================ #

check_dependencies() {
  local missing_deps=()
  
  if ! command_exists git; then
    missing_deps+=("git")
  fi
  
  if ! command_exists curl; then
    missing_deps+=("curl")
  fi
  
  if [[ ${#missing_deps[@]} -gt 0 ]]; then
    error "Missing required dependencies: ${missing_deps[*]}"
    error "Please install them first, or run the system package installation to install dependencies automatically"
    exit 1
  fi
  success "All dependencies are available"
}

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Install and configure a comprehensive dotfiles environment using chezmoi.

OPTIONS:
    -h, --help          Show this help message
    -n, --no-backup     Skip backup of existing dotfiles
    -q, --quiet         Suppress non-essential output
    -y, --yes           Answer yes to all prompts (non-interactive mode)
    --minimal           Install only essential components
    --no-ansible        Skip system package installation
    --log-file FILE     Use custom log file location

EXAMPLES:
    $0                  # Interactive installation with all components
    $0 --no-backup      # Skip backing up existing dotfiles
    $0 --minimal        # Install only essential components
    $0 -y --no-ansible  # Non-interactive, skip system packages

For more information, see: docs/installation.md
EOF
}

main() {
  log "🚀 Starting dotfiles installation with chezmoi..."
  
  # Initialize log file
  : > "$LOG_FILE"
  
  # Ensure ~/.local/bin is in PATH for this session (tools get installed there)
  export PATH="$HOME/.local/bin:$PATH"
  
  # Parse command line options
  local backup=true
  local quiet=false
  local yes_to_all=false
  local minimal=false
  local skip_ansible=false
  
  while [[ $# -gt 0 ]]; do
    case $1 in
      -h|--help)
        show_usage
        exit 0
        ;;
      -n|--no-backup)
        backup=false
        shift
        ;;
      -q|--quiet)
        quiet=true
        shift
        ;;
      -y|--yes)
        yes_to_all=true
        shift
        ;;
      --minimal)
        minimal=true
        shift
        ;;
      --no-ansible)
        skip_ansible=true
        shift
        ;;
      --log-file)
        LOG_FILE="$2"
        shift 2
        ;;
      *)
        error "Unknown option: $1"
        show_usage
        exit 1
        ;;
    esac
  done

  # Clean up any existing backup folders before starting
  rm -rf "$HOME"/backup_* || true

  # Execute setup steps
  check_dependencies
  
  # Set up component selection
  if [[ "$minimal" == "true" ]]; then
    selected_components["system_packages"]=false
    selected_components["mise"]=false
    selected_components["starship"]=false
    selected_components["chezmoi"]=true
    selected_components["shell_switch"]=false
  elif [[ "$skip_ansible" == "true" ]]; then
    selected_components["system_packages"]=false
  fi
  
  # Interactive component selection unless in yes-to-all mode
  if [[ "$yes_to_all" != "true" ]]; then
    select_components
  fi
  
  # Execute installation steps
  backup_dotfiles
  
  if [[ "${selected_components[system_packages]}" == "true" ]]; then
    detect_os_and_install_ansible
    run_ansible_and_continue
  fi
  
  if [[ "${selected_components[mise]}" == "true" ]]; then
    install_mise
  fi
  
  if [[ "${selected_components[starship]}" == "true" ]]; then
    install_starship
  fi
  
  if [[ "${selected_components[chezmoi]}" == "true" ]]; then
    setup_chezmoi
  fi
  
  finalize

  success "✅ Full bootstrap complete with chezmoi!"
  log "📝 Installation log saved to: $LOG_FILE"
  log "🔧 Use 'chezmoi apply' to apply future changes"
  log "📝 Use 'chezmoi edit <file>' to edit dotfiles"
  log "🔄 Use 'chezmoi update' to pull and apply remote changes"
  
  if [[ "${selected_components[shell_switch]}" == "true" ]] && command_exists zsh; then
    log "🐚 Restart your terminal or run 'exec zsh' to use the new shell"
  fi
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi