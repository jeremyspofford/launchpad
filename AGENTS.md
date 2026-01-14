# Agent Instructions for Dotfiles Repository

This document serves as the primary reference for AI agents (Cursor, Copilot, etc.) working in this repository.

## 1. Build, Test, and Validation Commands

This is a dotfiles repository managed via GNU Stow and Bash scripts. There is no compilation "build" step, but "installation" and "validation" are the equivalents.

### Installation (Build equivalent)
*   **Full Setup:** `./scripts/setup.sh`
    *   Prompts for configuration, installs packages, and stows dotfiles.
*   **Update Dotfiles Only:** `./scripts/setup.sh --update`
    *   Restows files without reinstalling system packages.
*   **Revert/Restore:** `./scripts/setup.sh --revert`
    *   Restores from backups in `~/.dotfiles-backup/`.

### Testing and Validation
*   **Run All Validations:** `./scripts/validate-setup.sh`
    *   This script checks symlinks, shell syntax, tool availability, and permissions.
    *   **Note:** Always run this after making changes to shell scripts or dotfile structure.
*   **Running a Single Test:**
    *   The validation script does not natively support flags for single tests.
    *   To verify a specific component (e.g., just Zsh config), run the specific validation function within a subshell:
        ```bash
        source ./scripts/validate-setup.sh; validate_shell_config
        ```

### Linting
*   **Bash:** Use `shellcheck` if available.
    *   Command: `shellcheck scripts/*.sh`
*   **Python:** Use `ruff` or `flake8` for `.py` files (e.g., `scripts/aws_sso.py`).

## 2. Code Style & Conventions

### Bash Scripting (Primary Language)
*   **Shebang:** Always use `#!/usr/bin/env bash`.
*   **Safety:** Start scripts with `set -e` (or `set -euo pipefail` for stricter validation).
*   **Formatting:**
    *   Indent with **4 spaces**.
    *   Keep lines under 100 characters where possible.
    *   Use `[[ ... ]]` for conditions over `[ ... ]` when possible for safer variable handling.
*   **Naming:**
    *   **Globals/Constants:** `UPPER_CASE` (e.g., `DOTFILES_DIR`).
    *   **Functions/Locals:** `snake_case` (e.g., `install_packages`).
    *   **Private/Internal:** Prefix with underscore (e.g., `_helper_func`).
*   **Output/Logging:**
    *   Do **not** use raw `echo` for status updates.
    *   Use the logging functions from `scripts/lib/logger.sh` (if sourced) or define standard helpers (`log_info`, `log_success`, `log_error`).
    *   Example: `log_info "Installing package..."`
*   **Error Handling:**
    *   Check for command existence before execution: `if command_exists foo; then ...`.
    *   Use `track_failed` or `error_exit` functions when modifying `setup.sh`.
    *   Gracefully handle platform differences (Linux vs macOS) using `detect_platform`.

### Project Structure & Stow
*   **Source Files:** All dotfiles reside in `home/`.
*   **Target:** `home/` contents are symlinked to `~/` using GNU Stow.
*   **Conventions:**
    *   Files in `home/` should mirror the relative path in the user's home directory.
    *   Example: `home/.config/nvim/init.lua` -> `~/.config/nvim/init.lua`.
*   **Secrets:**
    *   **NEVER** commit secrets.
    *   Use `.secrets.template` and `.config.template`.
    *   Real secrets go into `.secrets` or `.config` (which are git-ignored).

### Python (Scripts)
*   Follow PEP 8.
*   Sort imports (standard lib, third party, local).
*   Use type hints where helpful.

## 3. Workflow & Best Practices

### Configuration
*   User preferences are stored in `.config` (not tracked).
*   New configuration options **must** be added to `.config.template` with a default value.
*   When adding a new tool:
    1.  Add to `scripts/unified_app_manager.sh`.
    2.  Add to `scripts/setup.sh` tool selection logic.
    3.  Update `.config.template` if it requires user configuration.

### Cross-Platform Compatibility
*   Scripts must run on **macOS**, **Linux (Debian/Ubuntu/Fedora)**, and **WSL**.
*   Always check the platform before running package manager commands (`apt`, `brew`, `dnf`).
    ```bash
    case $(detect_platform) in
        linux) sudo apt-get install ... ;;
        macos) brew install ... ;;
    esac
    ```

### Documentation
*   Update `CLAUDE.md` if high-level architectural changes are made.
*   Update `README.md` for user-facing changes.
*   If a new script is added, ensure it has a header comment block explaining its purpose and usage.

## 4. Environment Details

*   **Dotfiles Root:** `~/workspace/dotfiles` (standard convention).
*   **Backups:** `~/.dotfiles-backup/YYYYMMDD_HHMMSS/`.
*   **Shells:** Zsh is the preferred default; Bash is supported.

## 5. Agent Behavior (Cursor/Copilot)

*   **Proactive Validation:** After modifying a script, verify syntax with `bash -n script.sh`.
*   **Safety First:** When suggesting deletion commands (`rm`), always verify paths and suggest using the backup mechanism (`backup_file` function) if applicable.
*   **Context Awareness:** Read `CLAUDE.md` for the latest architecture overview before proposing complex refactors.
