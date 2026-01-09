# Neovim (LazyVim) Cheatsheet

Quick reference for LazyVim keybindings. Leader key is `Space`.

## General

| Key | Action |
|-----|--------|
| `<leader>` | Show which-key popup |
| `<C-h/j/k/l>` | Navigate windows |
| `<leader>qq` | Quit all |
| `<leader>fn` | New file |
| `<leader>ft` | Terminal (floating) |

## File Navigation

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fr` | Recent files |
| `<leader>fb` | Buffers |
| `<leader>fg` | Live grep |
| `<leader>e` | File explorer (neo-tree) |

## Buffers

| Key | Action |
|-----|--------|
| `<S-h>` | Previous buffer |
| `<S-l>` | Next buffer |
| `<leader>bd` | Delete buffer |
| `<leader>bb` | Switch buffer |

## Windows

| Key | Action |
|-----|--------|
| `<leader>w-` | Split below |
| `<leader>w\|` | Split right |
| `<leader>wd` | Close window |
| `<C-Up/Down/Left/Right>` | Resize window |

## Search & Replace

| Key | Action |
|-----|--------|
| `<leader>sr` | Search and replace (spectre) |
| `<leader>sw` | Search word under cursor |
| `n/N` | Next/prev search result |
| `*/#` | Search word forward/back |

## LSP

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | References |
| `K` | Hover documentation |
| `<leader>ca` | Code actions |
| `<leader>cr` | Rename |
| `<leader>cf` | Format |
| `]d / [d` | Next/prev diagnostic |
| `<leader>cd` | Line diagnostics |

## Git (LazyGit)

| Key | Action |
|-----|--------|
| `<leader>gg` | LazyGit |
| `<leader>gf` | LazyGit file history |
| `<leader>gc` | LazyGit commits |
| `]h / [h` | Next/prev hunk |
| `<leader>ghp` | Preview hunk |
| `<leader>ghs` | Stage hunk |
| `<leader>ghr` | Reset hunk |

## Editing

| Key | Action |
|-----|--------|
| `gcc` | Toggle line comment |
| `gc` | Toggle comment (visual) |
| `<leader>cf` | Format buffer |
| `<C-s>` | Save file |

## Telescope

| Key | Action |
|-----|--------|
| `<leader>/` | Grep in project |
| `<leader>:` | Command history |
| `<leader>ss` | Search symbols |
| `<leader>sk` | Search keymaps |
| `<leader>sh` | Search help |

## Plugins

| Key | Action |
|-----|--------|
| `<leader>l` | Lazy plugin manager |
| `<leader>cm` | Mason (LSP installer) |
