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
    log_info "🗑️  Uninstalled"
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
    
    echo
}

################################################################################
# Unified Application Selection
################################################################################

select_applications() {
    if ! command_exists whiptail; then
        sudo apt-get install -y whiptail >> /tmp/app_install.log 2>&1
    fi
    
    # Load previous selections
    local previous=""
    if [ -f ~/.config/dotfiles/app-selections ]; then
        previous=$(cat ~/.config/dotfiles/app-selections)
    fi
    
    # Show warning if re-running
    if [ -n "$previous" ]; then
        whiptail --title "⚠️  IMPORTANT WARNING" --msgbox \
"You have previously installed applications.

⚠️  UNCHECKING = UNINSTALL

Unchecked applications will be REMOVED from your system.

Press OK to continue..." 12 60
    fi
    
    # Unified selection menu
    local selections=$(whiptail --title "Application Manager" --checklist \
"Select applications to install (Space=select, Enter=confirm)

System Tools:" 30 78 20 \
"zsh" "Zsh shell" ON \
"tmux" "Terminal multiplexer" ON \
"neovim" "Text editor" ON \
"" "" OFF \
"mise" "mise - Runtime manager (installs CLI tools from mise.toml)" ON \
"" "" OFF \
"ghostty" "Ghostty terminal" ON \
"cursor" "Cursor AI IDE" ON \
"claude_desktop" "Claude Desktop" ON \
"chrome" "Google Chrome" ON \
"docker_desktop" "Docker Desktop" ON \
"" "" OFF \
"vscode" "VS Code" OFF \
"brave" "Brave browser" OFF \
"notion" "Notion" OFF \
"1password" "1Password" OFF \
"orca_slicer" "Orca Slicer" OFF \
3>&1 1>&2 2>&3)
    
    if [ $? -ne 0 ]; then
        log_error "Selection cancelled"
        exit 1
    fi
    
    # Handle uninstalls
    if [ -n "$previous" ]; then
        for prev_app in $previous; do
            prev_app=$(echo "$prev_app" | tr -d '"')
            if [ -z "$prev_app" ]; then continue; fi
            
            if ! echo "$selections" | grep -q "$prev_app"; then
                log_section "Uninstalling $(echo $prev_app | tr '_' ' ' | sed 's/\b\(.\)/\u\1/g')"
                uninstall_"$prev_app" 2>/dev/null || log_warning "No uninstall function"
                echo
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
    if command_exists nvim; then
        track_skipped "Neovim"
        return 0
    fi
    
    if sudo apt-get install -y neovim >> /tmp/app_install.log 2>&1; then
        track_installed "Neovim"
    else
        track_failed "Neovim" "apt install failed"
    fi
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
        
        # Install tools from mise.toml if it exists
        if [ -f ~/.config/mise/mise.toml ]; then
            log_info "Installing tools from mise.toml..."
            log_warning "This may take a few minutes..."
            
            if mise install >> /tmp/app_install.log 2>&1; then
                log_success "✅ Tools installed from mise.toml"
                log_info "Installed tools:"
                mise list
            else
                log_warning "Some tools failed to install from mise.toml"
                log_info "Check /tmp/app_install.log for details"
            fi
        else
            log_info "No mise.toml found - tools will be available after stowing dotfiles"
        fi
        
        track_installed "mise + CLI tools from mise.toml"
    else
        track_failed "mise" "install script failed"
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
    if [ -f ~/.local/bin/cursor.AppImage ]; then
        track_skipped "Cursor"
        return 0
    fi
    
    mkdir -p ~/.local/bin
    if curl -L "https://downloader.cursor.sh/linux/appImage/x64" -o ~/.local/bin/cursor.AppImage >> /tmp/app_install.log 2>&1; then
        chmod +x ~/.local/bin/cursor.AppImage
        track_installed "Cursor"
    else
        track_failed "Cursor" "download failed"
    fi
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

install_docker_desktop() {
    if dpkg -l | grep -q docker-desktop; then
        track_skipped "Docker Desktop"
        return 0
    fi
    
    wget -q https://desktop.docker.com/linux/main/amd64/docker-desktop-latest-amd64.deb -O /tmp/docker.deb >> /tmp/app_install.log 2>&1
    if sudo dpkg -i /tmp/docker.deb >> /tmp/app_install.log 2>&1; then
        sudo apt-get install -f -y >> /tmp/app_install.log 2>&1
        rm -f /tmp/docker.deb
        track_installed "Docker Desktop"
    else
        rm -f /tmp/docker.deb
        track_failed "Docker Desktop" "installation failed"
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
    local url=$(curl -s https://api.github.com/repos/SoftFever/OrcaSlicer/releases/latest 2>/dev/null | grep "browser_download_url.*AppImage" | head -1 | cut -d '"' -f 4)
    
    if [ -n "$url" ] && curl -L "$url" -o ~/.local/bin/orca-slicer.AppImage >> /tmp/app_install.log 2>&1; then
        chmod +x ~/.local/bin/orca-slicer.AppImage
        track_installed "Orca Slicer"
    else
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
    if command_exists nvim; then
        sudo apt-get remove -y neovim >> /tmp/app_install.log 2>&1
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

uninstall_docker_desktop() {
    if dpkg -l | grep -q docker-desktop; then
        sudo apt-get remove -y docker-desktop >> /tmp/app_install.log 2>&1
        track_uninstalled "Docker Desktop"
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
    
    # Show unified selection menu
    selections=$(select_applications)
    
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
