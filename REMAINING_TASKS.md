# Remaining Tasks for Dotfiles Ansible Refactoring

This document summarizes the progress made and outlines the remaining tasks for refactoring the Ansible dotfiles repository. This can be used to restart the conversation with the AI from a clean slate.

## Current Status Overview

We have completed a significant refactoring of the Ansible roles, moving from a role-per-application structure to an OS-specific structure (`common`, `macos`, `linux`). We've also implemented several package installations and configurations.

**Last known state of the playbook:** The playbook was failing on the `chezmoi apply` task due to a `chezmoi` initialization issue related to missing data for templates (e.g., `email`). We were in the process of fixing this by ensuring `chezmoi.toml` is created with necessary data.

## Completed Tasks

### A. Core Ansible Setup & Integration
- All original roles (`aws`, `browsers`, `cli`, `dependencies`, `gcloud`, `logitech-options`) have been refactored and their logic integrated into the `common`, `macos`, and `linux` roles.

### B. Package Installation (from `install.sh` - Cross-Platform & OS-Specific)
- Node.js & npm installation (macOS & Linux)
- `eza` (Linux)
- Neovim (Linux)
- `nvm` (Cross-platform)
- `tldr` (Cross-platform)
- `chezmoi` (Linux - *installation done, but initialization/application is the current blocker*)
- `starship` (Linux)
- GitHub CLI (`gh`) (Linux)
- AWS CLI (Linux)

### C. Configuration Tasks (from `install.sh`)
- Configure terminals/IDEs to use JetBrainsMono font (macOS - *installation done, configuration attempted, but blocked by chezmoi issue*)

## Pending Tasks

### B. Package Installation (from `install.sh` - Remaining)
- Azure CLI (Linux) - *This was the next task we were about to implement when the chezmoi issue arose.*
- `mise` (Cross-platform)

### C. Configuration Tasks (from `install.sh` - Remaining)
- Neovim config setup
- Git configuration
- Shell configuration (beyond `PATH` - *PATH issue is blocked by chezmoi*)

### D. AI CLIs (User Requests & `install.sh`)
- GitHub Copilot CLI (Verify/document its installation - it's part of `gh`)
- Cursor, Gemini, Claude, Amazon Q CLIs (Moved to `macos` role, but need to verify/integrate fully)

### E. Future / Roadmap Items (Deferred)
- Implement Molecule Testing
- Sync VSCode/Cursor Extensions and Settings

## Current Blocker

The playbook is currently failing on the `chezmoi apply` task. The error indicates that `chezmoi` templates are missing data (e.g., `email`). We were in the process of adding a task to create `~/.config/chezmoi/chezmoi.toml` with this data, but encountered issues with the `replace` tool.

**To resume, the immediate next step is to fix the `chezmoi.toml` creation and `chezmoi apply` issue.**
