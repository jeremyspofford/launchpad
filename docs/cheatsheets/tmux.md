# Tmux Cheatsheet

Quick reference for tmux keybindings. Prefix is `C-a` (Ctrl+a).

## Sessions

| Key | Action |
|-----|--------|
| `tmux new -s name` | New session with name |
| `tmux ls` | List sessions |
| `tmux attach -t name` | Attach to session |
| `prefix d` | Detach from session |
| `prefix $` | Rename session |
| `prefix s` | Switch sessions |

## Windows

| Key | Action |
|-----|--------|
| `prefix c` | New window |
| `prefix ,` | Rename window |
| `prefix n` | Next window |
| `prefix p` | Previous window |
| `prefix 0-9` | Go to window # |
| `prefix &` | Kill window |
| `prefix w` | List windows |

## Panes

| Key | Action |
|-----|--------|
| `prefix \|` | Split vertically |
| `prefix -` | Split horizontally |
| `prefix h/j/k/l` | Navigate panes (vim-style) |
| `prefix H/J/K/L` | Resize panes |
| `prefix x` | Kill pane |
| `prefix z` | Toggle pane zoom |
| `prefix {` | Move pane left |
| `prefix }` | Move pane right |
| `prefix q` | Show pane numbers |
| `prefix o` | Cycle through panes |

## Copy Mode (vi)

| Key | Action |
|-----|--------|
| `prefix [` | Enter copy mode |
| `Space` | Start selection |
| `Enter` | Copy selection |
| `prefix ]` | Paste |
| `q` | Exit copy mode |

## Plugins (TPM)

| Key | Action |
|-----|--------|
| `prefix I` | Install plugins |
| `prefix U` | Update plugins |
| `prefix alt-u` | Uninstall removed plugins |

## Resurrect (Session Persistence)

| Key | Action |
|-----|--------|
| `prefix C-s` | Save session |
| `prefix C-r` | Restore session |

## Configuration

| Key | Action |
|-----|--------|
| `prefix r` | Reload config |

## Mouse

Mouse is enabled! You can:
- Click to select pane
- Drag to resize panes
- Scroll to scroll
- Click tab bar to switch windows
