# Antigravity AI Prompt for Dotfiles Overhaul

Copy everything below the line and paste it into Antigravity's AI chat:

---

## Task: Cross-Platform Dotfiles Repository Overhaul

I need you to help me overhaul my dotfiles repository. The goal is to create a clean, cross-platform setup that works on macOS, Linux, and Windows/WSL.

### Repository Location
`~/workspace/dotfiles` (or wherever you cloned it)

### High-Level Goals

1. **Delete unused files** (cleanup first)
2. **Replace Ansible with shell scripts** (simpler setup)
3. **Add application configs** (Ghostty, tmux, Neovim with AI, VS Code/Cursor)
4. **Set up multi-identity Git/SSH**
5. **Create cheatsheets**
6. **Ensure no secrets are exposed** (public repo)

---

## PHASE 0: DELETE THESE FILES/DIRECTORIES

Delete these completely (not archive):

```bash
rm -rf ansible/
rm -f REMAINING_TASKS.md
rm -f CODING_STANDARDS.md
rm -f CHANGELOG.md
rm -rf tests/
rm -f scripts/sso.py
rm -f scripts/requirements.txt
rm -f scripts/.mise.toml
rm -f home/.bash_aliases
rm -f home/.vimrc
rm -f home/.wezterm.lua
rm -f home/README.md
rm -f .yamllint.yml
rm -f home/.markdownlint.json
```

---

## PHASE 1: Create Shell-Based Install Scripts

Create these new files under `scripts/`:

### `scripts/install/common.sh`
Cross-platform tool installation (mise, stow, git, core CLI tools).
- Detect OS (macOS/Linux/WSL)
- Install mise if not present
- Install stow if not present
- Run `mise install` to install tools from mise.toml

### `scripts/install/macos.sh`
macOS-specific installations:
- Install Homebrew if not present
- Install casks: ghostty, font-jetbrains-mono-nerd-font
- Set up macOS defaults (optional)

### `scripts/install/linux.sh`
Linux package installation:
- Detect distro (apt/dnf/pacman)
- Install: git, stow, curl, unzip, build-essential

### `scripts/install/wsl.sh`
WSL-specific tweaks:
- Fix WSL interop
- Set up clipboard integration
- Configure WSLENV

### `scripts/setup.sh` (rewrite existing)
Main entry point that:
1. Detects OS
2. Sources appropriate install script
3. Runs stow to symlink dotfiles
4. Prompts user for git identity setup
5. Creates ~/.secrets from template if not exists

---

## PHASE 2: Clean Up Shell Configs

### `home/.zshrc` - Remove these lines:
- Kiro CLI blocks (top and bottom of file)
- Docker completions (lines 163-166)
- TEAMS_WEBHOOK_URL line (EXPOSED SECRET!)
- opencode PATH
- Duplicate Antigravity PATH entries

### `home/.bashrc` - Remove:
- Kiro CLI blocks (top and bottom)

### `home/.aliases` - Remove:
- Line 7: bru alias (hardcoded path to ft-quoting)
- Line 57: sso alias (hardcoded path)

### Create `home/.zshrc.local.template`:
```bash
# Local zsh configuration (not synced)
# Copy to ~/.zshrc.local and customize

# Example: Add work-specific paths
# export PATH="$HOME/work/tools:$PATH"

# Example: Source work-specific aliases
# source ~/.work-aliases
```

---

## PHASE 3: Add Application Configs

### `home/.config/ghostty/config`
```
font-family = JetBrainsMono Nerd Font
font-size = 14
window-theme = auto
theme = catppuccin-mocha
shell-integration = zsh
window-padding-x = 10
window-padding-y = 10
cursor-style = block
cursor-style-blink = true
copy-on-select = clipboard
```

### `home/.tmux.conf`
```bash
# Prefix: Ctrl-a (easier than Ctrl-b)
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Modern settings
set -g mouse on
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g history-limit 50000
set -s escape-time 0

# Better splits
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# Vim-style pane navigation
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Reload config
bind r source-file ~/.tmux.conf \; display "Reloaded!"

# TPM Plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'catppuccin/tmux'

# Catppuccin theme
set -g @catppuccin_flavor 'mocha'

# Auto-detect system theme on macOS
run-shell 'if [ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" != "Dark" ]; then tmux set -g @catppuccin_flavor "latte"; fi'

# Initialize TPM (keep at bottom)
run '~/.tmux/plugins/tpm/tpm'
```

### `home/.config/nvim/` - LazyVim with AI

Create a full LazyVim setup:

**`home/.config/nvim/init.lua`**:
```lua
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "lazyvim.plugins.extras.ai.copilot" },
    { import = "lazyvim.plugins.extras.ai.copilot-chat" },
    { import = "plugins" },
  },
  defaults = { lazy = false, version = false },
})
```

**`home/.config/nvim/lua/plugins/catppuccin.lua`**:
```lua
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
    },
  },
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
      update_interval = 1000,
      fallback = "dark",
    },
  },
}
```

**`home/.config/nvim/lua/plugins/ai.lua`**:
```lua
return {
  -- Avante (Cursor-like AI)
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    build = "make",
    opts = {
      provider = "claude",
      claude = {
        api_key_name = "ANTHROPIC_API_KEY",
        model = "claude-sonnet-4-20250514",
      },
    },
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
  },
  -- Aider integration
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
  },
}
```

**`home/.config/nvim/lazyvim.json`**:
```json
{
  "extras": [
    "lazyvim.plugins.extras.lang.typescript",
    "lazyvim.plugins.extras.lang.python",
    "lazyvim.plugins.extras.lang.go",
    "lazyvim.plugins.extras.lang.rust",
    "lazyvim.plugins.extras.ai.copilot",
    "lazyvim.plugins.extras.ai.copilot-chat"
  ],
  "news": { "NEWS.md": "" },
  "version": 7
}
```

### `home/.config/Code/User/settings.json` (VS Code/Cursor)
```json
{
  "window.autoDetectColorScheme": true,
  "workbench.preferredDarkColorTheme": "Catppuccin Mocha",
  "workbench.preferredLightColorTheme": "Catppuccin Latte",
  "editor.fontFamily": "JetBrainsMono Nerd Font, monospace",
  "editor.fontSize": 14,
  "editor.lineHeight": 1.5,
  "editor.tabSize": 2,
  "editor.formatOnSave": true,
  "editor.minimap.enabled": false,
  "terminal.integrated.fontFamily": "JetBrainsMono Nerd Font",
  "files.autoSave": "onFocusChange"
}
```

---

## PHASE 4: Git Identity System

### `home/.gitconfig` (update existing)
```gitconfig
[include]
    path = ~/.config/git/identity.gitconfig

[core]
    editor = nvim
    excludesfile = ~/.gitignore
    autocrlf = input
    pager = delta

[init]
    defaultBranch = main

[push]
    default = current
    autoSetupRemote = true

[pull]
    rebase = true

[fetch]
    prune = true

[merge]
    conflictstyle = diff3

[diff]
    colorMoved = default

[interactive]
    diffFilter = delta --color-only

[delta]
    navigate = true
    light = false
    side-by-side = true
    line-numbers = true

[alias]
    st = status -sb
    co = checkout
    ci = commit
    br = branch
    lg = log --oneline --graph --decorate
    unstage = reset HEAD --
    last = log -1 HEAD
    amend = commit --amend --no-edit
    sync = !git fetch --all && git pull

[color]
    ui = true
```

### `home/.config/git/identity.gitconfig.template`
```gitconfig
# Copy to ~/.config/git/identity.gitconfig and fill in your details
[user]
    name = "Your Name"
    email = "your.email@example.com"

# Optional: signing key
# [user]
#     signingkey = YOUR_KEY_ID
# [commit]
#     gpgsign = true
```

### `home/.ssh/config`
```ssh
# Personal GitHub
Host github.com-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes

# Work GitHub
Host github.com-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes

# GitLab Personal
Host gitlab.com
    HostName gitlab.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes

# Default GitHub (personal)
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes
```

---

## PHASE 5: Cheatsheets

Create `docs/cheatsheets/` directory with:

### `docs/cheatsheets/tmux.md`
Document all tmux keybindings (prefix C-a, splits, panes, sessions, resurrect)

### `docs/cheatsheets/neovim.md`
Document LazyVim keybindings, common commands, plugin shortcuts

### `docs/cheatsheets/neovim-ai.md`
Document AI plugin usage:
- `<leader>aa` - Avante chat
- `<leader>ac` - Copilot chat
- `<leader>ai` - Open Aider
- Tab - Accept Copilot suggestion

### `docs/cheatsheets/git-identities.md`
Document multi-identity workflow:
- How SSH host aliases work
- Clone patterns: `git clone git@github.com-work:org/repo.git`
- How to add new identities

---

## PHASE 6: Update .gitignore

Add to `.gitignore`:
```gitignore
# Secrets - NEVER commit
.secrets
*.secrets
.env.local

# Personal identity configs
home/.config/git/identity.gitconfig
home/.config/git/personal.gitconfig
home/.config/git/work.gitconfig
home/.config/git/*.gitconfig
!home/.config/git/*.template

# SSH private keys
home/.ssh/id_*
!home/.ssh/config

# Local overrides
*.local
```

---

## PHASE 7: Update README.md

Rewrite README.md with:
1. Quick start (3 commands)
2. What's included
3. How to customize (secrets, git identity)
4. Links to cheatsheets

---

## Summary Checklist

- [ ] Delete unused files (Phase 0)
- [ ] Create install scripts (Phase 1)
- [ ] Clean shell configs (Phase 2)
- [ ] Add Ghostty config
- [ ] Add tmux config with TPM
- [ ] Add Neovim/LazyVim with AI plugins
- [ ] Add VS Code settings
- [ ] Update .gitconfig with identity includes
- [ ] Create SSH config with host aliases
- [ ] Create identity.gitconfig.template
- [ ] Create cheatsheets
- [ ] Update .gitignore
- [ ] Rewrite README.md
- [ ] Update CLAUDE.md

---

**Important Notes:**
- Theme: Catppuccin (mocha=dark, latte=light) with auto system theme detection
- All apps should follow system dark/light mode automatically
- No secrets should ever be committed (use templates)
- mise.toml already exists at `home/.config/mise/mise.toml` with 27 tools
