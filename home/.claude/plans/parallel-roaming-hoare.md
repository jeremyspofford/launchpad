# Plan: Cross-Platform Dotfiles Overhaul

## Executive Summary

**Goal**: Clone repo to any OS (macOS, Windows/WSL, Linux), run setup, get a complete development environment with:

1. **mise** for tool version management (native performance)
2. **Application configs**: Ghostty, Neovim, tmux, VS Code/Cursor, Antigravity
3. **Dynamic git** with multiple SSH identities
4. **Cheatsheets** for tmux, neovim, and repo usage
5. **Simplified setup** (consider dropping Ansible for pure shell scripts)

---

## Current State Analysis

### What's Already Working ✅
- GNU Stow-based dotfiles (home/ mirrors ~/)
- mise.toml with 27 tools defined
- Shared `.commonrc` for bash/zsh
- Lazy loading for fast shell startup
- WeZTerm config exists
- 1Password secrets integration

### What's Missing ❌
- **Ghostty**: No config (location: `~/.config/ghostty/config`)
- **Neovim**: No config (location: `~/.config/nvim/`)
- **tmux**: No config (location: `~/.tmux.conf`)
- **VS Code/Cursor**: No settings synced
- **Antigravity**: Google's new AI IDE - no config
- **SSH config**: No multi-key management
- **Git identity configs**: Referenced but don't exist
- **Documentation**: No cheatsheets

### Issues to Fix
1. Shell configs have local cruft (Kiro CLI, hardcoded paths, exposed TEAMS_WEBHOOK_URL)
2. Ansible may be overkill - could simplify to shell scripts
3. Missing `~/.config/git/` directory structure

---

## Proposed Architecture

### 1. Simplified Setup (Drop Ansible)

**Current**: `setup.sh` → Ansible playbook → roles → stow
**Proposed**: `setup.sh` does everything directly

```bash
scripts/
├── setup.sh              # Main entry - detects OS, orchestrates
├── install/
│   ├── common.sh         # Cross-platform tools (mise, stow, git)
│   ├── macos.sh          # Homebrew + casks
│   ├── linux.sh          # apt/dnf packages
│   └── wsl.sh            # WSL-specific tweaks
├── config/
│   └── stow.sh           # Run stow operations
└── utils.sh              # Shared functions
```

**Benefits**:
- Simpler to understand and debug
- No Ansible/Python dependency
- Faster execution
- Easier for contributors

### 2. Tool Management: Mise

```
home/.config/mise/mise.toml          # Global defaults
project/.mise.toml                    # Per-project overrides
```

### 3. Application Configurations

```
home/.config/
├── ghostty/
│   └── config                       # Ghostty terminal config
├── nvim/                            # LazyVim + AI plugins
│   ├── init.lua
│   ├── lua/
│   │   ├── config/
│   │   └── plugins/
│   │       ├── ai.lua               # avante.nvim + copilot
│   │       └── ...
│   └── lazyvim.json
├── tmux/
│   └── tmux.conf                    # tmux config (TPM plugins)
├── Code/User/                       # VS Code settings
│   ├── settings.json
│   └── keybindings.json
├── Cursor/User/                     # Cursor settings (symlink to Code/)
├── antigravity/                     # Google Antigravity config
│   └── settings.json
├── mise/
│   └── mise.toml
└── git/
    ├── personal.gitconfig
    ├── work.gitconfig
    └── client.gitconfig.template
```

### 4. AI-Powered Neovim Setup

**Goal**: Make Neovim as powerful as Cursor/Antigravity

**LazyVim + AI Plugins**:
- **avante.nvim** - Cursor-like AI assistant (ask, edit, chat)
- **copilot.lua** + **CopilotChat.nvim** - GitHub Copilot integration
- **codecompanion.nvim** - Alternative AI chat (supports Claude, GPT, local models)

**LazyExtras to enable**:
```lua
-- In lazyvim.json
{
  "extras": [
    "ai.copilot",
    "ai.copilot-chat"
  ]
}
```

**avante.nvim config**:
```lua
{
  "yetone/avante.nvim",
  opts = {
    provider = "claude",  -- or "openai", "azure"
    claude = {
      api_key_name = "ANTHROPIC_API_KEY",
      model = "claude-sonnet-4-20250514",
    },
  },
}
```

### 5. Terminal Stack: Ghostty + tmux

**Ghostty config** (`~/.config/ghostty/config`):
```
font-family = JetBrainsMono Nerd Font
font-size = 14
theme = dark
window-decoration = false
shell-integration = zsh
```

**tmux config** with TPM:
```bash
# Prefix: Ctrl-a
set -g prefix C-a
set -g mouse on
set -g base-index 1

# Plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'catppuccin/tmux'

run '~/.tmux/plugins/tpm/tpm'
```

### 6. Dynamic Git + SSH

**SSH Host Aliases** (`~/.ssh/config`):
```ssh
Host github.com-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal

Host github.com-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
```

**Clone pattern**: `git clone git@github.com-work:org/repo.git`

### 7. Documentation & Cheatsheets

```
docs/
├── README.md                        # Main usage guide
├── SETUP.md                         # Detailed setup instructions
├── cheatsheets/
│   ├── tmux.md                      # tmux key bindings
│   ├── neovim.md                    # Neovim/LazyVim commands
│   ├── neovim-ai.md                 # AI plugin commands
│   └── git-identities.md            # Multi-identity workflow
└── TROUBLESHOOTING.md               # Common issues

---

## Implementation Plan

### Phase 1: Simplify Setup Scripts
**Remove Ansible, replace with pure shell**

1. Create `scripts/install/common.sh` - mise, stow, git, core CLI tools
2. Create `scripts/install/macos.sh` - Homebrew, casks (Ghostty, etc.)
3. Create `scripts/install/linux.sh` - apt/dnf packages
4. Create `scripts/install/wsl.sh` - WSL-specific tweaks
5. Update `scripts/setup.sh` to orchestrate based on OS detection
6. Archive `ansible/` directory (keep for reference, mark deprecated)

### Phase 2: Clean Up Shell Configs
**Files:** `home/.zshrc`, `home/.bashrc`, `home/.commonrc`

1. Remove hardcoded local paths (Kiro CLI, Antigravity, opencode)
2. Remove exposed secrets (TEAMS_WEBHOOK_URL)
3. Create `.zshrc.local.template` / `.bashrc.local.template` for local additions
4. Simplify and unify mise activation across both shells
5. Improve platform detection (macOS, Linux, WSL)
6. Add `dotfiles-push` and `dotfiles-status` functions

### Phase 3: Add Application Configs

**Ghostty** (`home/.config/ghostty/config`):
- Font, colors, shell integration
- Cross-platform compatible settings

**tmux** (`home/.tmux.conf`):
- TPM plugin manager setup
- Sensible defaults (mouse, prefix C-a)
- Session persistence (tmux-resurrect)
- Clipboard integration (tmux-yank)

**Neovim/LazyVim** (`home/.config/nvim/`):
- Base LazyVim configuration
- AI plugins: avante.nvim, copilot.lua, CopilotChat.nvim
- Language servers pre-configured
- Custom keybindings

**VS Code/Cursor** (`home/.config/Code/User/`):
- Shared settings.json
- Extensions list
- Keybindings

**Antigravity** (`home/.config/antigravity/`):
- Basic settings for Google's AI IDE

### Phase 4: Git Identity System
**Files:** `home/.gitconfig`, `home/.config/git/*.gitconfig`, `home/.ssh/config`

1. Create identity-specific gitconfig files (personal, work, clients)
2. Update main `.gitconfig` with conditional includes
3. Create SSH config with host aliases
4. Document the workflow in cheatsheet

### Phase 5: Documentation & Cheatsheets

**Main docs:**
- `docs/README.md` - Overview and quick start
- `docs/SETUP.md` - Detailed setup guide

**Cheatsheets:**
- `docs/cheatsheets/tmux.md` - All tmux bindings
- `docs/cheatsheets/neovim.md` - LazyVim commands
- `docs/cheatsheets/neovim-ai.md` - AI plugin usage
- `docs/cheatsheets/git-identities.md` - Multi-identity workflow
- `docs/cheatsheets/dotfiles.md` - Repo usage guide

---

## Files to Create

| File | Purpose |
|------|---------|
| `scripts/install/common.sh` | Cross-platform tool installation |
| `scripts/install/macos.sh` | macOS-specific (Homebrew, casks) |
| `scripts/install/linux.sh` | Linux packages |
| `scripts/install/wsl.sh` | WSL tweaks |
| `home/.config/ghostty/config` | Ghostty terminal settings |
| `home/.config/nvim/` | LazyVim + AI plugins config |
| `home/.tmux.conf` | tmux configuration |
| `home/.config/Code/User/settings.json` | VS Code settings |
| `home/.config/git/personal.gitconfig` | Personal git identity |
| `home/.config/git/work.gitconfig` | Work git identity |
| `home/.config/git/client.gitconfig.template` | Client template |
| `home/.ssh/config` | SSH host aliases |
| `docs/cheatsheets/*.md` | Cheatsheet files |

## Files to Modify

| File | Changes |
|------|---------|
| `scripts/setup.sh` | Rewrite to use new install scripts |
| `home/.zshrc` | Remove cruft, simplify |
| `home/.bashrc` | Remove cruft, simplify |
| `home/.commonrc` | Add sync functions, clean up |
| `home/.gitconfig` | Add conditional includes |
| `home/.aliases` | Remove hardcoded paths |

## Files to DELETE

| File | Action |
|------|--------|
| `ansible/` | DELETE entirely (see Phase 0 for full list) |

---

## Neovim AI Stack Details

**Goal**: Match Cursor/Antigravity capabilities in Neovim

### Plugins to Include

1. **avante.nvim** (Cursor-like experience)
   - AI chat sidebar
   - Inline code editing
   - Multi-model support (Claude, GPT, local)
   - Key: `<leader>aa` to open

2. **copilot.lua** + **CopilotChat.nvim**
   - GitHub Copilot completions
   - Chat interface
   - Supports Claude via CopilotChat
   - Key: `<leader>ac` for chat

3. **aider.nvim** (Terminal-based AI pair programming)
   - Integrates aider CLI into Neovim
   - Git-aware code editing
   - Excellent for multi-file refactoring
   - Key: `<leader>ai` to open aider in terminal

4. **codecompanion.nvim** (optional alternative)
   - Supports more providers
   - Better local model support

### Aider Integration

**What is aider?** A CLI tool for AI pair programming that edits files directly in your repo.

**Installation**: `pip install aider-chat` or via mise
```toml
# In mise.toml
[tools]
"pipx:aider-chat" = "latest"
```

**Neovim integration** (aider.nvim or custom):
```lua
-- Custom aider integration via toggleterm
{
  "akinsho/toggleterm.nvim",
  keys = {
    { "<leader>ai", function()
      local Terminal = require("toggleterm.terminal").Terminal
      local aider = Terminal:new({
        cmd = "aider",
        direction = "vertical",
        size = 80,
      })
      aider:toggle()
    end, desc = "Open Aider" },
  },
}
```

### LazyVim Extras to Enable
```json
{
  "extras": [
    "lang.typescript",
    "lang.python",
    "lang.go",
    "lang.rust",
    "ai.copilot",
    "ai.copilot-chat"
  ]
}
```

---

## Secrets Security (Public Repo Safe)

**Goal**: Repo is public and usable by anyone - NO secrets committed

### Secrets Strategy

1. **Environment variables** - API keys loaded from env, never hardcoded
2. **Template files** - `.secrets.template` shows structure, `.secrets` is gitignored
3. **1Password integration** - Optional, for users who have it
4. **Clear documentation** - README explains how to set up secrets

### Files Structure

```
home/
├── .secrets.template          # Template showing required env vars (COMMITTED)
├── .secrets                   # Actual secrets (GITIGNORED)
├── .gitconfig                 # No emails/keys - uses includes (COMMITTED)
└── .config/git/
    ├── identity.gitconfig.template  # Template for identities (COMMITTED)
    └── personal.gitconfig           # Actual identity (GITIGNORED or generic)
```

### .secrets.template Example
```bash
# Copy to ~/.secrets and fill in your values
# This file is gitignored - never commit actual secrets!

# AI API Keys (for Neovim AI plugins)
export ANTHROPIC_API_KEY=""
export OPENAI_API_KEY=""

# GitHub (for Copilot - usually authenticated via :Copilot auth)
# export GITHUB_TOKEN=""

# Optional: Other services
# export AWS_ACCESS_KEY_ID=""
# export AWS_SECRET_ACCESS_KEY=""
```

### .gitignore Additions
```gitignore
# Secrets - NEVER commit
.secrets
*.secrets
.env.local

# Personal git configs (contain email)
home/.config/git/personal.gitconfig
home/.config/git/work.gitconfig
home/.config/git/client*.gitconfig
!home/.config/git/*.template

# SSH keys (should never be in repo anyway)
home/.ssh/id_*
!home/.ssh/config
```

### Git Identity Strategy for Public Repo

**Option A**: Generic template only (recommended)
```gitconfig
# home/.gitconfig - committed, generic
[include]
    path = ~/.config/git/identity.gitconfig  # User creates locally

[user]
    # Intentionally empty - set in identity.gitconfig
```

**Option B**: Use env vars in gitconfig
```gitconfig
[user]
    name = "${GIT_USER_NAME}"
    email = "${GIT_USER_EMAIL}"
```
(Note: git doesn't expand env vars natively, requires wrapper script)

### Setup Script Prompts
```bash
# In setup.sh - prompt user for required info
if [[ ! -f "$HOME/.secrets" ]]; then
    echo "📝 Creating secrets file..."
    cp "$DOTFILES/home/.secrets.template" "$HOME/.secrets"
    echo "⚠️  Edit ~/.secrets and add your API keys"
fi

if [[ ! -f "$HOME/.config/git/identity.gitconfig" ]]; then
    echo "📝 Setting up git identity..."
    read -p "Git name: " git_name
    read -p "Git email: " git_email
    # Generate identity.gitconfig
fi
```

---

## Example Workflow After Implementation

```bash
# Fresh machine setup (any OS):
git clone git@github.com:jeremyspofford/dotfiles.git ~/workspace/dotfiles
cd ~/workspace/dotfiles
./scripts/setup.sh

# Opens Ghostty, tmux auto-starts
ghostty
# Inside tmux, open Neovim with AI
nvim .

# In Neovim:
# <leader>aa - Open Avante AI sidebar
# <leader>ac - Open Copilot Chat
# Tab - Accept Copilot suggestions

# Git with correct identity:
cd ~/workspace/client-project
git clone git@github.com-client:org/repo.git
# Uses client SSH key + email automatically

# Sync dotfiles changes:
dotfiles-push "Added tmux config"  # On Mac
dotfiles-sync                       # On Linux/WSL
```

---

## Theme System: Auto-Follow System + Manual Toggle

**Theme**: Catppuccin (Mocha = dark, Latte = light)
**Behavior**: Apps automatically follow system theme, with manual override available

### Automatic System Theme Detection

**Neovim**: Use [auto-dark-mode.nvim](https://github.com/f-person/auto-dark-mode.nvim)
```lua
{
  "f-person/auto-dark-mode.nvim",
  opts = {
    set_dark_mode = function()
      vim.api.nvim_set_option_value("background", "dark", {})
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
    set_light_mode = function()
      vim.api.nvim_set_option_value("background", "light", {})
      vim.cmd.colorscheme("catppuccin-latte")
    end,
    update_interval = 1000,  -- Check every second
    fallback = "dark",
  },
}
```
- Works on macOS (AppleScript), Linux (freedesktop portal), Windows (registry)
- Auto-detects and switches when system theme changes

**tmux**: Use dark-notify or shell hook
```bash
# In tmux.conf - check system theme on attach
run-shell 'if [ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" = "Dark" ]; then \
  tmux set -g @catppuccin_flavor "mocha"; \
else \
  tmux set -g @catppuccin_flavor "latte"; \
fi'
```

Or use **dark-notify** daemon (runs in background):
```bash
# Install: brew install cormacrelf/tap/dark-notify
# In shell startup:
dark-notify -c 'tmux source ~/.tmux.conf'
```

**Ghostty**: Native support via `window-theme = auto`
```
# In ghostty config
window-theme = auto
theme = catppuccin-mocha
# Ghostty will adjust window chrome automatically
```

**VS Code/Cursor**: Native support
```json
{
  "window.autoDetectColorScheme": true,
  "workbench.preferredDarkColorTheme": "Catppuccin Mocha",
  "workbench.preferredLightColorTheme": "Catppuccin Latte"
}
```

### Manual Override (Optional)
Still provide `theme` command for manual control:
```bash
theme dark    # Force dark mode
theme light   # Force light mode
theme auto    # Return to system-following (default)
```

---

## Phase 0: Repository Cleanup (DELETE UNUSED FILES)

### Files/Directories to DELETE (not archive)

| Path | Reason |
|------|--------|
| `ansible/` | Entire directory - replacing with shell scripts |
| `REMAINING_TASKS.md` | Outdated task list from chezmoi migration |
| `CODING_STANDARDS.md` | Generic boilerplate, not repo-specific |
| `CHANGELOG.md` | Empty/stale, will use git history instead |
| `tests/` | Empty test stubs, not functional |
| `scripts/sso.py` | Duplicate of aws_sso.py |
| `scripts/requirements.txt` | Python deps for ansible, no longer needed |
| `scripts/.mise.toml` | Misplaced, should be in home/.config/mise/ |
| `home/.bash_aliases` | Duplicate of home/.aliases |
| `home/.vimrc` | Replaced by Neovim config |
| `home/.wezterm.lua` | Replacing with Ghostty |
| `home/README.md` | Outdated stow instructions |
| `.yamllint.yml` | For Ansible linting, no longer needed |
| `home/.markdownlint.json` | Duplicate of root .markdownlint.json |

### Files to KEEP but UPDATE

| Path | Changes |
|------|---------|
| `CLAUDE.md` | Update to reflect new structure |
| `README.md` | Complete rewrite for new setup |
| `.gitignore` | Add new patterns for secrets |
| `scripts/setup.sh` | Rewrite completely |
| `scripts/sync.sh` | Simplify |
| `scripts/sync-secrets.sh` | Keep as-is |
| `scripts/validate-setup.sh` | Update for new structure |

### Cleanup Shell Configs (remove cruft)

**From `home/.zshrc`** - REMOVE these lines:
- Lines 1-2: Kiro CLI pre block
- Lines 163-166: Docker completions (will auto-add if needed)
- Line 169: TEAMS_WEBHOOK_URL (exposed secret!)
- Lines 172-173: opencode PATH
- Lines 175-176: Kiro CLI post block
- Lines 178-182: Duplicate Antigravity PATH entries

**From `home/.bashrc`** - REMOVE these lines:
- Lines 1-2: Kiro CLI pre block
- Lines 199-200: Kiro CLI post block

**From `home/.aliases`** - REMOVE/UPDATE:
- Line 7: bru alias (hardcoded path)
- Line 57: sso alias (hardcoded path)

---

## Confirmed Preferences ✅

- ✅ Use mise for tool management (no Docker)
- ✅ Drop Ansible, use shell scripts (DELETE, not archive)
- ✅ Ghostty as terminal + tmux
- ✅ Full LazyVim with AI (avante.nvim, Copilot)
- ✅ VS Code/Cursor/Antigravity configs
- ✅ 3-4 git identities with SSH host aliases
- ✅ Catppuccin theme with auto system theme detection
- ✅ Comprehensive cheatsheets
- ✅ Clean up all unused/duplicate files
