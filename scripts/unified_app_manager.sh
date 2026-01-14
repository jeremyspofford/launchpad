#!/usr/bin/env bash
# Unified Application Manager
# Handles installation/uninstallation of all applications (system, CLI, GUI)

set -uo pipefail

################################################################################
# Load logger functions
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/logger.sh"

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
    local onepassword_status="OFF"
    local orca_slicer_status="OFF"

    # Pre-check if installed OR if config says to install
    (command_exists zsh || [ "$INSTALL_ZSH" = "true" ]) && zsh_status="ON"
    (command_exists tmux || [ "$INSTALL_TMUX" = "true" ]) && tmux_status="ON"
    (command_exists nvim || [ "$INSTALL_NEOVIM" = "true" ]) && neovim_status="ON"
    (command_exists mise || [ "$INSTALL_MISE" = "true" ]) && mise_status="ON"
    (command_exists mdview || [ "$INSTALL_MDVIEW" = "true" ]) && mdview_status="ON"
    (command_exists ghostty || [ "$INSTALL_GHOSTTY" = "true" ]) && ghostty_status="ON"
    ((command_exists cursor || [ -f ~/.local/bin/cursor.AppImage ]) || [ "$INSTALL_CURSOR" = "true" ]) && cursor_status="ON"
    ((dpkg -l 2>/dev/null | grep -i antigravity | grep -qE "^[^ ]*ii") || [ "$INSTALL_ANTIGRAVITY" = "true" ]) && antigravity_status="ON"
    ((snap list 2>/dev/null | grep -q "claudeai-desktop") || [ "$INSTALL_CLAUDE_DESKTOP" = "true" ]) && claude_desktop_status="ON"
    (command_exists google-chrome || [ "$INSTALL_CHROME" = "true" ]) && chrome_status="ON"
    (command_exists code || [ "$INSTALL_VSCODE" = "true" ]) && vscode_status="ON"
    (command_exists brave-browser || [ "$INSTALL_BRAVE" = "true" ]) && brave_status="ON"
    ((snap list 2>/dev/null | grep -q "notion-snap-reborn") || [ "$INSTALL_NOTION" = "true" ]) && notion_status="ON"
    ((command_exists obsidian || snap list 2>/dev/null | grep -q "obsidian") || [ "$INSTALL_OBSIDIAN" = "true" ]) && obsidian_status="ON"
    (command_exists 1password || [ "$INSTALL_1PASSWORD" = "true" ]) && onepassword_status="ON"
    ([ -f ~/.local/bin/orca-slicer.AppImage ] || [ "$INSTALL_ORCA_SLICER" = "true" ]) && orca_slicer_status="ON"
    
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
    
    # Unified selection menu with dynamic ON/OFF based on what's installed
    local selections=$(whiptail --title "Application Manager" --checklist \
"Select applications (Space=select, Enter=confirm)

⚠️  WARNING: Unchecking installed apps will UNINSTALL them!

System Tools:" 28 78 19 \
"zsh" "Zsh shell" "$zsh_status" \
"tmux" "Terminal multiplexer" "$tmux_status" \
"neovim" "Text editor" "$neovim_status" \
"mise" "mise (installs ALL tools from config.toml)" "$mise_status" \
"mdview" "Markdown viewer (renders .md in browser)" "$mdview_status" \
"ghostty" "Ghostty terminal" "$ghostty_status" \
"cursor" "Cursor AI IDE" "$cursor_status" \
"antigravity" "Antigravity IDE (Google)" "$antigravity_status" \
"claude_desktop" "Claude Desktop" "$claude_desktop_status" \
"chrome" "Google Chrome" "$chrome_status" \
"vscode" "VS Code" "$vscode_status" \
"brave" "Brave browser" "$brave_status" \
"notion" "Notion" "$notion_status" \
"obsidian" "Obsidian (note-taking)" "$obsidian_status" \
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
                # Remove old version first
                sudo apt-get remove -y neovim >> /tmp/app_install.log 2>&1 || true
            fi
        fi
    fi
    
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
        
        # Install a Nerd Font for icons
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
                            fc-cache -fv ~/.local/share/fonts >> /tmp/app_install.log 2>&1
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
        log_info "On first nvim launch, LazyVim will install Tree-sitter parsers"
        
        track_installed "Neovim v$ppa_version (PPA)"
        return 0
    fi
    
    # Method 2: Try snap as fallback
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
            echo
            log_heredoc "${CYAN}" <<EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 Installing Tools from config.toml
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This will install ALL tools configured in:
  ~/.config/mise/config.toml

Including:
  • AWS/Terraform tools (aws-cli, terraform, etc.)
  • Languages (node, python, go, rust)
  • CLI tools (ripgrep, fd, fzf, bat, eza, jq, yq)
  • Git tools (lazygit, delta, gh)
  • AI tools (claude, gemini, aider, opencode)
  • And more...

⏱️  This may take 5-10 minutes depending on your system.

💡 TIP: To manage tools later:
   • View installed: mise list
   • Add a tool: mise use -g <tool>@latest
   • Remove a tool: 
     1. Delete from ~/.config/mise/config.toml
     2. Run: mise uninstall <tool>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
            echo
            log_info "Installing tools (this may take a while)..."
            
            if mise install >> /tmp/app_install.log 2>&1; then
                echo
                log_success "✅ Tools installed from config.toml"
                echo
                log_info "Installed tools:"
                mise list
                echo
            else
                log_warning "Some tools failed to install from config.toml"
                log_info "Check /tmp/app_install.log for details"
                log_info "You can retry with: mise install"
            fi
        else
            log_info "No config.toml found - tools will be available after stowing dotfiles"
            log_info "After stowing, run: mise install"
        fi
        
        track_installed "mise + CLI tools from config.toml"
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
    if ! command_exists npm; then
        log_warning "npm not found - install mise first or Node.js"
        track_failed "mdview" "npm not available"
        return 1
    fi
    
    log_info "Installing mdview..."
    if npm install -g mdview >> /tmp/app_install.log 2>&1; then
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
    if command_exists ghostty; then
        track_skipped "Ghostty"
        return 0
    fi
    
    if sudo snap install ghostty --edge >> /tmp/app_install.log 2>&1; then
        track_installed "Ghostty"
    else
        track_failed "Ghostty" "snap install failed"
    fi
}

install_cursor() {
    # Check both AppImage and deb installation
    if command_exists cursor || [ -f ~/.local/bin/cursor.AppImage ]; then
        track_skipped "Cursor"
        return 0
    fi
    
    local temp_deb="/tmp/cursor.deb"
    
    log_info "Downloading Cursor IDE..."
    # Use direct download URL that works
    if curl -L "https://api2.cursor.sh/updates/download/golden/linux-x64-deb/cursor/2.3" -o "$temp_deb" 2>&1 | tee -a /tmp/app_install.log; then
        # Check if it's actually a deb file
        if file "$temp_deb" | grep -q "Debian"; then
            log_info "Installing Cursor..."
            if sudo dpkg -i "$temp_deb" >> /tmp/app_install.log 2>&1; then
                sudo apt-get install -f -y >> /tmp/app_install.log 2>&1
                rm -f "$temp_deb"
                track_installed "Cursor"
            else
                rm -f "$temp_deb"
                track_failed "Cursor" "installation failed"
            fi
        else
            log_error "Downloaded file is not a valid .deb package"
            rm -f "$temp_deb"
            track_failed "Cursor" "invalid file type"
        fi
    else
        rm -f "$temp_deb"
        track_failed "Cursor" "download failed - check network"
    fi
}

install_antigravity() {
    # Check if installed (look for ii status, handling dpkg spacing)
    if dpkg -l 2>/dev/null | grep -i antigravity | grep -qE "^[^ ]*ii"; then
        track_skipped "Antigravity"
        return 0
    fi
    
    log_warning "Antigravity installation requires manual download"
    log_info "Visit: https://antigravity.google/download/linux"
    log_info "Download the .deb file and install with: sudo dpkg -i antigravity.deb"
    track_failed "Antigravity" "requires manual download from website"
}

install_claude_desktop() {
    if snap list 2>/dev/null | grep -q "claudeai-desktop"; then
        track_skipped "Claude Desktop"
        return 0
    fi
    
    if sudo snap install claudeai-desktop >> /tmp/app_install.log 2>&1; then
        track_installed "Claude Desktop"
    else
        track_failed "Claude Desktop" "snap install failed"
    fi
}

install_chrome() {
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
    if snap list 2>/dev/null | grep -q "notion-snap-reborn"; then
        track_skipped "Notion"
        return 0
    fi
    
    if sudo snap install notion-snap-reborn >> /tmp/app_install.log 2>&1; then
        track_installed "Notion"
    else
        track_failed "Notion" "snap install failed"
    fi
}

install_obsidian() {
    # Check if already installed
    if command_exists obsidian || snap list 2>/dev/null | grep -q "obsidian"; then
        track_skipped "Obsidian"
        return 0
    fi
    
    # Try snap first (easiest method)
    if command_exists snap; then
        log_info "Installing Obsidian via snap..."
        if sudo snap install obsidian --classic >> /tmp/app_install.log 2>&1; then
            track_installed "Obsidian (snap)"
            return 0
        fi
    fi
    
    # Fallback to AppImage
    log_info "Installing Obsidian AppImage..."
    mkdir -p ~/.local/bin
    
    # Get latest version from GitHub
    local latest_url=$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest 2>/dev/null | grep "browser_download_url.*AppImage" | cut -d '"' -f 4)
    
    if [ -n "$latest_url" ] && curl -L "$latest_url" -o ~/.local/bin/obsidian.AppImage >> /tmp/app_install.log 2>&1; then
        chmod +x ~/.local/bin/obsidian.AppImage
        
        # Create wrapper script
        cat > ~/.local/bin/obsidian << 'EOF'
#!/bin/bash
exec ~/.local/bin/obsidian.AppImage "$@"
EOF
        chmod +x ~/.local/bin/obsidian
        
        # Create desktop entry
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

install_1password() {
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
    if [ -f ~/.local/bin/orca-slicer.AppImage ]; then
        track_skipped "Orca Slicer"
        return 0
    fi
    
    mkdir -p ~/.local/bin

    log_info "Fetching latest Orca Slicer release info..."
    # Get latest release URL from GitHub API (repo moved to OrcaSlicer org)
    local url=$(curl -s https://api.github.com/repos/OrcaSlicer/OrcaSlicer/releases/latest 2>/dev/null | \
        grep '"browser_download_url"' | \
        grep -i "linux.*appimage.*ubuntu" | \
        head -1 | \
        cut -d '"' -f 4)

    if [ -z "$url" ]; then
        log_error "Could not fetch latest Orca Slicer download URL"
        track_failed "Orca Slicer" "failed to fetch download URL from GitHub"
        return
    fi

    log_info "Downloading Orca Slicer from: $url"
    log_info "This is a large file (~200MB), please wait..."

    if curl -L "$url" -o ~/.local/bin/orca-slicer.AppImage 2>&1 | tee -a /tmp/app_install.log; then
        # Verify it downloaded something substantial (AppImage should be >100MB)
        local filesize=$(stat -c%s ~/.local/bin/orca-slicer.AppImage 2>/dev/null || echo "0")
        if [ "$filesize" -gt 100000000 ]; then
            chmod +x ~/.local/bin/orca-slicer.AppImage

            # Download and install icon
            log_info "Installing Orca Slicer icon..."
            mkdir -p "$HOME/.local/share/icons/hicolor/256x256/apps"
            if curl -sL "https://raw.githubusercontent.com/OrcaSlicer/OrcaSlicer/main/resources/images/OrcaSlicer_192px.png" \
                -o "$HOME/.local/share/icons/hicolor/256x256/apps/orca-slicer.png" >> /tmp/app_install.log 2>&1; then
                log_info "Icon installed successfully"
            else
                log_warning "Could not download icon, using default"
            fi

            # Create desktop entry
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

            # Update desktop database if available
            if command_exists update-desktop-database; then
                update-desktop-database "$HOME/.local/share/applications/" 2>/dev/null || true
            fi

            track_installed "Orca Slicer"
        else
            log_error "Downloaded file is too small to be valid AppImage (${filesize} bytes)"
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
    if command_exists zsh; then
        sudo apt-get remove -y zsh >> /tmp/app_install.log 2>&1
        track_uninstalled "Zsh"
    fi
}

uninstall_tmux() {
    if command_exists tmux; then
        sudo apt-get remove -y tmux >> /tmp/app_install.log 2>&1
        track_uninstalled "Tmux"
    fi
}

uninstall_neovim() {
    local uninstalled=false
    
    # Check for AppImage version
    if [ -f ~/.local/bin/nvim.appimage ]; then
        rm -f ~/.local/bin/nvim.appimage
        rm -f ~/.local/bin/nvim
        log_info "Removed Neovim AppImage"
        uninstalled=true
    fi
    
    # Check if installed via snap
    if snap list 2>/dev/null | grep -q "nvim"; then
        sudo snap remove nvim >> /tmp/app_install.log 2>&1
        log_info "Removed Neovim snap"
        uninstalled=true
    fi
    
    # Check if installed via apt
    if command_exists nvim && ! [ -f ~/.local/bin/nvim.appimage ]; then
        sudo apt-get remove -y neovim >> /tmp/app_install.log 2>&1
        # Remove PPA if it was added
        sudo add-apt-repository -y --remove ppa:neovim-ppa/unstable >> /tmp/app_install.log 2>&1 || true
        log_info "Removed Neovim apt package"
        uninstalled=true
    fi
    
    if [ "$uninstalled" = true ]; then
        track_uninstalled "Neovim"
    fi
}

uninstall_mise() {
    if command_exists mise; then
        log_warning "Removing mise will remove ALL tools installed via mise"
        # User should manually uninstall if needed
        track_uninstalled "mise (manual cleanup recommended)"
    fi
}

uninstall_mdview() {
    if command_exists mdview; then
        npm uninstall -g mdview >> /tmp/app_install.log 2>&1
        track_uninstalled "mdview"
    fi
}

################################################################################
# GUI App Uninstall Functions
################################################################################

uninstall_ghostty() {
    if command_exists ghostty; then
        sudo snap remove ghostty >> /tmp/app_install.log 2>&1
        track_uninstalled "Ghostty"
    fi
}

uninstall_cursor() {
    if [ -f ~/.local/bin/cursor.AppImage ]; then
        rm -f ~/.local/bin/cursor.AppImage
        rm -f ~/.local/share/applications/cursor.desktop
        track_uninstalled "Cursor"
    fi
}

uninstall_antigravity() {
    if dpkg -l | grep -q antigravity; then
        sudo apt-get remove -y antigravity >> /tmp/app_install.log 2>&1
        track_uninstalled "Antigravity"
    fi
}

uninstall_claude_desktop() {
    if snap list 2>/dev/null | grep -q "claudeai-desktop"; then
        sudo snap remove claudeai-desktop >> /tmp/app_install.log 2>&1
        track_uninstalled "Claude Desktop"
    fi
}

uninstall_chrome() {
    if command_exists google-chrome; then
        sudo apt-get remove -y google-chrome-stable >> /tmp/app_install.log 2>&1
        track_uninstalled "Google Chrome"
    fi
}


uninstall_obsidian() {
    local uninstalled=false

    # Check for snap version
    if snap list 2>/dev/null | grep -q "obsidian"; then
        sudo snap remove obsidian >> /tmp/app_install.log 2>&1
        log_info "Removed Obsidian snap"
        uninstalled=true
    fi

    # Check for AppImage version
    if [ -f ~/.local/bin/obsidian.AppImage ]; then
        rm -f ~/.local/bin/obsidian.AppImage
        rm -f ~/.local/bin/obsidian
        rm -f ~/.local/share/applications/obsidian.desktop
        log_info "Removed Obsidian AppImage"
        uninstalled=true
    fi

    if [ "$uninstalled" = true ]; then
        track_uninstalled "Obsidian"
    fi
}

uninstall_vscode() {
    if command_exists code; then
        sudo apt-get remove -y code >> /tmp/app_install.log 2>&1
        sudo rm -f /etc/apt/sources.list.d/vscode.list
        sudo rm -f /etc/apt/keyrings/packages.microsoft.gpg
        track_uninstalled "VS Code"
    fi
}

uninstall_brave() {
    if command_exists brave-browser; then
        sudo apt-get remove -y brave-browser >> /tmp/app_install.log 2>&1
        sudo rm -f /etc/apt/sources.list.d/brave-browser-release.list
        sudo rm -f /usr/share/keyrings/brave-browser-archive-keyring.gpg
        track_uninstalled "Brave Browser"
    fi
}

uninstall_notion() {
    if snap list 2>/dev/null | grep -q "notion-snap-reborn"; then
        sudo snap remove notion-snap-reborn >> /tmp/app_install.log 2>&1
        track_uninstalled "Notion"
    fi
}

uninstall_1password() {
    if command_exists 1password; then
        sudo apt-get remove -y 1password >> /tmp/app_install.log 2>&1
        sudo rm -f /etc/apt/sources.list.d/1password.list
        sudo rm -f /usr/share/keyrings/1password-archive-keyring.gpg
        track_uninstalled "1Password"
    fi
}

uninstall_orca_slicer() {
    if [ -f ~/.local/bin/orca-slicer.AppImage ]; then
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

    log_section "Application Manager"
    log_info "Installation log: /tmp/app_install.log"
    echo

    # Parse arguments to check for non-interactive mode
    local non_interactive_flag=""
    for arg in "$@"; do
        if [ "$arg" = "--non-interactive" ]; then
            non_interactive_flag="--non-interactive"
            log_info "Running in non-interactive mode"
        fi
    done

    # Debug: Log start
    echo "DEBUG: Starting unified app manager" >> /tmp/app_install.log

    # Only check for whiptail in interactive mode
    if [ -z "$non_interactive_flag" ]; then
        # Ensure whiptail is available
        if ! command_exists whiptail; then
            log_info "Installing whiptail for interactive menu..."
            sudo apt-get update >> /tmp/app_install.log 2>&1
            sudo apt-get install -y whiptail >> /tmp/app_install.log 2>&1

            if ! command_exists whiptail; then
                log_error "Failed to install whiptail - cannot show interactive menu"
                log_info "Please install whiptail manually: sudo apt-get install whiptail"
                exit 1
            fi
        fi

        echo "DEBUG: whiptail is available" >> /tmp/app_install.log
    fi

    echo "DEBUG: About to call select_applications" >> /tmp/app_install.log

    # Show unified selection menu (pass flag if present)
    selections=$(select_applications $non_interactive_flag)

    echo "DEBUG: Returned from select_applications" >> /tmp/app_install.log
    echo "DEBUG: Selections = $selections" >> /tmp/app_install.log

    # Install selected applications
    for app in $selections; do
        app=$(echo "$app" | tr -d '"')

        # Skip empty entries (from separator lines)
        if [ -z "$app" ]; then
            continue
        fi

        log_section "Installing $(echo $app | tr '_' ' ' | sed 's/\b\(.\)/\u\1/g')"
        install_"$app" || true
        echo
    done

    # Show dashboard
    show_dashboard
}

main "$@"
