# GEMINI: Modern Dotfiles Analysis

## Directory Overview

This directory is a comprehensive, cross-platform dotfiles repository. Its primary purpose is to automate the setup and configuration of a consistent development environment across macOS, Linux, and Windows Subsystem for Linux (WSL).

The setup is managed by a series of shell scripts that handle everything from system updates and application installation to symlinking configuration files. It uses GNU Stow for managing the dotfiles, `mise` for managing command-line tool versions, and provides a robust backup and restore mechanism.

## Key Files and Directories

*   `scripts/bootstrap.sh`: The main entry point for a new machine. It clones the repository and executes the main setup script. It's designed to be run with a single `curl` command.
*   `scripts/setup.sh`: The core script of the repository. It is idempotent and can be run multiple times. It handles:
    *   Platform detection (macOS, Linux, WSL).
    *   System package installation and updates.
    *   Backing up existing dotfiles to `~/.dotfiles-backup`.
    *   Symlinking configurations from the `home/` directory using GNU Stow.
    *   Installation of applications like Zsh, Neovim, tmux, and various CLI/GUI tools.
    *   It supports flags like `--update`, `--minimal`, and `--revert`.
*   `home/`: This directory mirrors the user's home (`~`) directory. It contains all the configuration files (dotfiles) that will be symlinked into place. This includes configurations for Zsh (`.zshrc`), Git (`.gitconfig`), Neovim (`.config/nvim/`), tmux (`.tmux.conf`), and more.
*   `docs/`: Contains supplementary documentation, including a detailed `USAGE.md` guide and cheatsheets for various tools.
*   `templates/`: Holds reusable components, such as a logger script and a Terraform formatter setup, which can be copied into other projects.
*   `home/.config/mise/mise.toml.template`: Defines the command-line tools to be installed and managed by `mise`, ensuring consistent versions across all systems.

## Usage and Workflows

This repository is designed to be highly automated and easy to use. Here are the primary workflows:

### First-Time Setup

For a new machine, the entire setup process can be initiated with a single command. This will clone the repository to `~/workspace/dotfiles` and run the interactive setup script.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/jeremyspofford/dotfiles/main/scripts/bootstrap.sh)
```

### Updating an Existing Setup

After pulling changes from the Git repository, you can update your local setup by running the `setup.sh` script with the `--update` flag. This will re-symlink the dotfiles without re-installing all the packages.

```bash
cd ~/workspace/dotfiles
git pull
./scripts/setup.sh --update
```

### Customization

The repository is designed to be personalized without modifying tracked files. This is achieved through `.template` files.

*   **Secrets:** For API keys and other sensitive information, copy the template and edit the new file:
    ```bash
    cp ~/.secrets.template ~/.secrets
    vim ~/.secrets
    ```
*   **Git Identity:** To configure your Git user name and email:
    ```bash
    cp ~/.config/git/identity.gitconfig.template ~/.config/git/identity.gitconfig
    vim ~/.config/git/identity.gitconfig
    ```
*   **Local Shell Overrides:** For machine-specific shell settings:
    ```bash
    cp ~/.zshrc.local.template ~/.zshrc.local
    vim ~/.zshrc.local
    ```

### Reverting Changes

The setup script automatically backs up any existing dotfiles before creating symlinks. You can revert to your previous configuration using the `--revert` flag.

```bash
cd ~/workspace/dotfiles
./scripts/setup.sh --revert
```

## Development Conventions

*   **Tool Version Management:** The `mise` tool is used to manage versions of command-line tools. New tools should be added to the `home/.config/mise/mise.toml.template` file.
*   **Configuration Management:** All dotfiles are managed via GNU Stow. To add a new configuration, place the file in the `home/` directory in its corresponding location, and `stow` will handle the symlinking.
*   **Idempotency:** The setup scripts are designed to be idempotent, meaning they can be run multiple times without causing issues. Any new scripts or modifications should follow this principle.
*   **Cross-Platform Compatibility:** Changes should be compatible with macOS, Linux (Debian/Ubuntu), and WSL. The scripts use platform detection to handle any necessary differences.
