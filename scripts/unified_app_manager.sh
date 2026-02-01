#!/usr/bin/env bash
# Unified Application Manager
# Handles installation/uninstallation of all applications (system, CLI, GUI)
# Cross-platform: Linux, macOS, WSL

set -uo pipefail

################################################################################
# Load logger functions
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/logger.sh"

################################################################################
# Platform Detection
################################################################################

detect_platform() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif grep -q Microsoft /proc/version 2>/dev/null;
 then
        echo "wsl"
    else
        echo "linux"
    fi
}

PLATFORM=$(detect_platform)

################################################################################
# Installation Tracking
################################################################################

declare -a INSTALLED_APPS=()
declare -a FAILED_APPS=()
declare -a SKIPPED_APPS=()
declare -a UNINSTALLED_APPS=()

track_installed() {
    INSTALLED_APPS+=("$1")
    log_success "✅ Installed"
}

track_failed() {
    FAILED_APPS+=("$1: $2")
    log_error "❌ Failed: $2"
}

track_skipped() {
    SKIPPED_APPS+=("$1")
    log_info "⏭️  Already installed"
}

track_uninstalled() {
    UNINSTALLED_APPS+=("$1")
    # Output to stderr to avoid contaminating function return values
    log_info "🗑️  Uninstalled" >&2
}

################################################################################
# Helper Functions
################################################################################

# Check if we are in WSL and warn about GUI apps
check_wsl_gui() {
    if [ "$PLATFORM" = "wsl" ]; then
        log_warning "GUI applications are not typically installed inside WSL."
        log_info "Please install the Windows version of this application."
        return 1
    fi
    return 0
}

# Install brew package (macOS only helper)
install_brew() {
    local package="$1"
    local cask="${2:-false}"
    
    if [ "$cask" = "true" ]; then
        if brew list --cask "$package" &>/dev/null; then
            track_skipped "$package"
            return 0
        fi
        log_info "Installing $package via Homebrew Cask..."
        if brew install --cask "$package" >> /tmp/app_install.log 2>&1; then
            track_installed "$package"
            return 0
        fi
    else
        if brew list --formula "$package" &>/dev/null; then
            track_skipped "$package"
            return 0
        fi
        log_info "Installing $package via Homebrew..."
        if brew install "$package" >> /tmp/app_install.log 2>&1; then
            track_installed "$package"
            return 0
        fi
    fi
    
    track_failed "$package" "brew install failed"
    return 1
}

# Ensure snap is installed (for apps that need it)
ensure_snap() {
    if command_exists snap; then
        return 0
    fi
    
    log_info "Installing snap (snapd) package manager..."
    
    if [ "$PLATFORM" = "macos" ]; then
        log_warning "snap is not available on macOS"
        return 1
    fi
    
    # Debian/Ubuntu/Pop!_OS
    if command_exists apt-get; then
        if sudo apt-get install -y snapd >> /tmp/app_install.log 2>&1; then
            # Enable and start snapd
            sudo systemctl enable --now snapd.socket >> /tmp/app_install.log 2>&1
            # Create classic snap symlink
            sudo ln -sf /var/lib/snapd/snap /snap 2>/dev/null
            log_success "✅ snapd installed"
            # Give snapd a moment to initialize
            sleep 2
            return 0
        fi
    fi
    
    # Fedora/RHEL
    if command_exists dnf; then
        if sudo dnf install -y snapd >> /tmp/app_install.log 2>&1; then
            sudo systemctl enable --now snapd.socket >> /tmp/app_install.log 2>&1
            sudo ln -sf /var/lib/snapd/snap /snap 2>/dev/null
            log_success "✅ snapd installed"
            sleep 2
            return 0
        fi
    fi
    
    log_warning "Could not install snapd automatically"
    return 1
}

# Ensure flatpak is installed
ensure_flatpak() {
    if command_exists flatpak; then
        return 0
    fi
    
    log_info "Installing flatpak package manager..."
    
    if [ "$PLATFORM" = "macos" ]; then
        log_warning "flatpak is not available on macOS"
        return 1
    fi
    
    # Debian/Ubuntu/Pop!_OS
    if command_exists apt-get; then
        if sudo apt-get install -y flatpak >> /tmp/app_install.log 2>&1; then
            # Add flathub repo
            flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo >> /tmp/app_install.log 2>&1
            log_success "✅ flatpak installed"
            return 0
        fi
    fi
    
    # Fedora (usually pre-installed)
    if command_exists dnf; then
        if sudo dnf install -y flatpak >> /tmp/app_install.log 2>&1; then
            flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo >> /tmp/app_install.log 2>&1
            log_success "✅ flatpak installed"
            return 0
        fi
    fi
    
    log_warning "Could not install flatpak automatically"
    return 1
}

# Run npm via mise if system npm not available
run_npm() {
    if command_exists npm; then
        npm "$@"
        return $?
    fi
    
    # Try via mise
    if command_exists mise; then
        mise exec -- npm "$@"
        return $?
    fi
    
    return 1
}

################################################################################
# Dashboard
################################################################################

show_dashboard() {
    echo
    echo
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                  APPLICATION INSTALLATION                     ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo
    
    local total=$((${#INSTALLED_APPS[@]} + ${#FAILED_APPS[@]} + ${#SKIPPED_APPS[@]} + ${#UNINSTALLED_APPS[@]}))
    
    log_kv "Total Applications" "$total"
    log_kv "Installed" "${#INSTALLED_APPS[@]}"
    log_kv "Already Installed" "${#SKIPPED_APPS[@]}"
    log_kv "Uninstalled" "${#UNINSTALLED_APPS[@]}"
    log_kv "Failed" "${#FAILED_APPS[@]}"
    
    echo
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    
    # Installed
    if [ ${#INSTALLED_APPS[@]} -gt 0 ]; then
        log_heredoc "${GREEN}" <<EOF
✅ INSTALLED (${#INSTALLED_APPS[@]}):
EOF
        for app in "${INSTALLED_APPS[@]}"; do
            echo "   • $app"
        done
        echo
    fi
    
    # Skipped
    if [ ${#SKIPPED_APPS[@]} -gt 0 ]; then
        log_heredoc "${YELLOW}" <<EOF
⏭️  ALREADY INSTALLED (${#SKIPPED_APPS[@]}):
EOF
        for app in "${SKIPPED_APPS[@]}"; do
            echo "   • $app"
        done
        echo
    fi
    
    # Uninstalled
    if [ ${#UNINSTALLED_APPS[@]} -gt 0 ]; then
        log_heredoc "${YELLOW}" <<EOF
🗑️  UNINSTALLED (${#UNINSTALLED_APPS[@]}):
EOF
        for app in "${UNINSTALLED_APPS[@]}"; do
            echo "   • $app"
        done
        echo
    fi
    
    # Failed
    if [ ${#FAILED_APPS[@]} -gt 0 ]; then
        log_heredoc "${RED}" <<EOF
❌ FAILED (${#FAILED_APPS[@]}):
EOF
        for app in "${FAILED_APPS[@]}"; do
            echo "   • $app"
        done
        echo
        log_warning "Check /tmp/app_install.log for details"
        echo
    fi
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
    
    if [ ${#FAILED_APPS[@]} -eq 0 ]; then
        log_success "🎉 All applications processed successfully!"
    else
        log_warning "⚠️  ${#FAILED_APPS[@]} application(s) failed"
    fi
    
    # Show helpful tips
    echo
    log_heredoc "${CYAN}" <<EOF
💡 Helpful Tips:

Manage mise tools:
  • View installed: mise list
  • Add a tool: mise use -g <tool>@latest
  • Remove a tool: Remove from ~/.config/mise/config.toml, then: mise uninstall <tool>
  • Update all: mise upgrade

Re-run this manager:
  ./scripts/unified_app_manager.sh

View detailed logs:
  cat /tmp/app_install.log
EOF
    
    # Open terminal font guide if mdview is installed
    if command_exists mdview; then
        # Check if neovim or fonts were installed/relevant
        local should_show_guide=false
        
        # Check if neovim was newly installed
        for app in "${INSTALLED_APPS[@]}"; do
            if [[ "$app" == *"Neovim"* ]] || [[ "$app" == *"Font"* ]]; then
                should_show_guide=true
                break
            fi
        done
        
        # Also show if neovim exists and mdview was just installed
        if command_exists nvim; then
            for app in "${INSTALLED_APPS[@]}"; do
                if [[ "$app" == *"mdview"* ]]; then
                    should_show_guide=true
                    break
                fi
            done
        fi
        
        if [ "$should_show_guide" = true ]; then
            echo
            log_heredoc "${CYAN}" <<EOF
📖 Opening Terminal Font Setup Guide in Browser...
EOF
            # Find the TERMINAL_FONT_SETUP.md file
            local font_guide=""
            if [ -f "$SCRIPT_DIR/../docs/TERMINAL_FONT_SETUP.md" ]; then
                font_guide="$SCRIPT_DIR/../docs/TERMINAL_FONT_SETUP.md"
            elif [ -f "$SCRIPT_DIR/../TERMINAL_FONT_SETUP.md" ]; then
                font_guide="$SCRIPT_DIR/../TERMINAL_FONT_SETUP.md"
            elif [ -f "$(dirname "$SCRIPT_DIR")/docs/TERMINAL_FONT_SETUP.md" ]; then
                font_guide="$(dirname "$SCRIPT_DIR")/docs/TERMINAL_FONT_SETUP.md"
            fi
            
            if [ -n "$font_guide" ] && [ -f "$font_guide" ]; then
                log_info "Starting mdview server..."
                
                # mdview might need the directory, not the file
                local guide_dir=$(dirname "$font_guide")
                
                # Start mdview pointing to the directory
                (cd "$guide_dir" && mdview . --port 8765) > /dev/null 2>&1 &
                local mdview_pid=$!
                sleep 2
                
                # Try to open browser to the specific file
                local guide_file=$(basename "$font_guide")
                if command -v xdg-open > /dev/null; then
                    xdg-open "http://localhost:8765/${guide_file}" > /dev/null 2>&1
                elif command -v open > /dev/null; then
                    open "http://localhost:8765/${guide_file}" > /dev/null 2>&1
                fi
                
                log_success "✅ Font setup guide opened at http://localhost:8765/${guide_file}"
                log_info "Follow the instructions to set your terminal font to 'JetBrainsMono Nerd Font Mono'"
                log_info "Press Ctrl+C in this terminal to stop the mdview server when done"
            else
                log_warning "Font guide not found (looked in: $SCRIPT_DIR/../docs/, $SCRIPT_DIR/../)"
                log_info "Manually set your terminal font to: JetBrainsMono Nerd Font Mono"
            fi
        fi
    fi
    
    echo
}

################################################################################
# Unified Application Selection
################################################################################

select_applications() {
    local non_interactive=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --non-interactive)
                non_interactive=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done

    # Non-interactive mode: read from .config file
    if [ "$non_interactive" = true ]; then
        log_info "Non-interactive mode: reading app selections from .config"

        # Source config if exists
        local config_file="${DOTFILES_DIR:-$HOME/workspace/dotfiles}/.config"
        if [ ! -f "$config_file" ]; then
            log_warning "No .config file found, using template defaults"
            config_file="${DOTFILES_DIR:-$HOME/workspace/dotfiles}/.config.template"
        fi

        if [ -f "$config_file" ]; then
            source "$config_file"
        fi

        # Build selection list based on INSTALL_* variables
        local selections=""

        [ "$INSTALL_ZSH" = "true" ] && selections="$selections zsh"
        [ "$INSTALL_TMUX" = "true" ] && selections="$selections tmux"
        [ "$INSTALL_NEOVIM" = "true" ] && selections="$selections neovim"
        [ "$INSTALL_MISE" = "true" ] && selections="$selections mise"
        [ "$INSTALL_MDVIEW" = "true" ] && selections="$selections mdview"
        [ "$INSTALL_GHOSTTY" = "true" ] && selections="$selections ghostty"
        [ "$INSTALL_CURSOR" = "true" ] && selections="$selections cursor"
        [ "$INSTALL_ANTIGRAVITY" = "true" ] && selections="$selections antigravity"
        [ "$INSTALL_CLAUDE_DESKTOP" = "true" ] && selections="$selections claude_desktop"
        [ "$INSTALL_CHROME" = "true" ] && selections="$selections chrome"
        [ "$INSTALL_VSCODE" = "true" ] && selections="$selections vscode"
        [ "$INSTALL_BRAVE" = "true" ] && selections="$selections brave"
        [ "$INSTALL_NOTION" = "true" ] && selections="$selections notion"
        [ "$INSTALL_OBSIDIAN" = "true" ] && selections="$selections obsidian"
        [ "$INSTALL_TELEGRAM" = "true" ] && selections="$selections telegram"
        [ "$INSTALL_1PASSWORD" = "true" ] && selections="$selections 1password"
        [ "$INSTALL_ORCA_SLICER" = "true" ] && selections="$selections orca_slicer"

        # Save selections
        mkdir -p ~/.config/dotfiles
        echo "$selections" > ~/.config/dotfiles/app-selections

        if [ -z "$selections" ]; then
            log_warning "No applications configured for installation"
        else
            log_info "Selected apps: $selections"
        fi

        echo "$selections"
        return 0
    fi

    # Interactive mode: Set high contrast colors for all whiptail dialogs
    export NEWT_COLORS=' 
root=white,black
window=white,black
border=cyan,black
textbox=white,black
button=black,cyan
compactbutton=white,black
checkbox=white,black
actcheckbox=black,cyan
entry=white,black
label=white,black
listbox=white,black
actlistbox=black,cyan
sellistbox=black,cyan
'

    # Interactive mode: Load config for defaults
    local config_file="${DOTFILES_DIR:-$HOME/workspace/dotfiles}/.config"
    if [ ! -f "$config_file" ]; then
        config_file="${DOTFILES_DIR:-$HOME/workspace/dotfiles}/.config.template"
    fi

    if [ -f "$config_file" ]; then
        source "$config_file"
    fi

    # Load previous selections
    local previous=""
    if [ -f ~/.config/dotfiles/app-selections ]; then
        previous=$(cat ~/.config/dotfiles/app-selections)
    fi

    # Detect what's currently installed to pre-check items
    local zsh_status="OFF"
    local tmux_status="OFF"
    local neovim_status="OFF"
    local mise_status="OFF"
    local mdview_status="OFF"
    local ghostty_status="OFF"
    local cursor_status="OFF"
    local antigravity_status="OFF"
    local claude_desktop_status="OFF"
    local chrome_status="OFF"
    local vscode_status="OFF"
    local brave_status="OFF"
    local notion_status="OFF"
    local obsidian_status="OFF"
    local telegram_status="OFF"
    local onepassword_status="OFF"
    local orca_slicer_status="OFF"

    # Pre-check if installed OR if config says to install
    (command_exists zsh || [ "$INSTALL_ZSH" = "true" ]) && zsh_status="ON"
    (command_exists tmux || [ "$INSTALL_TMUX" = "true" ]) && tmux_status="ON"
    (command_exists nvim || [ "$INSTALL_NEOVIM" = "true" ]) && neovim_status="ON"
    (command_exists mise || [ "$INSTALL_MISE" = "true" ]) && mise_status="ON"
    (command_exists mdview || [ "$INSTALL_MDVIEW" = "true" ]) && mdview_status="ON"
    
    # Platform-specific checks
    if [ "$PLATFORM" = "macos" ]; then
        (brew list --cask ghostty &>/dev/null || [ "$INSTALL_GHOSTTY" = "true" ]) && ghostty_status="ON"
        (brew list --cask cursor &>/dev/null || [ "$INSTALL_CURSOR" = "true" ]) && cursor_status="ON"
        [ "$INSTALL_ANTIGRAVITY" = "true" ] && antigravity_status="ON"
        (brew list --cask claude &>/dev/null || [ "$INSTALL_CLAUDE_DESKTOP" = "true" ]) && claude_desktop_status="ON"
        (brew list --cask google-chrome &>/dev/null || [ "$INSTALL_CHROME" = "true" ]) && chrome_status="ON"
        (brew list --cask visual-studio-code &>/dev/null || [ "$INSTALL_VSCODE" = "true" ]) && vscode_status="ON"
        (brew list --cask brave-browser &>/dev/null || [ "$INSTALL_BRAVE" = "true" ]) && brave_status="ON"
        (brew list --cask notion &>/dev/null || [ "$INSTALL_NOTION" = "true" ]) && notion_status="ON"
        (brew list --cask obsidian &>/dev/null || [ "$INSTALL_OBSIDIAN" = "true" ]) && obsidian_status="ON"
        (brew list --cask telegram &>/dev/null || [ "$INSTALL_TELEGRAM" = "true" ]) && telegram_status="ON"
        (brew list --cask 1password &>/dev/null || [ "$INSTALL_1PASSWORD" = "true" ]) && onepassword_status="ON"
        (brew list --cask orca-slicer &>/dev/null || [ "$INSTALL_ORCA_SLICER" = "true" ]) && orca_slicer_status="ON"
    else
        # Linux / WSL
        (command_exists ghostty || [ "$INSTALL_GHOSTTY" = "true" ]) && ghostty_status="ON"
        ((command_exists cursor || [ -f ~/.local/bin/cursor.AppImage ]) || [ "$INSTALL_CURSOR" = "true" ]) && cursor_status="ON"
        ((dpkg -l 2>/dev/null | grep -i antigravity | grep -qE "^[^ ]*ii") || [ "$INSTALL_ANTIGRAVITY" = "true" ]) && antigravity_status="ON"
        ((dpkg -l 2>/dev/null | grep -E "^ii\s+claude-desktop\s+" || snap list 2>/dev/null | grep -q "claudeai-desktop") || [ "$INSTALL_CLAUDE_DESKTOP" = "true" ]) && claude_desktop_status="ON"
        (command_exists google-chrome || [ "$INSTALL_CHROME" = "true" ]) && chrome_status="ON"
        (command_exists code || [ "$INSTALL_VSCODE" = "true" ]) && vscode_status="ON"
        (command_exists brave-browser || [ "$INSTALL_BRAVE" = "true" ]) && brave_status="ON"
        ((snap list 2>/dev/null | grep -q "notion-snap-reborn") || [ "$INSTALL_NOTION" = "true" ]) && notion_status="ON"
        ((command_exists obsidian || snap list 2>/dev/null | grep -q "obsidian") || [ "$INSTALL_OBSIDIAN" = "true" ]) && obsidian_status="ON"
        ((command_exists telegram-desktop || flatpak list 2>/dev/null | grep -q "org.telegram.desktop" || snap list 2>/dev/null | grep -q "telegram-desktop") || [ "$INSTALL_TELEGRAM" = "true" ]) && telegram_status="ON"
        (command_exists 1password || [ "$INSTALL_1PASSWORD" = "true" ]) && onepassword_status="ON"
        ([ -f ~/.local/bin/orca-slicer.AppImage ] || [ "$INSTALL_ORCA_SLICER" = "true" ]) && orca_slicer_status="ON"
    fi
    
    # Show re-run warning if applicable
    if [ -n "$previous" ]; then
        whiptail --title "⚠️  UNINSTALL WARNING" --msgbox \
"You have previously installed applications.

⚠️  UNCHECKING = UNINSTALL

Unchecked applications will be REMOVED from your system.

Apps that are currently installed will be pre-checked.

Press OK to continue..." 13 60 3>&1 1>&2 2>&3 || {
            log_error "Selection cancelled"
            exit 1
        }
    fi
    
    # Unified selection menu
    # Items marked [*] may require snap or flatpak if native package unavailable
    local selections=$(whiptail --title "Application Manager ($PLATFORM)" --checklist \
"Select applications (Space=select, Enter=confirm)

⚠️  WARNING: Unchecking installed apps will UNINSTALL them!

[*] = May install snap/flatpak if native package unavailable

System Tools:" 30 78 17 \
"zsh" "Zsh shell" "$zsh_status" \
"tmux" "Terminal multiplexer" "$tmux_status" \
"neovim" "Text editor [*]" "$neovim_status" \
"mise" "mise (installs ALL tools from config.toml)" "$mise_status" \
"mdview" "Markdown viewer (renders .md in browser)" "$mdview_status" \
"ghostty" "Ghostty terminal [*]" "$ghostty_status" \
"cursor" "Cursor AI IDE" "$cursor_status" \
"antigravity" "Antigravity IDE (Google)" "$antigravity_status" \
"claude_desktop" "Claude Desktop" "$claude_desktop_status" \
"chrome" "Google Chrome" "$chrome_status" \
"vscode" "VS Code" "$vscode_status" \
"brave" "Brave browser" "$brave_status" \
"notion" "Notion [*]" "$notion_status" \
"obsidian" "Obsidian (note-taking) [*]" "$obsidian_status" \
"telegram" "Telegram Desktop [*]" "$telegram_status" \
"1password" "1Password" "$onepassword_status" \
"orca_slicer" "Orca Slicer" "$orca_slicer_status" \
3>&1 1>&2 2>&3)
    
    # Check if user cancelled
    if [ $? -ne 0 ]; then
        log_error "Selection cancelled by user"
        exit 1
    fi
    
    # Check if we got selections
    if [ -z "$selections" ]; then
        log_warning "No applications selected"
        exit 0
    fi
    
    # Check if any apps that may need snap/flatpak are selected
    local needs_pkg_manager=false
    local pkg_manager_apps=""
    for app in neovim ghostty notion obsidian telegram; do
        if echo "$selections" | grep -qi "$app"; then
            needs_pkg_manager=true
            pkg_manager_apps="$pkg_manager_apps\n  • $app"
        fi
    done
    
    # Show acknowledgment if needed
    if [ "$needs_pkg_manager" = "true" ]; then
        whiptail --title "📦 Package Manager Notice" --yesno \
"The following apps may require snap or flatpak:
$pkg_manager_apps

The installer will first try your native package manager.
If that fails, it will install snap or flatpak as needed.

By continuing, you acknowledge that a new package manager
(snap or flatpak) may be installed on your system.

Continue with installation?" 18 65 3>&1 1>&2 2>&3
        
        if [ $? -ne 0 ]; then
            log_warning "Installation cancelled - you can re-run and select different apps"
            exit 0
        fi
    fi
    
    # Handle uninstalls
    if [ -n "$previous" ]; then
        for prev_app in $previous; do
            prev_app=$(echo "$prev_app" | tr -d '"')
            if [ -z "$prev_app" ]; then continue; fi
            
            if ! echo "$selections" | grep -q "$prev_app"; then
                # Redirect ALL output to stderr so nothing contaminates the return value
                {
                    log_section "Uninstalling $(echo $prev_app | tr '_' ' ' | sed 's/\b\(.\)/\u\1/g')"
                    uninstall_"$prev_app" 2>&1 || log_warning "No uninstall function"
                    echo
                } >&2
            fi
        done
    fi
    
    # Save selections
    mkdir -p ~/.config/dotfiles
    echo "$selections" > ~/.config/dotfiles/app-selections
    
    echo "$selections"
}

################################################################################
# System Tools Installation
################################################################################

install_zsh() {
    if command_exists zsh; then
        track_skipped "Zsh"
        return 0
    fi
    
    if [ "$PLATFORM" = "macos" ]; then
        install_brew "zsh"
        return
    fi
    
    if sudo apt-get install -y zsh >> /tmp/app_install.log 2>&1; then
        track_installed "Zsh"
    else
        track_failed "Zsh" "apt install failed"
    fi
}

install_tmux() {
    if command_exists tmux; then
        track_skipped "Tmux"
        return 0
    fi
    
    if [ "$PLATFORM" = "macos" ]; then
        install_brew "tmux"
        return
    fi
    
    if sudo apt-get install -y tmux >> /tmp/app_install.log 2>&1; then
        track_installed "Tmux"
    else
        track_failed "Tmux" "apt install failed"
    fi
}

install_neovim() {
    # Check if neovim is already installed with sufficient version
    if command_exists nvim; then
        local current_version=$(nvim --version 2>/dev/null | head -1 | grep -oP 'v?\K[0-9]+\.[0-9]+' | head -1)
        
        if [ -n "$current_version" ]; then
            local major=$(echo "$current_version" | cut -d. -f1)
            local minor=$(echo "$current_version" | cut -d. -f2)
            
            log_info "Found Neovim v$current_version"
            
            # Check if version >= 0.11
            if [ "$major" -gt 0 ] || ([ "$major" -eq 0 ] && [ "$minor" -ge 11 ]); then
                log_success "Neovim v$current_version is sufficient (>= 0.11.2)"
                track_skipped "Neovim"
                return 0
            else
                log_warning "Neovim v$current_version is too old (need >= 0.11.2), upgrading..."
                if [ "$PLATFORM" != "macos" ]; then
                    sudo apt-get remove -y neovim >> /tmp/app_install.log 2>&1 || true
                fi
            fi
        fi
    fi

    # macOS Installation
    if [ "$PLATFORM" = "macos" ]; then
        if install_brew "neovim"; then
             log_info "Installing Nerd Font for icons via Homebrew..."
             install_brew "font-jetbrains-mono-nerd-font" "true"
             return 0
        else
             return 1
        fi
    fi
    
    # Linux/WSL Installation
    # Method 1: Try unstable PPA (has latest versions including 0.11+)
    log_info "Installing Neovim from unstable PPA (has v0.11+)..."
    sudo add-apt-repository -y ppa:neovim-ppa/unstable >> /tmp/app_install.log 2>&1
    sudo apt-get update >> /tmp/app_install.log 2>&1
    
    if sudo apt-get install -y neovim >> /tmp/app_install.log 2>&1; then
        local ppa_version=$(nvim --version 2>/dev/null | head -1 | grep -oP 'v?\K[0-9]+\.[0-9]+' | head -1)
        log_success "Installed Neovim v$ppa_version via PPA"
        
        # Install dependencies for LazyVim
        log_info "Installing LazyVim dependencies..."
        
        # Install tree-sitter CLI (needed for parsers)
        if ! command_exists tree-sitter && command_exists npm; then
            npm install -g tree-sitter-cli >> /tmp/app_install.log 2>&1
        fi
        
        # Install ripgrep if not already installed (needed for telescope)
        if ! command_exists rg; then
            sudo apt-get install -y ripgrep >> /tmp/app_install.log 2>&1
        fi
        
        # Install a Nerd Font for icons (Manual install for Linux)
        log_info "Installing Nerd Font for icons..."
        
        # Create fonts directory with proper permissions
        if [ ! -d ~/.local/share ]; then
            mkdir -p ~/.local/share
        fi
        mkdir -p ~/.local/share/fonts
        
        # Verify directory was created
        if [ ! -d ~/.local/share/fonts ]; then
            log_error "Failed to create fonts directory"
            log_warning "Skipping font installation"
        else
            # Ensure curl and unzip are available
            if ! command_exists curl; then
                log_warning "curl not found, skipping font installation"
            elif ! command_exists unzip; then
                log_info "unzip not found, installing..."
                sudo apt-get install -y unzip >> /tmp/app_install.log 2>&1
            fi
            
            if command_exists curl && command_exists unzip; then
                # Download JetBrainsMono Nerd Font
                local font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip"
                log_info "Downloading JetBrainsMono Nerd Font (~50MB)..."
                
                if curl -L "$font_url" -o /tmp/JetBrainsMono.zip 2>&1 | tee -a /tmp/app_install.log; then
                    log_info "Extracting font files to ~/.local/share/fonts/JetBrainsMono..."
                    mkdir -p ~/.local/share/fonts/JetBrainsMono
                    
                    if unzip -o -q /tmp/JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMono 2>&1 | tee -a /tmp/app_install.log; then
                        rm /tmp/JetBrainsMono.zip
                        
                        # Verify fonts were extracted
                        local font_count=$(ls ~/.local/share/fonts/JetBrainsMono/*.ttf 2>/dev/null | wc -l)
                        if [ "$font_count" -gt 0 ]; then
                            log_info "Rebuilding font cache..."
                            if command_exists fc-cache; then
                                fc-cache -fv ~/.local/share/fonts >> /tmp/app_install.log 2>&1
                            fi
                            log_success "✅ JetBrainsMono Nerd Font installed ($font_count fonts)"
                            log_warning "⚠️  Set your terminal font to 'JetBrainsMono Nerd Font Mono' for icons"
                        else
                            log_error "No font files found after extraction"
                        fi
                    else
                        log_error "Failed to extract font files"
                        rm -f /tmp/JetBrainsMono.zip
                    fi
                else
                    log_error "Failed to download font"
                    rm -f /tmp/JetBrainsMono.zip
                fi
            else
                log_warning "Cannot install font - missing curl or unzip"
            fi
        fi
        
        log_info "LazyVim dependencies installed"
        
        track_installed "Neovim v$ppa_version (PPA)"
        return 0
    fi
    
    # Method 2: Try snap as fallback (Linux only)
    if command_exists snap; then
        log_info "PPA failed, trying Neovim via snap..."
        if sudo snap install nvim --classic >> /tmp/app_install.log 2>&1; then
            local snap_version=$(nvim --version 2>/dev/null | head -1 | grep -oP 'v?\K[0-9]+\.[0-9]+' | head -1)
            log_success "Installed Neovim v$snap_version via snap"
            track_installed "Neovim v$snap_version (snap)"
            return 0
        fi
    fi
    
    track_failed "Neovim" "all installation methods failed"
}

################################################################################
# mise and CLI Tools
################################################################################

install_mise() {
    if command_exists mise; then
        track_skipped "mise"
        return 0
    fi
    
    log_info "Installing mise..."
    if curl https://mise.run | sh >> /tmp/app_install.log 2>&1; then
        export PATH="$HOME/.local/bin:$PATH"
        
        log_success "✅ mise installed"
        
        # Install tools from config.toml if it exists
        if [ -f ~/.config/mise/config.toml ]; then
            log_info "Installing tools from ~/.config/mise/config.toml..."
            
            if mise install >> /tmp/app_install.log 2>&1; then
                log_success "✅ Tools installed from config.toml"
            else
                log_warning "Some tools failed to install from config.toml"
            fi
        fi
        
        track_installed "mise + CLI tools"
    else
        track_failed "mise" "install script failed"
    fi
}

install_mdview() {
    if command_exists mdview; then
        track_skipped "mdview"
        return 0
    fi
    
    # Check if npm is available (either system or via mise)
    if ! command_exists npm && ! command_exists mise; then
        log_warning "npm not found - install mise first or Node.js"
        track_failed "mdview" "npm not available"
        return 1
    fi
    
    log_info "Installing mdview..."
    if run_npm install -g mdview >> /tmp/app_install.log 2>&1; then
        log_success "✅ mdview installed"
        track_installed "mdview"
    else
        track_failed "mdview" "npm install failed"
    fi
}

################################################################################
# GUI Applications
################################################################################

install_ghostty() {
    check_wsl_gui || { track_skipped "Ghostty (WSL)"; return 0; }

    if [ "$PLATFORM" = "macos" ]; then
        install_brew "ghostty" "true"
        return
    fi

    if command_exists ghostty; then
        track_skipped "Ghostty"
        return 0
    fi
    
    # Check for Arch Linux (has official package)
    if command_exists pacman; then
        log_info "Installing Ghostty via pacman..."
        if sudo pacman -S --noconfirm ghostty >> /tmp/app_install.log 2>&1; then
            track_installed "Ghostty (pacman)"
            return 0
        fi
    fi
    
    # Try flatpak (Pop!_OS default)
    if command_exists flatpak; then
        log_info "Checking flatpak for Ghostty..."
        if flatpak install -y flathub com.mitchellh.ghostty >> /tmp/app_install.log 2>&1; then
            track_installed "Ghostty (flatpak)"
            return 0
        fi
    fi
    
    # Try snap as fallback (install snapd if needed)
    if ensure_snap; then
        log_info "Installing Ghostty via snap..."
        if sudo snap install ghostty --classic >> /tmp/app_install.log 2>&1; then
            track_installed "Ghostty (snap)"
            return 0
        fi
    fi
    
    # If we get here, provide manual instructions
    log_warning "Ghostty not available via package manager for your distro"
    log_info "For Ubuntu/Debian/Pop!_OS, you may need to build from source:"
    log_info "  https://ghostty.org/docs/install/build"
    log_info "Or install snap first: sudo apt install snapd && sudo snap install ghostty --edge"
    track_failed "Ghostty" "no package manager available - see instructions above"
}

install_cursor() {
    check_wsl_gui || { track_skipped "Cursor (WSL)"; return 0; }

    if [ "$PLATFORM" = "macos" ]; then
        install_brew "cursor" "true"
        return
    fi

    # Linux Installation
    local app_installed=false
    if command_exists cursor || [ -f ~/.local/bin/cursor.AppImage ]; then
        app_installed=true
    fi

    local cli_installed=false
    if [ -f ~/.local/bin/cursor-agent ]; then
        cli_installed=true
    fi

    if [ "$app_installed" = true ] && [ "$cli_installed" = true ]; then
        track_skipped "Cursor"
        return 0
    fi

    if [ "$app_installed" = true ]; then
        log_info "Installing missing Cursor CLI..."
        if curl -fsSL https://cursor.com/install | bash >> /tmp/app_install.log 2>&1; then
            log_success "Cursor CLI installed"
        fi
        track_skipped "Cursor (added CLI)"
        return 0
    fi
    
    local temp_deb="/tmp/cursor.deb"
    
    log_info "Downloading Cursor IDE..."
    if curl -L "https://api2.cursor.sh/updates/download/golden/linux-x64-deb/cursor/2.3" -o "$temp_deb" 2>&1 | tee -a /tmp/app_install.log; then
        if file "$temp_deb" | grep -q "Debian"; then
            log_info "Installing Cursor..."
            if sudo dpkg -i "$temp_deb" >> /tmp/app_install.log 2>&1; then
                sudo apt-get install -f -y >> /tmp/app_install.log 2>&1
                rm -f "$temp_deb"
                
                log_info "Installing Cursor CLI..."
                curl -fsSL https://cursor.com/install | bash >> /tmp/app_install.log 2>&1
                
                track_installed "Cursor"
            else
                rm -f "$temp_deb"
                track_failed "Cursor" "installation failed"
            fi
        else
            rm -f "$temp_deb"
            track_failed "Cursor" "invalid file type"
        fi
    else
        rm -f "$temp_deb"
        track_failed "Cursor" "download failed"
    fi
}

install_antigravity() {
    check_wsl_gui || { track_skipped "Antigravity (WSL)"; return 0; }
    
    if [ "$PLATFORM" = "macos" ]; then
        log_warning "Antigravity installation requires manual steps on macOS."
        log_info "Visit: https://antigravity.google/download"
        track_skipped "Antigravity (Manual)"
        return
    fi
    
    # Check if already installed
    if command_exists antigravity || dpkg -l 2>/dev/null | grep -qi "antigravity"; then
        track_skipped "Antigravity"
        return 0
    fi
    
    # Debian/Ubuntu/Pop!_OS - add apt repo
    if command_exists apt-get; then
        log_info "Adding Antigravity apt repository..."
        
        # Create keyrings directory
        sudo mkdir -p /etc/apt/keyrings >> /tmp/app_install.log 2>&1
        
        # Download and install signing key (Google Artifact Registry key)
        curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | \
            sudo gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg >> /tmp/app_install.log 2>&1
        
        # Add repository
        echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | \
            sudo tee /etc/apt/sources.list.d/antigravity.list > /dev/null
        
        # Update and install
        sudo apt-get update >> /tmp/app_install.log 2>&1
        if sudo apt-get install -y antigravity >> /tmp/app_install.log 2>&1; then
            track_installed "Antigravity"
            return 0
        fi
    fi
    
    # Fedora/RHEL - add yum/dnf repo
    if command_exists dnf; then
        log_info "Adding Antigravity dnf repository..."
        
        sudo tee /etc/yum.repos.d/antigravity.repo > /dev/null << 'EOF'
[antigravity-rpm]
name=Antigravity RPM Repository
baseurl=https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-rpm
enabled=1
gpgcheck=0
EOF
        
        sudo dnf makecache >> /tmp/app_install.log 2>&1
        if sudo dnf install -y antigravity >> /tmp/app_install.log 2>&1; then
            track_installed "Antigravity"
            return 0
        fi
    fi
    
    track_failed "Antigravity" "installation failed - check /tmp/app_install.log"
}

install_claude_desktop() {
    check_wsl_gui || { track_skipped "Claude Desktop (WSL)"; return 0; }

    if [ "$PLATFORM" = "macos" ]; then
        install_brew "claude" "true"
        return
    fi

    # Check if already installed via dpkg
    if dpkg -l 2>/dev/null | grep -E "^ii\s+claude-desktop\s+" >> /tmp/app_install.log 2>&1; then
        track_skipped "Claude Desktop"
        return 0
    fi

    # Warning about unofficial installation
    log_warning "⚠️  Using UNOFFICIAL Claude Desktop installation"
    log_info "Source: https://github.com/aaddrick/claude-desktop-debian"
    log_info "This is a community-maintained Debian package, not official Anthropic software"

    local temp_deb="/tmp/claude-desktop.deb"

    log_info "Fetching latest Claude Desktop release..."
    local latest_url=$(curl -s https://api.github.com/repos/aaddrick/claude-desktop-debian/releases/latest 2>/dev/null | \
        grep '"browser_download_url"' | \
        grep '\.deb"' | \
        head -1 | \
        cut -d '"' -f 4)

    if [ -z "$latest_url" ]; then
        track_failed "Claude Desktop" "failed to fetch download URL"
        return 1
    fi

    log_info "Downloading Claude Desktop from unofficial repo..."
    if curl -L "$latest_url" -o "$temp_deb" 2>&1 | tee -a /tmp/app_install.log; then
        if file "$temp_deb" | grep -q "Debian"; then
            log_info "Installing Claude Desktop..."
            # Install dependencies first
            log_info "Installing dependencies (nodejs, npm, p7zip-full)..."
            sudo apt-get update >> /tmp/app_install.log 2>&1
            sudo apt-get install -y nodejs npm p7zip-full >> /tmp/app_install.log 2>&1

            # Now install the package - even if dpkg fails due to dependency issues,
            # we'll fix them with apt-get install -f
            sudo dpkg -i "$temp_deb" >> /tmp/app_install.log 2>&1 || true
            sudo apt-get install -f -y >> /tmp/app_install.log 2>&1

            # Check if installation succeeded
            if dpkg -l 2>/dev/null | grep -E "^ii\s+claude-desktop\s+" >> /tmp/app_install.log 2>&1; then
                rm -f "$temp_deb"
                track_installed "Claude Desktop (unofficial)"
            else
                rm -f "$temp_deb"
                track_failed "Claude Desktop" "installation failed"
            fi
        else
            rm -f "$temp_deb"
            track_failed "Claude Desktop" "invalid file type"
        fi
    else
        rm -f "$temp_deb"
        track_failed "Claude Desktop" "download failed"
    fi
}

install_chrome() {
    check_wsl_gui || { track_skipped "Chrome (WSL)"; return 0; }
    
    if [ "$PLATFORM" = "macos" ]; then
        install_brew "google-chrome" "true"
        return
    fi

    if command_exists google-chrome; then
        track_skipped "Google Chrome"
        return 0
    fi
    
    wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb >> /tmp/app_install.log 2>&1
    if sudo dpkg -i /tmp/chrome.deb >> /tmp/app_install.log 2>&1; then
        sudo apt-get install -f -y >> /tmp/app_install.log 2>&1
        rm -f /tmp/chrome.deb
        track_installed "Google Chrome"
    else
        rm -f /tmp/chrome.deb
        track_failed "Google Chrome" "installation failed"
    fi
}

install_vscode() {
    check_wsl_gui || { track_skipped "VS Code (WSL)"; return 0; }
    
    if [ "$PLATFORM" = "macos" ]; then
        install_brew "visual-studio-code" "true"
        return
    fi

    if command_exists code; then
        track_skipped "VS Code"
        return 0
    fi
    
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg 2>> /tmp/app_install.log
    sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg >> /tmp/app_install.log 2>&1
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f /tmp/packages.microsoft.gpg
    
    sudo apt-get update >> /tmp/app_install.log 2>&1
    if sudo apt-get install -y code >> /tmp/app_install.log 2>&1; then
        track_installed "VS Code"
    else
        track_failed "VS Code" "installation failed"
    fi
}

install_brave() {
    check_wsl_gui || { track_skipped "Brave (WSL)"; return 0; }
    
    if [ "$PLATFORM" = "macos" ]; then
        install_brew "brave-browser" "true"
        return
    fi

    if command_exists brave-browser; then
        track_skipped "Brave"
        return 0
    fi
    
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg >> /tmp/app_install.log 2>&1
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt-get update >> /tmp/app_install.log 2>&1
    if sudo apt-get install -y brave-browser >> /tmp/app_install.log 2>&1; then
        track_installed "Brave Browser"
    else
        track_failed "Brave" "installation failed"
    fi
}

install_notion() {
    check_wsl_gui || { track_skipped "Notion (WSL)"; return 0; }
    
    if [ "$PLATFORM" = "macos" ]; then
        install_brew "notion" "true"
        return
    fi

    if snap list 2>/dev/null | grep -q "notion-snap-reborn"; then
        track_skipped "Notion"
        return 0
    fi
    
    # Notion requires snap
    if ! ensure_snap; then
        track_failed "Notion" "snap not available"
        return 1
    fi
    
    if sudo snap install notion-snap-reborn >> /tmp/app_install.log 2>&1; then
        track_installed "Notion"
    else
        track_failed "Notion" "snap install failed"
    fi
}

install_obsidian() {
    check_wsl_gui || { track_skipped "Obsidian (WSL)"; return 0; }
    
    if [ "$PLATFORM" = "macos" ]; then
        install_brew "obsidian" "true"
        return
    fi

    if command_exists obsidian || snap list 2>/dev/null | grep -q "obsidian"; then
        track_skipped "Obsidian"
        return 0
    fi
    
    # Try snap (install snapd if needed)
    if ensure_snap; then
        if sudo snap install obsidian --classic >> /tmp/app_install.log 2>&1; then
            track_installed "Obsidian (snap)"
            return 0
        fi
    fi
    
    # AppImage fallback
    mkdir -p ~/.local/bin
    local latest_url=$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest 2>/dev/null | grep "browser_download_url.*AppImage" | cut -d '"' -f 4)
    
    if [ -n "$latest_url" ] && curl -L "$latest_url" -o ~/.local/bin/obsidian.AppImage >> /tmp/app_install.log 2>&1; then
        chmod +x ~/.local/bin/obsidian.AppImage
        
        cat > ~/.local/bin/obsidian << 'EOF'
#!/bin/bash
exec ~/.local/bin/obsidian.AppImage "$@"
EOF
        chmod +x ~/.local/bin/obsidian
        
        mkdir -p ~/.local/share/applications
        cat > ~/.local/share/applications/obsidian.desktop << 'EOF'
[Desktop Entry]
Name=Obsidian
Exec=/home/$USER/.local/bin/obsidian
Icon=obsidian
Type=Application
Categories=Office;
EOF
        track_installed "Obsidian (AppImage)"
    else
        track_failed "Obsidian" "installation failed"
    fi
}

install_telegram() {
    check_wsl_gui || { track_skipped "Telegram (WSL)"; return 0; }
    
    if [ "$PLATFORM" = "macos" ]; then
        install_brew "telegram" "true"
        return
    fi

    # Check if already installed
    if command_exists telegram-desktop || \
       flatpak list 2>/dev/null | grep -q "org.telegram.desktop" || \
       snap list 2>/dev/null | grep -q "telegram-desktop"; then
        track_skipped "Telegram"
        return 0
    fi
    
    # Try flatpak first (Pop!_OS default)
    if command_exists flatpak; then
        log_info "Installing Telegram via Flatpak..."
        if flatpak install -y flathub org.telegram.desktop >> /tmp/app_install.log 2>&1; then
            track_installed "Telegram (flatpak)"
            return 0
        fi
    fi
    
    # Try snap as fallback (install snapd if needed)
    if ensure_snap; then
        if sudo snap install telegram-desktop >> /tmp/app_install.log 2>&1; then
            track_installed "Telegram (snap)"
            return 0
        fi
    fi
    
    # Try apt as last resort
    if command_exists apt; then
        if sudo apt-get install -y telegram-desktop >> /tmp/app_install.log 2>&1; then
            track_installed "Telegram (apt)"
            return 0
        fi
    fi
    
    track_failed "Telegram" "installation failed - no supported package manager"
}

install_1password() {
    check_wsl_gui || { track_skipped "1Password (WSL)"; return 0; }
    
    if [ "$PLATFORM" = "macos" ]; then
        install_brew "1password" "true"
        return
    fi

    if command_exists 1password; then
        track_skipped "1Password"
        return 0
    fi
    
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg >> /tmp/app_install.log 2>&1
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | sudo tee /etc/apt/sources.list.d/1password.list
    
    sudo apt-get update >> /tmp/app_install.log 2>&1
    if sudo apt-get install -y 1password >> /tmp/app_install.log 2>&1; then
        track_installed "1Password"
    else
        track_failed "1Password" "installation failed"
    fi
}

install_orca_slicer() {
    check_wsl_gui || { track_skipped "Orca Slicer (WSL)"; return 0; }
    
    if [ "$PLATFORM" = "macos" ]; then
        install_brew "orca-slicer" "true"
        return
    fi

    if [ -f ~/.local/bin/orca-slicer.AppImage ]; then
        track_skipped "Orca Slicer"
        return 0
    fi
    
    mkdir -p ~/.local/bin

    log_info "Fetching latest Orca Slicer release info..."
    local url=$(curl -s https://api.github.com/repos/OrcaSlicer/OrcaSlicer/releases/latest 2>/dev/null | \
        grep '"browser_download_url"' | \
        grep -i "linux.*appimage.*ubuntu" | \
        head -1 | \
        cut -d '"' -f 4)

    if [ -z "$url" ]; then
        log_error "Could not fetch latest Orca Slicer download URL"
        track_failed "Orca Slicer" "failed to fetch download URL"
        return
    fi

    log_info "Downloading Orca Slicer..."
    if curl -L "$url" -o ~/.local/bin/orca-slicer.AppImage 2>&1 | tee -a /tmp/app_install.log; then
        local filesize=$(stat -c%s ~/.local/bin/orca-slicer.AppImage 2>/dev/null || echo "0")
        if [ "$filesize" -gt 100000000 ]; then
            chmod +x ~/.local/bin/orca-slicer.AppImage

            mkdir -p "$HOME/.local/share/icons/hicolor/256x256/apps"
            curl -sL "https://raw.githubusercontent.com/OrcaSlicer/OrcaSlicer/main/resources/images/OrcaSlicer_192px.png" \
                -o "$HOME/.local/share/icons/hicolor/256x256/apps/orca-slicer.png" >> /tmp/app_install.log 2>&1

            mkdir -p "$HOME/.local/share/applications"
            cat > "$HOME/.local/share/applications/orca-slicer.desktop" << EOF
[Desktop Entry]
Name=Orca Slicer
Comment=3D Printing Slicer
Exec=$HOME/.local/bin/orca-slicer.AppImage %F
Icon=orca-slicer
Terminal=false
Type=Application
Categories=Graphics;3DGraphics;Engineering;
MimeType=model/stl;application/x-3mf;application/vnd.ms-3mfdocument;
StartupNotify=true
EOF
            chmod +x "$HOME/.local/share/applications/orca-slicer.desktop"

            if command_exists update-desktop-database; then
                update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true
            fi

            track_installed "Orca Slicer"
        else
            rm -f ~/.local/bin/orca-slicer.AppImage
            track_failed "Orca Slicer" "invalid file size"
        fi
    else
        rm -f ~/.local/bin/orca-slicer.AppImage
        track_failed "Orca Slicer" "download failed"
    fi
}

################################################################################
# Uninstall Functions
################################################################################

uninstall_zsh() {
    if [ "$PLATFORM" = "macos" ]; then
        brew uninstall zsh >> /tmp/app_install.log 2>&1
        track_uninstalled "Zsh"
    elif command_exists zsh; then
        sudo apt-get remove -y zsh >> /tmp/app_install.log 2>&1
        track_uninstalled "Zsh"
    fi
}

uninstall_tmux() {
    if [ "$PLATFORM" = "macos" ]; then
        brew uninstall tmux >> /tmp/app_install.log 2>&1
        track_uninstalled "Tmux"
    elif command_exists tmux; then
        sudo apt-get remove -y tmux >> /tmp/app_install.log 2>&1
        track_uninstalled "Tmux"
    fi
}

uninstall_neovim() {
    if [ "$PLATFORM" = "macos" ]; then
        brew uninstall neovim >> /tmp/app_install.log 2>&1
        track_uninstalled "Neovim"
        return
    fi

    local uninstalled=false
    if [ -f ~/.local/bin/nvim.appimage ]; then
        rm -f ~/.local/bin/nvim.appimage
        rm -f ~/.local/bin/nvim
        uninstalled=true
    fi
    if snap list 2>/dev/null | grep -q "nvim"; then
        sudo snap remove nvim >> /tmp/app_install.log 2>&1
        uninstalled=true
    fi
    if command_exists nvim && ! [ -f ~/.local/bin/nvim.appimage ]; then
        sudo apt-get remove -y neovim >> /tmp/app_install.log 2>&1
        sudo add-apt-repository -y --remove ppa:neovim-ppa/unstable >> /tmp/app_install.log 2>&1 || true
        uninstalled=true
    fi
    [ "$uninstalled" = true ] && track_uninstalled "Neovim"
}

uninstall_mise() {
    log_warning "Removing mise will remove ALL tools installed via mise"
    track_uninstalled "mise (manual cleanup recommended)"
}

uninstall_mdview() {
    if command_exists mdview; then
        npm uninstall -g mdview >> /tmp/app_install.log 2>&1
        track_uninstalled "mdview"
    fi
}

uninstall_ghostty() {
    if [ "$PLATFORM" = "macos" ]; then
        brew uninstall --cask ghostty >> /tmp/app_install.log 2>&1
        track_uninstalled "Ghostty"
    elif command_exists ghostty; then
        sudo snap remove ghostty >> /tmp/app_install.log 2>&1
        track_uninstalled "Ghostty"
    fi
}

uninstall_cursor() {
    if [ "$PLATFORM" = "macos" ]; then
        brew uninstall --cask cursor >> /tmp/app_install.log 2>&1
        track_uninstalled "Cursor"
        return
    fi
    
    local uninstalled=false
    if [ -f ~/.local/bin/cursor-agent ] || [ -d ~/.local/share/cursor-agent ]; then
        rm -f ~/.local/bin/agent
        rm -f ~/.local/bin/cursor-agent
        rm -rf ~/.local/share/cursor-agent
    fi
    if [ -f ~/.local/bin/cursor.AppImage ]; then
        rm -f ~/.local/bin/cursor.AppImage
        rm -f ~/.local/share/applications/cursor.desktop
        uninstalled=true
    fi
    if dpkg -l | grep -qE "^ii\s+cursor\s+"; then
        sudo apt-get remove -y cursor >> /tmp/app_install.log 2>&1
        uninstalled=true
    fi
    [ "$uninstalled" = true ] && track_uninstalled "Cursor"
}

uninstall_antigravity() {
    if dpkg -l | grep -q antigravity; then
        sudo apt-get remove -y antigravity >> /tmp/app_install.log 2>&1
        track_uninstalled "Antigravity"
    fi
}

uninstall_claude_desktop() {
    if [ "$PLATFORM" = "macos" ]; then
        brew uninstall --cask claude >> /tmp/app_install.log 2>&1
        track_uninstalled "Claude Desktop"
        return
    fi

    local uninstalled=false

    # Remove snap version if exists
    if snap list 2>/dev/null | grep -q "claudeai-desktop"; then
        sudo snap remove claudeai-desktop >> /tmp/app_install.log 2>&1
        uninstalled=true
    fi

    # Remove debian package version if exists
    if dpkg -l 2>/dev/null | grep -E "^ii\s+claude-desktop\s+" >> /tmp/app_install.log 2>&1; then
        log_info "Removing Claude Desktop debian package..."
        sudo dpkg -P claude-desktop >> /tmp/app_install.log 2>&1
        uninstalled=true
    fi

    # Clean up user configuration
    if [ -d ~/.config/Claude ]; then
        log_info "Removing Claude Desktop configuration..."
        rm -rf ~/.config/Claude
    fi

    [ "$uninstalled" = true ] && track_uninstalled "Claude Desktop"
}

uninstall_chrome() {
    if [ "$PLATFORM" = "macos" ]; then
        brew uninstall --cask google-chrome >> /tmp/app_install.log 2>&1
        track_uninstalled "Google Chrome"
    elif command_exists google-chrome; then
        sudo apt-get remove -y google-chrome-stable >> /tmp/app_install.log 2>&1
        track_uninstalled "Google Chrome"
    fi
}

uninstall_obsidian() {
    if [ "$PLATFORM" = "macos" ]; then
        brew uninstall --cask obsidian >> /tmp/app_install.log 2>&1
        track_uninstalled "Obsidian"
        return
    fi
    
    local uninstalled=false
    if snap list 2>/dev/null | grep -q "obsidian"; then
        sudo snap remove obsidian >> /tmp/app_install.log 2>&1
        uninstalled=true
    fi
    if [ -f ~/.local/bin/obsidian.AppImage ]; then
        rm -f ~/.local/bin/obsidian.AppImage
        rm -f ~/.local/bin/obsidian
        rm -f ~/.local/share/applications/obsidian.desktop
        uninstalled=true
    fi
    [ "$uninstalled" = true ] && track_uninstalled "Obsidian"
}

uninstall_telegram() {
    if [ "$PLATFORM" = "macos" ]; then
        brew uninstall --cask telegram >> /tmp/app_install.log 2>&1
        track_uninstalled "Telegram"
        return
    fi
    
    local uninstalled=false
    if flatpak list 2>/dev/null | grep -q "org.telegram.desktop"; then
        flatpak uninstall -y org.telegram.desktop >> /tmp/app_install.log 2>&1
        uninstalled=true
    fi
    if snap list 2>/dev/null | grep -q "telegram-desktop"; then
        sudo snap remove telegram-desktop >> /tmp/app_install.log 2>&1
        uninstalled=true
    fi
    if dpkg -l telegram-desktop 2>/dev/null | grep -q "^ii"; then
        sudo apt-get remove -y telegram-desktop >> /tmp/app_install.log 2>&1
        uninstalled=true
    fi
    [ "$uninstalled" = true ] && track_uninstalled "Telegram"
}

uninstall_vscode() {
    if [ "$PLATFORM" = "macos" ]; then
        brew uninstall --cask visual-studio-code >> /tmp/app_install.log 2>&1
        track_uninstalled "VS Code"
    elif command_exists code; then
        sudo apt-get remove -y code >> /tmp/app_install.log 2>&1
        sudo rm -f /etc/apt/sources.list.d/vscode.list
        sudo rm -f /etc/apt/keyrings/packages.microsoft.gpg
        track_uninstalled "VS Code"
    fi
}

uninstall_brave() {
    if [ "$PLATFORM" = "macos" ]; then
        brew uninstall --cask brave-browser >> /tmp/app_install.log 2>&1
        track_uninstalled "Brave Browser"
    elif command_exists brave-browser; then
        sudo apt-get remove -y brave-browser >> /tmp/app_install.log 2>&1
        sudo rm -f /etc/apt/sources.list.d/brave-browser-release.list
        sudo rm -f /usr/share/keyrings/brave-browser-archive-keyring.gpg
        track_uninstalled "Brave Browser"
    fi
}

uninstall_notion() {
    if [ "$PLATFORM" = "macos" ]; then
        brew uninstall --cask notion >> /tmp/app_install.log 2>&1
        track_uninstalled "Notion"
    elif snap list 2>/dev/null | grep -q "notion-snap-reborn"; then
        sudo snap remove notion-snap-reborn >> /tmp/app_install.log 2>&1
        track_uninstalled "Notion"
    fi
}

uninstall_1password() {
    if [ "$PLATFORM" = "macos" ]; then
        brew uninstall --cask 1password >> /tmp/app_install.log 2>&1
        track_uninstalled "1Password"
    elif command_exists 1password; then
        sudo apt-get remove -y 1password >> /tmp/app_install.log 2>&1
        sudo rm -f /etc/apt/sources.list.d/1password.list
        sudo rm -f /usr/share/keyrings/1password-archive-keyring.gpg
        track_uninstalled "1Password"
    fi
}

uninstall_orca_slicer() {
    if [ "$PLATFORM" = "macos" ]; then
        brew uninstall --cask orca-slicer >> /tmp/app_install.log 2>&1
        track_uninstalled "Orca Slicer"
    elif [ -f ~/.local/bin/orca-slicer.AppImage ]; then
        rm -f ~/.local/bin/orca-slicer.AppImage
        rm -f ~/.local/share/applications/orca-slicer.desktop
        rm -f ~/.local/share/icons/hicolor/256x256/apps/orca-slicer.png
        track_uninstalled "Orca Slicer"
    fi
}

################################################################################
# Main
################################################################################

main() {
    > /tmp/app_install.log

    log_section "Application Manager ($PLATFORM)"
    log_info "Installation log: /tmp/app_install.log"
    echo

    local non_interactive_flag=""
    for arg in "$@"; do
        if [ "$arg" = "--non-interactive" ]; then
            non_interactive_flag="--non-interactive"
            log_info "Running in non-interactive mode"
        fi
    done

    echo "DEBUG: Starting unified app manager for $PLATFORM" >> /tmp/app_install.log

    if [ -z "$non_interactive_flag" ]; then
        if [ "$PLATFORM" = "linux" ] || [ "$PLATFORM" = "wsl" ]; then
            if ! command_exists whiptail; then
                log_info "Installing whiptail for interactive menu..."
                sudo apt-get update >> /tmp/app_install.log 2>&1
                sudo apt-get install -y whiptail >> /tmp/app_install.log 2>&1
            fi
        fi
        # macOS has dialog/whiptail via brew or system sometimes, but assume present or skip if not critical
    fi

    # Show unified selection menu
    selections=$(select_applications $non_interactive_flag)

    # Install selected applications
    for app in $selections; do
        app=$(echo "$app" | tr -d '"')
        if [ -z "$app" ]; then continue; fi

        log_section "Installing $(echo $app | tr '_' ' ' | sed 's/\b\(.\)/\u\1/g')"
        install_"$app" || true
        echo
    done

    show_dashboard
    
    # Return exit code based on failures
    if [ ${#FAILED_APPS[@]} -gt 0 ]; then
        exit 2  # Exit 2 = some apps failed (not user cancel)
    fi
    exit 0
}

main "$@"