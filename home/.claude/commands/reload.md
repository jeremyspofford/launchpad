---
description: Reload agent configurations and validate setup (requires new session to take effect)
---

# Configuration Reload

Claude Code loads agent configurations at **session start only**. Configuration changes won't affect the current session.

## To Apply Configuration Changes:

1. **End this session** (Ctrl+C or exit command)
2. **Start a new Claude Code session**
3. New session will load updated configurations

## Configuration Validation

Let me validate your current configuration files:

### Agent Configuration Files

Check all agent files are readable and properly formatted:

```bash
# List all agent files
echo "=== Agent Files ==="
ls -1 ~/.claude/agents/*.md 2>/dev/null | wc -l | xargs echo "Total agents:"
echo ""

# Check for syntax issues in frontmatter
echo "=== Validating Agent Frontmatter ==="
for file in ~/.claude/agents/*.md; do
  if [ -f "$file" ]; then
    # Check if file has frontmatter
    if grep -q "^---$" "$file"; then
      echo "✅ $(basename "$file")"
    else
      echo "⚠️  $(basename "$file") - Missing frontmatter"
    fi
  fi
done
echo ""

# List available agents
echo "=== Available Agents ==="
grep -h "^name:" ~/.claude/agents/*.md 2>/dev/null | sed 's/name: /  - /' | sort
echo ""
```

### Global Configuration

Check CLAUDE.md:

```bash
echo "=== Global Configuration ==="
if [ -f ~/.claude/CLAUDE.md ]; then
  echo "✅ CLAUDE.md found"
  echo "   Size: $(wc -c < ~/.claude/CLAUDE.md) bytes"
  echo "   Lines: $(wc -l < ~/.claude/CLAUDE.md) lines"
else
  echo "⚠️  CLAUDE.md not found"
fi
echo ""
```

### Settings

Check settings.json:

```bash
echo "=== Claude Code Settings ==="
if [ -f ~/.claude/settings.json ]; then
  echo "✅ settings.json found"
  # Pretty print if jq is available
  if command -v jq &> /dev/null; then
    echo "   Model: $(jq -r '.model // "default"' ~/.claude/settings.json)"
    echo "   Max tokens: $(jq -r '.maxTokens // "default"' ~/.claude/settings.json)"
  fi
else
  echo "⚠️  settings.json not found"
fi
echo ""
```

### Async Agent Specifications

Check if async agent specs are available:

```bash
echo "=== Async Agent Specifications ==="
if [ -f ~/.claude/agents/ASYNC_AGENTS_SPEC.md ]; then
  echo "✅ ASYNC_AGENTS_SPEC.md found"
else
  echo "⚠️  ASYNC_AGENTS_SPEC.md not found"
fi

if [ -f ~/.claude/agents/ASYNC_WORKFLOW_EXAMPLES.md ]; then
  echo "✅ ASYNC_WORKFLOW_EXAMPLES.md found"
else
  echo "⚠️  ASYNC_WORKFLOW_EXAMPLES.md not found"
fi
echo ""
```

### Symlinks (Stow)

Check if configurations are properly symlinked:

```bash
echo "=== Symlink Status ==="
if [ -L ~/.claude ]; then
  echo "✅ ~/.claude is a symlink"
  echo "   Target: $(readlink ~/.claude)"
elif [ -d ~/.claude ]; then
  echo "ℹ️  ~/.claude is a regular directory (not stowed)"
else
  echo "⚠️  ~/.claude doesn't exist"
fi
echo ""
```

## Summary

Once validation is complete:

- ✅ **All checks passed**: Your configuration is ready. Restart Claude Code to apply changes.
- ⚠️ **Issues found**: Fix the issues listed above, then restart Claude Code.

## Recent Configuration Changes

To see what changed recently:

```bash
echo "=== Recent Changes to Agent Files ==="
find ~/.claude/agents -name "*.md" -mtime -7 -exec ls -lht {} \; | head -10
```

## Quick Reference

**Start new session**: Exit this session and run `claude` again

**Your configurations**:
- Agents: `~/.claude/agents/`
- Global config: `~/.claude/CLAUDE.md`
- Settings: `~/.claude/settings.json`
- Commands: `~/.claude/commands/`

**Async agent capabilities**:
- Orchestrator has parallel execution built-in
- Use orchestrator-agent for coordinated parallel workflows
- See ASYNC_WORKFLOW_EXAMPLES.md for usage patterns
