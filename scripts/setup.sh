#!/usr/bin/env bash

################################################################################
# Dotfiles Setup Script
# 
# This script sets up dotfiles using GNU Stow for symlink management.
# It can be run safely multiple times on the same machine.
#
# Usage:
#   ./scripts/setup.sh           # Full setup
#   ./scripts/setup.sh --update  # Re-stow dotfiles only
#   ./scripts/setup.sh --revert  # Restore backups and remove symlinks
#   ./scripts/setup.sh --minimal # Dotfiles only, skip package installation
#
################################################################################

set -e

# Configuration
# Detect dotfiles directory from script location (works from any location)
if [ -d "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/.git" ]; then
    # Running from within the repo
    DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
else
    # Default fallback location
    DOTFILES_DIR="$HOME/workspace/dotfiles"
fi

BACKUP_BASE_DIR="$HOME/.dotfiles-backup"
BACKUP_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_BASE_DIR/$BACKUP_TIMESTAMP"
MANIFEST_FILE="$BACKUP_DIR/manifest.txt"

# Installation tracking
declare -a COMPLETED_STEPS=()
declare -a FAILED_STEPS=()
declare -a SKIPPED_STEPS=()

# Flags
MINIMAL_INSTALL=false
UPDATE_ONLY=false
REVERT=false
LIST_BACKUPS=false
SKIP_INTERACTIVE=false
CREATE_RESTORE_POINT=false
SKIP_RESTORE_PROMPT=false

# Tool installation flags (defaults)
INSTALL_SHELL_TOOLS=true
INSTALL_TERMINAL_TOOLS=true
INSTALL_EDITOR=true
INSTALL_CLI_TOOLS=true
INSTALL_MISE=true
INSTALL_OLLAMA=false
INSTALL_CLAUDE_CODE=false
INSTALL_OBSIDIAN=false

# Preferences file (XDG compliant)
PREFERENCES_DIR="$HOME/.config/dotfiles"
PREFERENCES_FILE="$PREFERENCES_DIR/preferences"

# System restore configuration
RESTORE_DIR="$HOME/.system-snapshots"
PACKAGE_MANIFEST="$RESTORE_DIR/packages-$BACKUP_TIMESTAMP.txt"

################################################################################
# Load logger functions
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/logger.sh"

################################################################################
# Installation Tracking
################################################################################

track_completed() {
    COMPLETED_STEPS+=("$1")
}

track_failed() {
    FAILED_STEPS+=("$1: $2")
}

track_skipped() {
    SKIPPED_STEPS+=("$1")
}

show_setup_dashboard() {
    echo
    echo
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                      SETUP DASHBOARD                          ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo
    
    local total=$((${#COMPLETED_STEPS[@]} + ${#FAILED_STEPS[@]} + ${#SKIPPED_STEPS[@]}))
    
    log_kv "Total Steps" "$total"
    log_kv "Completed" "${#COMPLETED_STEPS[@]}"
    log_kv "Skipped" "${#SKIPPED_STEPS[@]}"
    log_kv "Failed" "${#FAILED_STEPS[@]}"
    
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    
    # Completed Steps
    if [ ${#COMPLETED_STEPS[@]} -gt 0 ]; then
        log_heredoc "${GREEN}" <<EOF
✅ COMPLETED (${#COMPLETED_STEPS[@]}):
EOF
        for step in "${COMPLETED_STEPS[@]}"; do
            echo "   • $step"
        done
        echo
    fi
    
    # Skipped Steps
    if [ ${#SKIPPED_STEPS[@]} -gt 0 ]; then
        log_heredoc "${YELLOW}" <<EOF
⏭️  SKIPPED (${#SKIPPED_STEPS[@]}):
EOF
        for step in "${SKIPPED_STEPS[@]}"; do
            echo "   • $step"
        done
        echo
    fi
    
    # Failed Steps
    if [ ${#FAILED_STEPS[@]} -gt 0 ]; then
        log_heredoc "${RED}" <<EOF
❌ FAILED (${#FAILED_STEPS[@]}):
EOF
        for step in "${FAILED_STEPS[@]}"; do
            echo "   • $step"
        done
        echo
    fi
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    
    # Final Status
    if [ ${#FAILED_STEPS[@]} -eq 0 ]; then
        log_success "🎉 All steps completed successfully!"
    else
        log_warning "⚠️  ${#FAILED_STEPS[@]} step(s) failed"
        log_info "Review errors above for details"
    fi
    
    echo
}

################################################################################
# Helper Functions
################################################################################

load_tool_preferences() {
    if [ -f "$PREFERENCES_FILE" ]; then
        source "$PREFERENCES_FILE"
        log_info "Loaded saved preferences from $PREFERENCES_FILE"
    fi
}

save_tool_preferences() {
    mkdir -p "$PREFERENCES_DIR"
    cat > "$PREFERENCES_FILE" << EOF
# Dotfiles tool preferences
# Generated on $(date)

INSTALL_SHELL_TOOLS=$INSTALL_SHELL_TOOLS
INSTALL_TERMINAL_TOOLS=$INSTALL_TERMINAL_TOOLS
INSTALL_EDITOR=$INSTALL_EDITOR
INSTALL_CLI_TOOLS=$INSTALL_CLI_TOOLS
INSTALL_MISE=$INSTALL_MISE
INSTALL_OBSIDIAN=$INSTALL_OBSIDIAN
EOF
    log_info "Saved preferences to $PREFERENCES_FILE"
}

show_help() {
    log_heredoc "${CYAN}" <<EOF
Dotfiles Setup Script

Usage: ./scripts/setup.sh [OPTIONS]

OPTIONS:
    --help                  Show this help message
    --minimal               Install dotfiles only, skip package installation
    --update                Re-stow dotfiles without reinstalling packages
    --revert                Restore backed-up files and remove dotfile symlinks
    --revert=BACKUP         Restore from specific backup (e.g., --revert=20260111_143022)
    --list-backups          List available backups
    --non-interactive       Skip interactive tool selection, use defaults/saved preferences
    --create-restore-point  Create system restore point before changes
    --skip-restore-prompt   Don't prompt for restore point creation

ENVIRONMENT VARIABLES:
    DOTFILES_DIR            Override dotfiles location (default: ~/workspace/dotfiles)

EXAMPLES:
    ./scripts/setup.sh                      # Full setup with interactive prompts
    ./scripts/setup.sh --minimal            # Just symlink dotfiles
    ./scripts/setup.sh --update             # Update dotfiles after git pull
    ./scripts/setup.sh --revert             # Revert to most recent backup
    
    # Use custom location
    DOTFILES_DIR=/tmp/dotfiles ./scripts/setup.sh
    
    # Run from anywhere
    cd /tmp/dotfiles && ./scripts/setup.sh
    cd ~ && ~/workspace/dotfiles/scripts/setup.sh

INSTALLATION COMPONENTS:
    The setup script installs in this order:
    1. System packages (zsh, tmux, neovim, etc.)
    2. mise runtime manager
    3. CLI tools via mise (ripgrep, fd, fzf, bat, eza)
    4. GUI applications (optional, interactive selection)
       - Terminal emulators (Ghostty, Alacritty, etc.)
       - IDEs (Cursor, VS Code, etc.)
       - Browsers (Chrome, Brave, etc.)
       - AI tools (Claude Desktop, Ollama, etc.)
    5. Dotfiles symlinking via GNU Stow

GUI APPLICATIONS:
    During setup, you'll be prompted to install GUI applications.
    You can also run the GUI installer separately:
        ./scripts/install_gui_apps.sh

SYSTEM RESTORE:
    The script always creates lightweight package manifests automatically.
    
    For full system snapshots with Timeshift, use the flag:
        ./scripts/setup.sh --create-restore-point
    
    This will prompt to install Timeshift (if needed) and create a full snapshot.
    
    Restore points created:
    - Package manifests (always, lightweight, automatic)
    - Dotfile backups (always, in ~/.dotfiles-backup/)
    - Timeshift snapshots (only with --create-restore-point flag)

TOOL SELECTION:
    On first run, you'll be prompted to select which tools to install.
    Your selections are saved to ~/.config/dotfiles/preferences for future runs.
    
    To change your selections, either:
    - Run the script again (it will load your previous choices)
    - Delete ~/.config/dotfiles/preferences to start fresh
    - Use --non-interactive to skip the prompt

EOF
}

################################################################################
# Parse Arguments
################################################################################

parse_args() {
    for arg in "$@"; do
        case $arg in
            --help)
                show_help
                exit 0
                ;;
            --minimal)
                MINIMAL_INSTALL=true
                ;;
            --update)
                UPDATE_ONLY=true
                ;;
            --revert)
                REVERT=true
                ;;
            --revert=*)
                REVERT=true
                SPECIFIC_BACKUP="${arg#*=}"
                ;;
            --list-backups)
                LIST_BACKUPS=true
                ;;
            --non-interactive)
                SKIP_INTERACTIVE=true
                ;;
            --create-restore-point)
                CREATE_RESTORE_POINT=true
                ;;
            --skip-restore-prompt)
                SKIP_RESTORE_PROMPT=true
                ;;
            *)
                log_error "Unknown option: $arg"
                show_help
                exit 1
                ;;
        esac
    done
}

################################################################################
# List Backups
################################################################################

list_backups() {
    log_section "Available Backups"
    
    if [ ! -d "$BACKUP_BASE_DIR" ]; then
        log_warning "No backups found at $BACKUP_BASE_DIR"
        return
    fi
    
    backups=($(ls -1 "$BACKUP_BASE_DIR" 2>/dev/null | sort -r))
    
    if [ ${#backups[@]} -eq 0 ]; then
        log_warning "No backups found"
        return
    fi
    
    echo "Found ${#backups[@]} backup(s):"
    echo
    
    for backup in "${backups[@]}"; do
        backup_path="$BACKUP_BASE_DIR/$backup"
        if [ -f "$backup_path/manifest.txt" ]; then
            file_count=$(wc -l < "$backup_path/manifest.txt")
            echo "  📁 $backup ($file_count files)"
        else
            echo "  📁 $backup"
        fi
    done
    
    echo
    echo "To restore a specific backup:"
    echo "  ./scripts/setup.sh --revert=BACKUP_NAME"
}

################################################################################
# Backup Functions
################################################################################

backup_file() {
    local file="$1"
    
    # Skip if file doesn't exist or is already a symlink
    if [ ! -e "$file" ] || [ -L "$file" ]; then
        return
    fi
    
    # Create backup directory if it doesn't exist
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        log_info "Created backup directory: $BACKUP_DIR"
    fi
    
    # Backup the file
    local relative_path="${file#$HOME/}"
    local backup_path="$BACKUP_DIR/$relative_path"
    local backup_parent=$(dirname "$backup_path")
    
    mkdir -p "$backup_parent"
    cp -a "$file" "$backup_path"
    
    # Add to manifest
    echo "$file" >> "$MANIFEST_FILE"
    
    log_info "Backed up: $relative_path"
}

backup_dotfiles() {
    log_section "Backing Up Existing Dotfiles"
    
    # Common dotfiles to backup
    local files_to_backup=(
        "$HOME/.zshrc"
        "$HOME/.bashrc"
        "$HOME/.bash_profile"
        "$HOME/.profile"
        "$HOME/.tmux.conf"
        "$HOME/.gitconfig"
        "$HOME/.config/nvim"
        "$HOME/.config/ghostty"
    )
    
    local backed_up=false
    
    for file in "${files_to_backup[@]}"; do
        if [ -e "$file" ] && [ ! -L "$file" ]; then
            backup_file "$file"
            backed_up=true
        fi
    done
    
    if [ "$backed_up" = true ]; then
        log_success "✅ Backup complete: $BACKUP_DIR"
        echo "$BACKUP_TIMESTAMP" > "$BACKUP_BASE_DIR/latest"
    else
        log_info "No files needed backup (all are symlinks or don't exist)"
    fi
    
    echo
}

################################################################################
# System Restore Point Functions
################################################################################

prompt_restore_point() {
    if [ "$SKIP_RESTORE_PROMPT" = true ]; then
        return
    fi
    
    log_section "System Restore Point"
    
    log_heredoc "${YELLOW}" <<EOF
Would you like to create a system restore point before making changes?

This script offers three levels of protection:

1. 📦 Package Manifest (Always enabled, lightweight)
   - Saves list of installed packages
   - Can reinstall same packages later
   - No disk space needed

2. 📁 Dotfile Backups (Always enabled)
   - Backs up your existing dotfiles
   - Can revert with --revert flag
   - Minimal disk space

3. 💾 Timeshift System Snapshot (Optional, requires installation)
   - Full system snapshot
   - Can restore entire system state
   - Requires ~5-20GB disk space
   - Best for complete safety

EOF
    
    if command_exists timeshift; then
        log_success "✅ Timeshift is already installed"
        
        if whiptail --title "Create Timeshift Snapshot?" \
            --yesno "Create a Timeshift system snapshot before proceeding?\n\nThis will take a few minutes and require 5-20GB of disk space." \
            12 70 3>&1 1>&2 2>&3; then
            CREATE_RESTORE_POINT=true
        fi
    else
        log_info "Timeshift is not installed"
        
        if whiptail --title "Install Timeshift?" \
            --yesno "Would you like to install Timeshift for full system snapshots?\n\nTimeshift allows you to restore your entire system to previous states.\n\nNote: This will install ~30MB of software." \
            15 70 3>&1 1>&2 2>&3; then
            install_timeshift
            CREATE_RESTORE_POINT=true
        else
            log_info "Skipping Timeshift installation"
            log_info "Package manifest and dotfile backups will still be created"
        fi
    fi
    
    echo
}

install_timeshift() {
    log_section "Installing Timeshift"
    
    local platform=$(detect_platform)
    
    case $platform in
        linux|wsl)
            log_info "Installing Timeshift..."
            sudo apt-get update
            sudo apt-get install -y timeshift
            log_success "✅ Timeshift installed"
            
            log_warning "Important: Timeshift works best with BTRFS or a separate backup partition"
            log_info "You can configure Timeshift later with: sudo timeshift-gtk"
            ;;
        macos)
            log_error "Timeshift is not available on macOS"
            log_info "macOS has Time Machine built-in for system backups"
            return 1
            ;;
        *)
            log_error "Timeshift not available for this platform"
            return 1
            ;;
    esac
    
    echo
}

create_package_manifest() {
    log_section "Creating Package Manifest"
    
    mkdir -p "$RESTORE_DIR"
    
    local platform=$(detect_platform)
    
    case $platform in
        linux|wsl)
            log_info "Saving APT package list..."
            dpkg --get-selections > "$PACKAGE_MANIFEST"
            
            # Also save apt sources
            if [ -f /etc/apt/sources.list ]; then
                cp /etc/apt/sources.list "$RESTORE_DIR/sources.list-$BACKUP_TIMESTAMP"
            fi
            
            # Save manually installed packages
            apt-mark showmanual > "$RESTORE_DIR/manual-packages-$BACKUP_TIMESTAMP.txt"
            
            log_success "✅ Package manifest saved to $PACKAGE_MANIFEST"
            log_kv "Total packages" "$(wc -l < "$PACKAGE_MANIFEST")"
            ;;
        macos)
            log_info "Saving Homebrew package list..."
            brew list > "$PACKAGE_MANIFEST"
            brew list --cask > "$RESTORE_DIR/cask-packages-$BACKUP_TIMESTAMP.txt"
            
            log_success "✅ Package manifest saved to $PACKAGE_MANIFEST"
            log_kv "Brew packages" "$(wc -l < "$PACKAGE_MANIFEST")"
            log_kv "Cask packages" "$(wc -l < "$RESTORE_DIR/cask-packages-$BACKUP_TIMESTAMP.txt")"
            ;;
    esac
    
    # Create a restore script
    create_package_restore_script
    
    echo
}

create_package_restore_script() {
    local restore_script="$RESTORE_DIR/restore-packages-$BACKUP_TIMESTAMP.sh"
    
    cat > "$restore_script" << 'EOF'
#!/usr/bin/env bash
# Package Restore Script
# Generated by dotfiles setup

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFEST="$SCRIPT_DIR/$(basename "$PACKAGE_MANIFEST")"

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Restoring APT packages..."
    sudo dpkg --set-selections < "$MANIFEST"
    sudo apt-get dselect-upgrade -y
    echo "✅ Packages restored"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Restoring Homebrew packages..."
    xargs brew install < "$MANIFEST"
    echo "✅ Packages restored"
fi
EOF
    
    chmod +x "$restore_script"
    log_info "Created restore script: $restore_script"
}

create_timeshift_snapshot() {
    if [ "$CREATE_RESTORE_POINT" != true ]; then
        return
    fi
    
    if ! command_exists timeshift; then
        log_warning "Timeshift not installed, skipping snapshot"
        return
    fi
    
    log_section "Creating Timeshift Snapshot"
    
    log_info "Creating system snapshot with Timeshift..."
    log_warning "This may take several minutes..."
    
    # Create snapshot with comment
    sudo timeshift --create --comments "Before dotfiles setup - $BACKUP_TIMESTAMP" --tags D
    
    if [ $? -eq 0 ]; then
        log_success "✅ Timeshift snapshot created successfully"
        log_info "You can restore this snapshot with: sudo timeshift --restore"
    else
        log_error "Failed to create Timeshift snapshot"
        log_warning "Continuing anyway (package manifest and dotfile backups still active)"
    fi
    
    echo
}

show_restore_info() {
    log_section "Restore Point Information"
    
    log_heredoc "${GREEN}" <<EOF
✅ System restore points created:

EOF
    
    log_kv "Package manifest" "$PACKAGE_MANIFEST"
    log_kv "Dotfile backup" "$BACKUP_DIR"
    
    if [ "$CREATE_RESTORE_POINT" = true ] && command_exists timeshift; then
        log_kv "Timeshift snapshot" "Created with tag: $BACKUP_TIMESTAMP"
    fi
    
    echo
    log_heredoc "${CYAN}" <<EOF
To restore your system:

1. Restore packages:
   $RESTORE_DIR/restore-packages-$BACKUP_TIMESTAMP.sh

2. Restore dotfiles:
   cd ~/workspace/dotfiles
   ./scripts/setup.sh --revert

3. Restore full system (if Timeshift snapshot was created):
   sudo timeshift --restore

EOF
}

revert_dotfiles() {
    local backup_to_use="$SPECIFIC_BACKUP"
    
    log_section "Reverting Dotfiles"
    
    # Determine which backup to use
    if [ -z "$backup_to_use" ]; then
        if [ -f "$BACKUP_BASE_DIR/latest" ]; then
            backup_to_use=$(cat "$BACKUP_BASE_DIR/latest")
            log_info "Using most recent backup: $backup_to_use"
        else
            error_exit "No backup found. Cannot revert."
        fi
    fi
    
    local restore_from="$BACKUP_BASE_DIR/$backup_to_use"
    
    if [ ! -d "$restore_from" ]; then
        log_error "Backup not found: $restore_from"
        list_backups
        exit 1
    fi
    
    if [ ! -f "$restore_from/manifest.txt" ]; then
        error_exit "Manifest not found in backup: $restore_from/manifest.txt"
    fi
    
    # Unstow ALL dotfiles first (remove ALL symlinks)
    log_info "Removing ALL dotfile symlinks..."
    if command_exists stow; then
        # Try to find the dotfiles directory
        local stow_dir=""
        if [ -d "$DOTFILES_DIR" ] && [ -d "$DOTFILES_DIR/home" ]; then
            stow_dir="$DOTFILES_DIR"
        elif [ -d ~/workspace/dotfiles/home ]; then
            stow_dir=~/workspace/dotfiles
        elif [ -d /tmp/dotfiles/home ]; then
            stow_dir=/tmp/dotfiles
        fi
        
        if [ -n "$stow_dir" ]; then
            cd "$stow_dir"
            stow -D -d "$stow_dir" -t "$HOME" home 2>/dev/null || true
            log_success "✅ Dotfile symlinks removed from $stow_dir"
        else
            log_warning "Could not find dotfiles directory to unstow"
            log_info "Manually removing symlinks from manifest..."
            
            # Fallback: manually remove symlinks
            while IFS= read -r file; do
                if [ -L "$file" ]; then
                    rm "$file"
                    log_info "Removed symlink: ${file#$HOME/}"
                fi
            done < "$restore_from/manifest.txt"
        fi
    else
        log_warning "GNU Stow not found, manually removing symlinks"
        
        # Manually remove symlinks from manifest
        while IFS= read -r file; do
            if [ -L "$file" ]; then
                rm "$file"
                log_info "Removed symlink: ${file#$HOME/}"
            fi
        done < "$restore_from/manifest.txt"
    fi
    
    # Restore files from backup
    log_info "Restoring files from backup..."
    
    while IFS= read -r file; do
        local relative_path="${file#$HOME/}"
        local backup_file="$restore_from/$relative_path"
        
        if [ -e "$backup_file" ]; then
            # Remove current file/symlink if it exists
            if [ -e "$file" ] || [ -L "$file" ]; then
                rm -rf "$file"
            fi
            
            # Create parent directory if needed
            local parent_dir=$(dirname "$file")
            mkdir -p "$parent_dir"
            
            # Restore the file
            cp -a "$backup_file" "$file"
            log_success "✅ Restored: $relative_path"
        else
            log_warning "Backup file not found: $relative_path"
        fi
    done < "$restore_from/manifest.txt"
    
    log_success "✅ Revert complete!"
    echo
    log_info "Your dotfiles have been restored from backup: $backup_to_use"
    log_info "Dotfiles repository is still at: $DOTFILES_DIR"
    echo
    log_warning "To re-apply dotfiles, run: ./scripts/setup.sh"
}

################################################################################
# Installation Functions
################################################################################

detect_platform() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if grep -q Microsoft /proc/version 2>/dev/null; then
            echo "wsl"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

install_prerequisites() {
    log_section "Installing Prerequisites"
    
    local platform=$(detect_platform)
    
    # Install whiptail for interactive menus (if not present and not skipping interactive)
    if [ "$SKIP_INTERACTIVE" = false ] && ! command_exists whiptail; then
        case $platform in
            linux|wsl)
                log_info "Installing whiptail for interactive menus..."
                sudo apt-get update
                sudo apt-get install -y whiptail
                ;;
            macos)
                log_info "Installing dialog for interactive menus..."
                if command_exists brew; then
                    brew install dialog
                    # Create whiptail alias for dialog
                    alias whiptail=dialog
                fi
                ;;
        esac
    fi
    
    # Install GNU Stow
    if ! command_exists stow; then
        log_info "Installing GNU Stow..."
        
        case $platform in
            linux|wsl)
                sudo apt-get update
                sudo apt-get install -y stow
                ;;
            macos)
                if ! command_exists brew; then
                    error_exit "Homebrew not found. Please install Homebrew first: https://brew.sh"
                fi
                brew install stow
                ;;
            *)
                error_exit "Unsupported platform"
                ;;
        esac
        
        log_success "✅ GNU Stow installed"
    else
        log_success "✅ GNU Stow already installed"
    fi
    
    echo
}

install_packages() {
    if [ "$MINIMAL_INSTALL" = true ]; then
        log_info "Skipping package installation (--minimal flag)"
        echo
        return
    fi
    
    log_section "Installing System Packages"
    
    local platform=$(detect_platform)
    
    # Interactive tool selection if whiptail is available
    if command_exists whiptail && [ -z "$SKIP_INTERACTIVE" ]; then
        select_tools_interactive
    fi
    
    case $platform in
        linux|wsl)
            log_info "Updating package lists..."
            sudo apt-get update -y
            
            log_info "Upgrading existing packages..."
            sudo apt-get upgrade -y
            
            log_info "Installing essential packages..."
            
            # Always install these core tools
            local core_packages=(
                build-essential
                curl
                wget
                git
            )
            
            # Optional tools based on selection
            local optional_packages=()
            
            if [ "${INSTALL_SHELL_TOOLS:-true}" = "true" ]; then
                optional_packages+=(zsh)
            fi
            
            if [ "${INSTALL_TERMINAL_TOOLS:-true}" = "true" ]; then
                optional_packages+=(tmux)
            fi
            
            if [ "${INSTALL_EDITOR:-true}" = "true" ]; then
                optional_packages+=(neovim)
            fi
            
            # Note: CLI tools (ripgrep, fd, fzf, bat, eza) will be installed via mise
            
            # Combine and install
            sudo apt-get install -y "${core_packages[@]}" "${optional_packages[@]}"
            
            log_success "✅ System packages installed"
            log_info "CLI tools will be installed via mise"
            
            # Install Obsidian if selected
            if [ "${INSTALL_OBSIDIAN:-false}" = "true" ]; then
                install_obsidian_linux
            fi
            ;;
        macos)
            if ! command_exists brew; then
                error_exit "Homebrew required for package installation"
            fi
            
            log_info "Installing packages via Homebrew..."
            
            local brew_packages=(stow git curl wget)
            
            if [ "${INSTALL_SHELL_TOOLS:-true}" = "true" ]; then
                brew_packages+=(zsh)
            fi
            
            if [ "${INSTALL_TERMINAL_TOOLS:-true}" = "true" ]; then
                brew_packages+=(tmux)
            fi
            
            if [ "${INSTALL_EDITOR:-true}" = "true" ]; then
                brew_packages+=(neovim)
            fi
            
            # Note: CLI tools (ripgrep, fd, fzf, bat, eza) will be installed via mise
            
            brew install "${brew_packages[@]}"
            
            log_success "✅ Homebrew packages installed"
            log_info "CLI tools will be installed via mise"
            
            # Install Obsidian if selected
            if [ "${INSTALL_OBSIDIAN:-false}" = "true" ]; then
                install_obsidian_macos
            fi
            ;;
    esac
    
    echo
}

install_obsidian_linux() {
    log_section "Installing Obsidian"
    
    if command_exists obsidian; then
        log_success "✅ Obsidian already installed"
        return
    fi
    
    # Check if we should use snap or AppImage
    if command_exists snap; then
        log_info "Installing Obsidian via Snap..."
        sudo snap install obsidian --classic
        log_success "✅ Obsidian installed via Snap"
    else
        log_info "Installing Obsidian AppImage..."
        
        # Create obsidian directory
        sudo mkdir -p /opt/obsidian
        
        # Download latest AppImage
        OBSIDIAN_VERSION="1.7.7"  # Update this as needed
        OBSIDIAN_URL="https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/Obsidian-${OBSIDIAN_VERSION}.AppImage"
        
        log_info "Downloading Obsidian ${OBSIDIAN_VERSION}..."
        sudo wget -O /opt/obsidian/Obsidian.AppImage "$OBSIDIAN_URL"
        sudo chmod +x /opt/obsidian/Obsidian.AppImage
        
        # Create desktop entry
        mkdir -p "$HOME/.local/share/applications"
        cat > "$HOME/.local/share/applications/obsidian.desktop" << 'EOF'
[Desktop Entry]
Name=Obsidian
Exec=/opt/obsidian/Obsidian.AppImage
Icon=obsidian
Type=Application
Categories=Office;
EOF
        
        # Create symlink for command line access
        sudo ln -sf /opt/obsidian/Obsidian.AppImage /usr/local/bin/obsidian
        
        log_success "✅ Obsidian installed via AppImage"
        log_info "Launch with: obsidian"
    fi
    
    echo
}

install_obsidian_macos() {
    log_section "Installing Obsidian"
    
    if [ -d "/Applications/Obsidian.app" ]; then
        log_success "✅ Obsidian already installed"
        return
    fi
    
    log_info "Installing Obsidian via Homebrew Cask..."
    brew install --cask obsidian
    log_success "✅ Obsidian installed"
    
    echo
}

select_tools_interactive() {
    log_section "Tool Selection"
    
    log_info "Select which tools to install/configure:"
    echo
    
    # Create options array for whiptail
    local options=(
        "SHELL_TOOLS" "Zsh (modern shell)" "${INSTALL_SHELL_TOOLS:-ON}"
        "TERMINAL_TOOLS" "tmux (terminal multiplexer)" "${INSTALL_TERMINAL_TOOLS:-ON}"
        "EDITOR" "Neovim (modern text editor)" "${INSTALL_EDITOR:-ON}"
        "CLI_TOOLS" "CLI tools (ripgrep, fd, fzf, bat, exa)" "${INSTALL_CLI_TOOLS:-ON}"
        "MISE" "mise (runtime version manager)" "${INSTALL_MISE:-ON}"
        "OLLAMA" "Ollama (local LLM)" "${INSTALL_OLLAMA:-OFF}"
        "CLAUDE_CODE" "Claude Code (AI coding assistant)" "${INSTALL_CLAUDE_CODE:-OFF}"
        "OBSIDIAN" "Obsidian (note-taking app)" "${INSTALL_OBSIDIAN:-OFF}"
    )
    
    # Run whiptail checklist
    local selections
    selections=$(whiptail --title "Dotfiles Setup - Tool Selection" \
        --checklist "Use SPACE to select/deselect, ENTER to confirm:" 20 70 10 \
        "${options[@]}" \
        3>&1 1>&2 2>&3)
    
    # Check if user cancelled
    if [ $? -ne 0 ]; then
        log_warning "Tool selection cancelled, using defaults"
        return
    fi
    
    # Reset all to false
    INSTALL_SHELL_TOOLS=false
    INSTALL_TERMINAL_TOOLS=false
    INSTALL_EDITOR=false
    INSTALL_CLI_TOOLS=false
    INSTALL_MISE=false
    INSTALL_OLLAMA=false
    INSTALL_CLAUDE_CODE=false
    INSTALL_OBSIDIAN=false
    
    # Set selected items to true
    for selection in $selections; do
        # Remove quotes
        selection=$(echo "$selection" | tr -d '"')
        case "$selection" in
            SHELL_TOOLS)
                INSTALL_SHELL_TOOLS=true
                ;;
            TERMINAL_TOOLS)
                INSTALL_TERMINAL_TOOLS=true
                ;;
            EDITOR)
                INSTALL_EDITOR=true
                ;;
            CLI_TOOLS)
                INSTALL_CLI_TOOLS=true
                ;;
            MISE)
                INSTALL_MISE=true
                ;;
            OLLAMA)
                INSTALL_OLLAMA=true
                ;;
            CLAUDE_CODE)
                INSTALL_CLAUDE_CODE=true
                ;;
            OBSIDIAN)
                INSTALL_OBSIDIAN=true
                ;;
        esac
    done
    
    # Show selections
    log_info "Selected tools:"
    [ "$INSTALL_SHELL_TOOLS" = "true" ] && log_success "  ✅ Zsh"
    [ "$INSTALL_TERMINAL_TOOLS" = "true" ] && log_success "  ✅ tmux"
    [ "$INSTALL_EDITOR" = "true" ] && log_success "  ✅ Neovim"
    [ "$INSTALL_CLI_TOOLS" = "true" ] && log_success "  ✅ CLI tools"
    [ "$INSTALL_MISE" = "true" ] && log_success "  ✅ mise"
    [ "$INSTALL_OBSIDIAN" = "true" ] && log_success "  ✅ Obsidian"
    echo
    
    # Save preferences
    save_tool_preferences
}

install_mise() {
    if [ "$MINIMAL_INSTALL" = true ] || [ "${INSTALL_MISE:-true}" != "true" ]; then
        return
    fi
    
    log_section "Installing mise"
    
    if command_exists mise; then
        log_success "✅ mise already installed ($(mise --version))"
    else
        log_info "Installing mise..."
        curl https://mise.run | sh
        
        # Add mise to current shell
        export PATH="$HOME/.local/bin:$PATH"
        
        if command_exists mise; then
            log_success "✅ mise installed successfully"
        else
            log_warning "mise installed but not in PATH yet"
            log_info "Restart your shell or run: export PATH=\"\$HOME/.local/bin:\$PATH\""
        fi
    fi
    
    # Install CLI tools via mise if selected
    if [ "${INSTALL_CLI_TOOLS:-true}" = "true" ]; then
        install_cli_tools_with_mise
    fi
    
    echo
}

install_cli_tools_with_mise() {
    log_section "Installing CLI Tools via mise"
    
    # Ensure mise is in PATH
    export PATH="$HOME/.local/bin:$PATH"
    
    if ! command_exists mise; then
        log_error "mise not found in PATH"
        return 1
    fi
    
    log_info "Installing CLI tools with mise..."
    log_warning "mise may ask you to trust config files - select 'yes' or 'all'"
    echo
    
    # Install each tool
    local tools=(
        "ripgrep"      # Fast grep alternative (rg)
        "fd"           # Fast find alternative
        "fzf"          # Fuzzy finder
        "bat"          # Cat with syntax highlighting
        "eza"          # Modern ls replacement
    )
    
    for tool in "${tools[@]}"; do
        log_info "Installing $tool..."
        # Use --yes to auto-approve trust prompts in non-interactive mode
        if [ "$SKIP_INTERACTIVE" = true ]; then
            mise use -g "$tool@latest" --yes || log_warning "Failed to install $tool"
        else
            mise use -g "$tool@latest" || log_warning "Failed to install $tool"
        fi
    done
    
    # Verify installations
    log_info "Verifying installations..."
    mise list
    
    log_success "✅ CLI tools installed via mise"
    log_info "Tools installed: ripgrep, fd, fzf, bat, eza"
    log_info "Run 'mise list' to see installed versions"
    
    echo
}

install_ollama() {
    if [ "${INSTALL_OLLAMA:-false}" = false ]; then
        return
    fi
    
    log_section "Installing Ollama"
    
    if command_exists ollama; then
        log_success "✅ Ollama already installed"
        track_skipped "Ollama (already installed)"
        return
    fi
    
    log_info "Installing Ollama..."
    if curl -fsSL https://ollama.com/install.sh | sh; then
        log_success "✅ Ollama installed"
        log_info "Start with: ollama serve"
        log_info "Pull models with: ollama pull <model>"
        track_completed "Ollama installed"
    else
        log_error "Failed to install Ollama"
        track_failed "Ollama" "installation failed"
    fi
    
    echo
}

install_claude_code() {
    if [ "${INSTALL_CLAUDE_CODE:-false}" = false ]; then
        return
    fi
    
    log_section "Installing Claude Code"
    
    if command_exists claude-code; then
        log_success "✅ Claude Code already installed"
        track_skipped "Claude Code (already installed)"
        return
    fi
    
    log_info "Installing Claude Code via npm..."
    if npm install -g @anthropic-ai/claude-code; then
        log_success "✅ Claude Code installed"
        log_info "Run with: claude-code"
        track_completed "Claude Code installed"
    else
        log_error "Failed to install Claude Code"
        log_info "Make sure npm is installed"
        track_failed "Claude Code" "npm install failed"
    fi
    
    echo
}

install_gui_applications() {
    if [ "$MINIMAL_INSTALL" = true ]; then
        log_info "Minimal install - skipping GUI applications"
        return
    fi
    
    log_section "GUI Applications"
    
    # Check if GUI installer exists
    if [ ! -f "$SCRIPT_DIR/install_gui_apps.sh" ]; then
        log_warning "GUI applications installer not found at $SCRIPT_DIR/install_gui_apps.sh"
        log_info "Skipping GUI applications installation"
        return
    fi
    
    # Check if running in non-interactive mode
    if [ "$SKIP_INTERACTIVE" = true ]; then
        log_info "Non-interactive mode - skipping GUI applications"
        log_info "Run './scripts/install_gui_apps.sh' manually to install GUI apps"
        return
    fi
    
    # Prompt user if they want to install GUI applications
    log_info "Would you like to install GUI applications (terminal emulators, IDEs, browsers, etc.)?"
    
    if whiptail --title "GUI Applications" --yesno "Install GUI applications?\n\nThis includes:\n- Terminal emulators (Ghostty, etc.)\n- IDEs (Cursor, VS Code, etc.)\n- Browsers (Chrome, Brave, etc.)\n- AI tools (Claude Desktop, Ollama, etc.)\n- And more..." 15 70 3>&1 1>&2 2>&3; then
        log_info "Starting GUI applications installer..."
        echo
        
        # Run the GUI installer
        if bash "$SCRIPT_DIR/install_gui_apps.sh"; then
            log_success "✅ GUI applications installer completed"
        else
            log_warning "GUI applications installer finished with some issues"
            log_info "Check the dashboard above for details"
        fi
    else
        log_info "Skipping GUI applications installation"
        log_info "You can run './scripts/install_gui_apps.sh' later to install GUI apps"
    fi
    
    echo
}

setup_zsh() {
    if [ "$MINIMAL_INSTALL" = true ] || [ "${INSTALL_SHELL_TOOLS:-true}" != "true" ]; then
        return
    fi
    
    log_section "Setting Up Zsh"
    
    # Install Oh My Zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log_info "Installing Oh My Zsh..."
        RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        log_success "✅ Oh My Zsh installed"
    else
        log_success "✅ Oh My Zsh already installed"
    fi
    
    # Set Zsh as default shell
    if [ "$SHELL" != "$(which zsh)" ]; then
        log_info "Setting Zsh as default shell..."
        if ! grep -q "$(which zsh)" /etc/shells; then
            echo "$(which zsh)" | sudo tee -a /etc/shells
        fi
        chsh -s "$(which zsh)"
        log_success "✅ Zsh set as default shell"
        log_warning "You'll need to log out and back in for this to take effect"
    else
        log_success "✅ Zsh is already the default shell"
    fi
    
    echo
}

stow_dotfiles() {
    log_section "Installing Dotfiles"
    
    cd "$DOTFILES_DIR"
    
    # Remove backed-up files that would conflict with stow
    # (They're already backed up, safe to remove)
    if [ -f "$MANIFEST_FILE" ]; then
        log_info "Removing backed-up files to prepare for stowing..."
        while IFS= read -r file; do
            if [ -e "$file" ] && [ ! -L "$file" ]; then
                rm -rf "$file"
                log_info "Removed: ${file#$HOME/}"
            fi
        done < "$MANIFEST_FILE"
    fi
    
    log_info "Stowing dotfiles to $HOME..."
    stow -v -d "$DOTFILES_DIR" -t "$HOME" home
    
    log_success "✅ Dotfiles symlinked successfully"
    echo
}

create_template_files() {
    log_section "Creating Template Files"
    
    # Create .secrets if it doesn't exist
    if [ ! -f "$HOME/.secrets" ]; then
        if [ -f "$HOME/.secrets.template" ]; then
            cp "$HOME/.secrets.template" "$HOME/.secrets"
            log_success "✅ Created ~/.secrets from template"
            log_warning "Remember to fill in your actual secrets!"
        fi
    fi
    
    # Create Git identity config if it doesn't exist
    if [ ! -f "$HOME/.config/git/identity.gitconfig" ]; then
        if [ -f "$HOME/.config/git/identity.gitconfig.template" ]; then
            cp "$HOME/.config/git/identity.gitconfig.template" "$HOME/.config/git/identity.gitconfig"
            log_success "✅ Created Git identity config from template"
            log_warning "Remember to configure your Git identity!"
        fi
    fi
    
    # Don't overwrite mise.toml if user already has one configured
    if [ ! -f "$HOME/.config/mise/mise.toml" ] && [ ! -f "$HOME/mise.toml" ]; then
        if [ -f "$HOME/.config/mise/mise.toml.template" ] || [ -L "$HOME/.config/mise/mise.toml.template" ]; then
            cp "$HOME/.config/mise/mise.toml.template" "$HOME/.config/mise/mise.toml"
            log_success "✅ Created mise config from template"
            log_info "Edit ~/.config/mise/mise.toml to add tools"
        fi
    else
        log_info "mise config already exists, skipping template"
    fi
    
    echo
}

################################################################################
# Post-Install
################################################################################

show_post_install() {
    log_section "Setup Complete!"
    
    log_heredoc "${GREEN}" <<EOF

✅ Dotfiles installed and symlinked
✅ Previous configs backed up to: $BACKUP_DIR

EOF
    
    log_heredoc "${YELLOW}" <<EOF
⚠️  Manual steps needed:

1. Log out and back in for shell changes to take effect

2. Configure secrets file:
   vim ~/.secrets

3. Set up Git identity:
   vim ~/.config/git/identity.gitconfig

4. If using SSH for Git, ensure your keys are set up:
   ssh -T git@github.com

EOF
    
    log_kv "📝 Backup location" "$BACKUP_DIR"
    echo
    log_info "To revert these changes:"
    log_info "   cd ~/workspace/dotfiles"
    log_info "   ./scripts/setup.sh --revert"
    echo
    log_info "To update dotfiles after pulling changes:"
    log_info "   cd ~/workspace/dotfiles"
    log_info "   ./scripts/setup.sh --update"
    echo
}

################################################################################
# Main
################################################################################

main() {
    parse_args "$@"
    
    # Load saved preferences
    load_tool_preferences
    
    # Handle special modes
    if [ "$LIST_BACKUPS" = true ]; then
        list_backups
        exit 0
    fi
    
    if [ "$REVERT" = true ]; then
        revert_dotfiles
        exit 0
    fi
    
    # Normal setup flow
    log_section "Dotfiles Setup"
    log_kv "Platform" "$(detect_platform)"
    log_kv "Dotfiles" "$DOTFILES_DIR"
    echo
    
    if [ "$UPDATE_ONLY" = false ]; then
        # Prompt for system restore point ONLY if explicitly requested
        if [ "$CREATE_RESTORE_POINT" = true ]; then
            prompt_restore_point
            if create_package_manifest && create_timeshift_snapshot; then
                track_completed "System restore point created"
            else
                track_failed "System restore point" "creation failed"
            fi
        else
            # Always create lightweight package manifest (no prompt needed)
            if create_package_manifest; then
                track_completed "Package manifest created"
            else
                track_failed "Package manifest" "creation failed"
            fi
        fi
        
        # Install system packages and tools
        if install_prerequisites; then
            track_completed "Prerequisites installed"
        else
            track_failed "Prerequisites" "installation failed"
        fi
        
        if backup_dotfiles; then
            track_completed "Dotfiles backed up"
        else
            track_failed "Dotfiles backup" "backup failed"
        fi
        
        if install_packages; then
            track_completed "System packages installed"
        else
            track_failed "System packages" "installation failed"
        fi
        
        if install_mise; then
            track_completed "mise installed"
        else
            track_failed "mise" "installation failed"
        fi
        
        if setup_zsh; then
            track_completed "Zsh configured"
        else
            track_failed "Zsh" "configuration failed"
        fi
        
        # Install optional CLI tools
        install_ollama || true
        install_claude_code || true
        
        # Install GUI applications (interactive)
        install_gui_applications || true
        # Note: GUI apps installer handles its own tracking
    fi
    
    if stow_dotfiles; then
        track_completed "Dotfiles symlinked"
    else
        track_failed "Dotfiles" "symlinking failed"
    fi
    
    if create_template_files; then
        track_completed "Template files created"
    else
        track_failed "Template files" "creation failed"
    fi
    
    # Show restore point info before dashboard
    if [ "$UPDATE_ONLY" = false ]; then
        show_restore_info
    fi
    
    # Show setup dashboard
    show_setup_dashboard
    
    # Show post-install instructions
    show_post_install
}

main "$@"
