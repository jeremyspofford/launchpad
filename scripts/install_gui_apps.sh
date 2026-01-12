#!/usr/bin/env bash
# GUI Applications Installer with Error Tracking and Dashboard
# Installs desktop applications based on user selection

set -uo pipefail  # Note: removed -e so errors don't stop execution

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

track_installed() {
    INSTALLED_APPS+=("$1")
    log_success "✅ $1"
}

track_failed() {
    FAILED_APPS+=("$1: $2")
    log_error "❌ $1 - $2"
}

track_skipped() {
    SKIPPED_APPS+=("$1")
    log_info "⏭️  $1 (already installed)"
}

################################################################################
# Show Final Dashboard
################################################################################

show_dashboard() {
    echo
    echo
    log_heredoc "${CYAN}" <<EOF
╔══════════════════════════════════════════════════════════════╗
║                    INSTALLATION DASHBOARD                     ║
╚══════════════════════════════════════════════════════════════╝
EOF
    
    echo
    local total=$((${#INSTALLED_APPS[@]} + ${#FAILED_APPS[@]} + ${#SKIPPED_APPS[@]}))
    
    log_kv "Total Applications" "$total"
    log_kv "Successfully Installed" "${GREEN}${#INSTALLED_APPS[@]}${NC}"
    log_kv "Already Installed" "${YELLOW}${#SKIPPED_APPS[@]}${NC}"
    log_kv "Failed" "${RED}${#FAILED_APPS[@]}${NC}"
    
    echo
    log_heredoc "${CYAN}" <<EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    echo
    
    # Successfully Installed
    if [ ${#INSTALLED_APPS[@]} -gt 0 ]; then
        log_heredoc "${GREEN}" <<EOF
✅ SUCCESSFULLY INSTALLED (${#INSTALLED_APPS[@]}):
EOF
        for app in "${INSTALLED_APPS[@]}"; do
            log_info "   • $app"
        done
        echo
    fi
    
    # Skipped (Already Installed)
    if [ ${#SKIPPED_APPS[@]} -gt 0 ]; then
        log_heredoc "${YELLOW}" <<EOF
⏭️  ALREADY INSTALLED (${#SKIPPED_APPS[@]}):
EOF
        for app in "${SKIPPED_APPS[@]}"; do
            log_info "   • $app"
        done
        echo
    fi
    
    # Failed Installations
    if [ ${#FAILED_APPS[@]} -gt 0 ]; then
        log_heredoc "${RED}" <<EOF
❌ FAILED TO INSTALL (${#FAILED_APPS[@]}):
EOF
        for app in "${FAILED_APPS[@]}"; do
            log_info "   • $app"
        done
        echo
        log_warning "⚠️  Check /tmp/gui_install.log for detailed error messages"
        echo
    fi
    
    log_heredoc "${CYAN}" <<EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    echo
    
    # Final Status
    if [ ${#FAILED_APPS[@]} -eq 0 ]; then
        log_success "🎉 All selected applications completed successfully!"
    else
        log_warning "⚠️  ${#FAILED_APPS[@]} application(s) failed to install"
        log_info "Review /tmp/gui_install.log for details"
    fi
    
    echo
}

################################################################################
# Installation Functions (with error handling)
################################################################################

install_ghostty() {
    if command_exists ghostty; then
        track_skipped "Ghostty"
        return 0
    fi
    
    if sudo snap install ghostty --edge >> /tmp/gui_install.log 2>&1; then
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
    if curl -L "https://downloader.cursor.sh/linux/appImage/x64" -o ~/.local/bin/cursor.AppImage >> /tmp/gui_install.log 2>&1; then
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
    
    if sudo snap install claudeai-desktop >> /tmp/gui_install.log 2>&1; then
        track_installed "Claude Desktop (unofficial)"
    else
        track_failed "Claude Desktop" "snap install failed"
    fi
}

install_claude_code() {
    if command_exists claude-code; then
        track_skipped "Claude Code"
        return 0
    fi
    
    if npm install -g @anthropic-ai/claude-code >> /tmp/gui_install.log 2>&1; then
        track_installed "Claude Code"
    else
        track_failed "Claude Code" "npm install failed"
    fi
}

install_chrome() {
    if command_exists google-chrome; then
        track_skipped "Google Chrome"
        return 0
    fi
    
    wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb >> /tmp/gui_install.log 2>&1
    if sudo dpkg -i /tmp/chrome.deb >> /tmp/gui_install.log 2>&1; then
        sudo apt-get install -f -y >> /tmp/gui_install.log 2>&1
        rm -f /tmp/chrome.deb
        track_installed "Google Chrome"
    else
        rm -f /tmp/chrome.deb
        track_failed "Google Chrome" "installation failed"
    fi
}

install_docker_desktop() {
    if command_exists docker && dpkg -l | grep -q docker-desktop; then
        track_skipped "Docker Desktop"
        return 0
    fi
    
    wget -q https://desktop.docker.com/linux/main/amd64/docker-desktop-latest-amd64.deb -O /tmp/docker.deb >> /tmp/gui_install.log 2>&1
    if sudo dpkg -i /tmp/docker.deb >> /tmp/gui_install.log 2>&1; then
        sudo apt-get install -f -y >> /tmp/gui_install.log 2>&1
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
    
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /tmp/packages.microsoft.gpg 2>> /tmp/gui_install.log
    sudo install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg >> /tmp/gui_install.log 2>&1
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    rm -f /tmp/packages.microsoft.gpg
    
    sudo apt-get update >> /tmp/gui_install.log 2>&1
    if sudo apt-get install -y code >> /tmp/gui_install.log 2>&1; then
        track_installed "VS Code"
    else
        track_failed "VS Code" "installation failed"
    fi
}

install_opencode() {
    if mise list 2>/dev/null | grep -q "opencode"; then
        track_skipped "OpenCode"
        return 0
    fi
    
    if command_exists mise && mise use -g "npm:@opencode/cli@latest" >> /tmp/gui_install.log 2>&1; then
        track_installed "OpenCode"
    else
        track_failed "OpenCode" "mise install failed"
    fi
}

install_ollama() {
    if command_exists ollama; then
        track_skipped "Ollama"
        return 0
    fi
    
    if curl -fsSL https://ollama.com/install.sh | sh >> /tmp/gui_install.log 2>&1; then
        track_installed "Ollama"
    else
        track_failed "Ollama" "installation failed"
    fi
}

install_brave() {
    if command_exists brave-browser; then
        track_skipped "Brave"
        return 0
    fi
    
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg >> /tmp/gui_install.log 2>&1
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    sudo apt-get update >> /tmp/gui_install.log 2>&1
    if sudo apt-get install -y brave-browser >> /tmp/gui_install.log 2>&1; then
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
    
    if sudo snap install notion-snap-reborn >> /tmp/gui_install.log 2>&1; then
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
    
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg >> /tmp/gui_install.log 2>&1
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | sudo tee /etc/apt/sources.list.d/1password.list
    
    sudo apt-get update >> /tmp/gui_install.log 2>&1
    if sudo apt-get install -y 1password >> /tmp/gui_install.log 2>&1; then
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
    orca_url=$(curl -s https://api.github.com/repos/SoftFever/OrcaSlicer/releases/latest 2>/dev/null | grep "browser_download_url.*AppImage" | head -1 | cut -d '"' -f 4)
    
    if [ -n "$orca_url" ] && curl -L "$orca_url" -o ~/.local/bin/orca-slicer.AppImage >> /tmp/gui_install.log 2>&1; then
        chmod +x ~/.local/bin/orca-slicer.AppImage
        track_installed "Orca Slicer"
    else
        track_failed "Orca Slicer" "download failed"
    fi
}

################################################################################
# Interactive Selection
################################################################################

select_applications() {
    if ! command_exists whiptail; then
        sudo apt-get install -y whiptail >> /tmp/gui_install.log 2>&1
    fi
    
    whiptail --title "GUI Applications" --checklist \
"Select applications (Space=select, Enter=confirm):" 25 78 18 \
"ghostty" "Ghostty terminal" ON \
"cursor" "Cursor AI IDE" ON \
"claude_desktop" "Claude Desktop (unofficial)" ON \
"claude_code" "Claude Code CLI" ON \
"chrome" "Google Chrome" ON \
"docker_desktop" "Docker Desktop" ON \
"vscode" "VS Code" OFF \
"opencode" "OpenCode AI IDE" OFF \
"ollama" "Ollama local LLM" OFF \
"brave" "Brave browser" OFF \
"notion" "Notion" OFF \
"1password" "1Password" OFF \
"orca_slicer" "Orca Slicer" OFF \
3>&1 1>&2 2>&3
}

################################################################################
# Main Function
################################################################################

main() {
    > /tmp/gui_install.log
    
    log_section "GUI Applications Installer"
    log_info "Installation log: /tmp/gui_install.log"
    echo
    
    selections=$(select_applications)
    
    if [ $? -ne 0 ]; then
        log_error "Selection cancelled"
        exit 1
    fi
    
    for app in $selections; do
        app=$(echo "$app" | tr -d '"')
        log_section "Installing $(echo $app | tr '_' ' ' | sed 's/\b\(.\)/\u\1/g')"
        install_"$app" || true
        echo
    done
    
    show_dashboard
}

main "$@"
