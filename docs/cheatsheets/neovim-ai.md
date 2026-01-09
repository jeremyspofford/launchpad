# Neovim AI Plugins Cheatsheet

Quick reference for AI-powered coding assistants in Neovim.

## GitHub Copilot

Inline code suggestions powered by GitHub Copilot.

| Key | Action |
|-----|--------|
| `Tab` | Accept suggestion |
| `<C-]>` | Dismiss suggestion |
| `<M-]>` | Next suggestion |
| `<M-[>` | Previous suggestion |
| `<C-\>` | Open Copilot panel |

### Copilot Chat

| Key | Action |
|-----|--------|
| `<leader>cc` | Open Copilot Chat |
| `<leader>cq` | Quick chat (ask question) |
| `<leader>ch` | Show Copilot Chat help |
| `<leader>ce` | Explain code |
| `<leader>ct` | Generate tests |
| `<leader>cr` | Review code |
| `<leader>cR` | Refactor code |

## Avante (Cursor-like AI)

AI chat interface similar to Cursor, powered by Claude.

| Key | Action |
|-----|--------|
| `<leader>aa` | Open Avante chat |
| `<leader>ae` | Edit with AI |
| `<leader>ar` | Refresh response |

### Chat Commands

In the Avante chat window:
- Type your question and press Enter
- Use `@file` to reference a file
- Use `@selection` to include selected code
- Press `<CR>` to submit

### Configuration

Set your API key in `~/.secrets`:
```bash
export ANTHROPIC_API_KEY="your-key-here"
```

## Aider (Terminal AI)

Aider runs in a terminal for pair programming with AI.

| Key | Action |
|-----|--------|
| `<leader>ai` | Open Aider terminal |
| `<leader>at` | Toggle terminal |

### Aider Commands

Once in Aider:
- `/add file.py` - Add file to context
- `/drop file.py` - Remove file from context
- `/undo` - Undo last change
- `/diff` - Show pending changes
- `/commit` - Commit changes
- `/exit` - Exit Aider

### Setup

Install Aider:
```bash
pip install aider-chat
```

Configure in `~/.aider.conf.yml`:
```yaml
model: claude-sonnet-4-20250514
```

## Tips

1. **Use Copilot for quick completions** - Best for boilerplate and common patterns
2. **Use Copilot Chat for explanations** - Ask about unfamiliar code
3. **Use Avante for complex edits** - Multi-file refactoring and architectural changes
4. **Use Aider for pair programming** - Long coding sessions with context
