#!/usr/bin/env bash

################################################################################
# Configuration Management
# Handles loading and prompting for user configuration
################################################################################

# Configuration file path
CONFIG_FILE="${DOTFILES_DIR}/.config"
CONFIG_TEMPLATE="${DOTFILES_DIR}/.config.template"

################################################################################
# Load configuration
################################################################################

load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        log_info "Loaded configuration from .config"
        return 0
    else
        log_warning "Configuration file not found: $CONFIG_FILE"
        return 1
    fi
}

################################################################################
# Create configuration from template
################################################################################

create_config_from_template() {
    if [ ! -f "$CONFIG_TEMPLATE" ]; then
        log_error "Configuration template not found: $CONFIG_TEMPLATE"
        return 1
    fi

    if [ -f "$CONFIG_FILE" ]; then
        log_info "Configuration already exists at $CONFIG_FILE"
        return 0
    fi

    log_section "Initial Configuration"

    log_info "Creating configuration file..."
    log_info "You can customize these settings later by editing: $CONFIG_FILE"
    echo

    # Copy template
    cp "$CONFIG_TEMPLATE" "$CONFIG_FILE"

    log_success "✅ Configuration file created: $CONFIG_FILE"
    return 0
}

################################################################################
# Prompt for configuration values
################################################################################

prompt_for_config() {
    log_section "Configuration Setup"

    log_heredoc "${CYAN}" <<EOF
Let's set up your personal configuration.
These settings will be used throughout your dotfiles.

You can skip this and edit .config manually later, or
provide answers now for automatic configuration.
EOF

    echo

    # Ask if user wants interactive setup
    if [ "$SKIP_INTERACTIVE" = true ]; then
        log_info "Non-interactive mode - using defaults from template"
        create_config_from_template
        return 0
    fi

    if whiptail --title "Configuration Setup" --yesno "Would you like to configure your settings now?\n\nYou can also skip this and edit .config manually later." 12 70 3>&1 1>&2 2>&3; then
        interactive_config_setup
    else
        log_info "Skipping interactive configuration"
        create_config_from_template
        log_warning "Remember to edit $CONFIG_FILE with your personal settings!"
    fi
}

################################################################################
# Interactive configuration setup
################################################################################

interactive_config_setup() {
    # Copy template first
    create_config_from_template

    log_info "Configuring essential settings..."
    echo

    # Git user name
    local git_name
    git_name=$(whiptail --title "Git Configuration" --inputbox "Enter your full name for Git commits:" 10 70 "$(git config --global user.name 2>/dev/null || echo '')" 3>&1 1>&2 2>&3)
    if [ -n "$git_name" ]; then
        sed -i "s/^GIT_USER_NAME=.*/GIT_USER_NAME=\"$git_name\"/" "$CONFIG_FILE"
    fi

    # Git user email
    local git_email
    git_email=$(whiptail --title "Git Configuration" --inputbox "Enter your email for Git commits:" 10 70 "$(git config --global user.email 2>/dev/null || echo '')" 3>&1 1>&2 2>&3)
    if [ -n "$git_email" ]; then
        sed -i "s/^GIT_USER_EMAIL=.*/GIT_USER_EMAIL=\"$git_email\"/" "$CONFIG_FILE"
    fi

    # Ask about GitHub noreply email
    if whiptail --title "Privacy" --yesno "Would you like to use GitHub's noreply email?\n\nThis hides your real email address in commits.\nFormat: USERNAME@users.noreply.github.com" 12 70 3>&1 1>&2 2>&3; then
        sed -i 's/^USE_GITHUB_NOREPLY=.*/USE_GITHUB_NOREPLY="true"/' "$CONFIG_FILE"
    else
        sed -i 's/^USE_GITHUB_NOREPLY=.*/USE_GITHUB_NOREPLY="false"/' "$CONFIG_FILE"
    fi

    # Preferred editor
    local editor_choice
    editor_choice=$(whiptail --title "Editor Preference" --menu "Choose your preferred text editor:" 15 70 4 \
        "nvim" "Neovim (modern, powerful)" \
        "cursor" "Cursor (AI-powered IDE)" \
        "vscode" "VS Code" \
        "vim" "Vim (classic)" \
        3>&1 1>&2 2>&3)
    if [ -n "$editor_choice" ]; then
        sed -i "s/^PREFERRED_EDITOR=.*/PREFERRED_EDITOR=\"$editor_choice\"/" "$CONFIG_FILE"
    fi

    # Shell preference
    if whiptail --title "Shell Preference" --yesno "Use Zsh as your default shell?\n\nZsh is modern, powerful, and works great with Oh My Zsh.\n\nSelect 'No' to keep Bash." 12 70 3>&1 1>&2 2>&3; then
        sed -i 's/^DEFAULT_SHELL=.*/DEFAULT_SHELL="zsh"/' "$CONFIG_FILE"
    else
        sed -i 's/^DEFAULT_SHELL=.*/DEFAULT_SHELL="bash"/' "$CONFIG_FILE"
    fi

    echo
    log_success "✅ Configuration updated: $CONFIG_FILE"
    log_info "You can edit this file anytime to change your preferences"
}

################################################################################
# Apply configuration
################################################################################

apply_git_config() {
    if ! load_config; then
        log_warning "No configuration loaded, skipping git setup"
        return 1
    fi

    log_section "Applying Git Configuration"

    # Set user name
    if [ -n "$GIT_USER_NAME" ] && [ "$GIT_USER_NAME" != "Your Name" ]; then
        git config --global user.name "$GIT_USER_NAME"
        log_info "Set git user.name: $GIT_USER_NAME"
    fi

    # Set user email
    if [ -n "$GIT_USER_EMAIL" ] && [ "$GIT_USER_EMAIL" != "your.email@example.com" ]; then
        git config --global user.email "$GIT_USER_EMAIL"
        log_info "Set git user.email: $GIT_USER_EMAIL"
    fi

    # Configure signing if enabled
    if [ "$ENABLE_GIT_SIGNING" = "true" ]; then
        case "$GIT_SIGNING" in
            gpg)
                if [ -n "$GIT_GPG_KEY" ]; then
                    git config --global user.signingkey "$GIT_GPG_KEY"
                    git config --global commit.gpgsign true
                    log_info "Enabled GPG signing with key: $GIT_GPG_KEY"
                fi
                ;;
            ssh)
                if [ -n "$GIT_SSH_KEY" ] && [ -f "$GIT_SSH_KEY" ]; then
                    git config --global user.signingkey "$GIT_SSH_KEY"
                    git config --global gpg.format ssh
                    git config --global commit.gpgsign true
                    log_info "Enabled SSH signing with key: $GIT_SSH_KEY"
                fi
                ;;
        esac
    fi

    log_success "✅ Git configuration applied"
    echo
}

################################################################################
# Generate SSH key if requested
################################################################################

setup_ssh_key() {
    if ! load_config; then
        return 1
    fi

    if [ "$SSH_GENERATE_KEY" != "true" ]; then
        return 0
    fi

    log_section "SSH Key Setup"

    local key_path="$HOME/.ssh/id_${SSH_KEY_TYPE}"

    if [ -f "$key_path" ]; then
        log_info "SSH key already exists: $key_path"
        return 0
    fi

    log_info "Generating $SSH_KEY_TYPE SSH key..."

    case "$SSH_KEY_TYPE" in
        ed25519)
            ssh-keygen -t ed25519 -C "$SSH_KEY_COMMENT" -f "$key_path" -N ""
            ;;
        rsa)
            ssh-keygen -t rsa -b 4096 -C "$SSH_KEY_COMMENT" -f "$key_path" -N ""
            ;;
    esac

    if [ -f "$key_path" ]; then
        log_success "✅ SSH key generated: $key_path"
        log_info "Public key:"
        cat "${key_path}.pub"
        echo
        log_warning "Add this public key to your Git hosting service (GitHub, GitLab, etc.)"
    else
        log_error "Failed to generate SSH key"
    fi

    echo
}

################################################################################
# Show configuration summary
################################################################################

show_config_summary() {
    if ! load_config; then
        return 1
    fi

    log_section "Configuration Summary"

    echo "Your current configuration:"
    echo
    log_kv "Git Name" "${GIT_USER_NAME}"
    log_kv "Git Email" "${GIT_USER_EMAIL}"
    log_kv "Editor" "${PREFERRED_EDITOR}"
    log_kv "Shell" "${DEFAULT_SHELL}"
    log_kv "Terminal" "${PREFERRED_TERMINAL}"
    log_kv "Color Scheme" "${COLOR_SCHEME}"
    echo
    log_info "Edit configuration: $CONFIG_FILE"
    echo
}
