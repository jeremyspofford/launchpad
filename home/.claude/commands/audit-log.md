---
description: View routing audit log to track orchestrator-first policy compliance
---

# View Routing Audit Log

Display recent routing decisions and policy compliance.

## What This Shows

The audit log tracks:

- Direct file edits (Edit/Write/MultiEdit)
- Whether operations were routed through orchestrator
- Session start/end events
- Timestamps and file paths

## Commands to Execute

### View Last 20 Entries

```bash
if [ -f ~/.claude/routing-audit.log ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📊 Routing Audit Log (Last 20 Entries)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  tail -20 ~/.claude/routing-audit.log
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
  echo "No audit log found. Start using Claude Code to generate entries."
fi
```

### Statistics Summary

```bash
if [ -f ~/.claude/routing-audit.log ]; then
  echo ""
  echo "📈 Audit Log Statistics:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Total entries: $(wc -l < ~/.claude/routing-audit.log)"
  echo "Direct tool uses: $(grep -c 'DIRECT.*tool-use' ~/.claude/routing-audit.log || echo 0)"
  echo "Session ends: $(grep -c 'SESSION_END' ~/.claude/routing-audit.log || echo 0)"
  echo ""
  echo "Recent direct edits (potential policy violations):"
  grep 'DIRECT.*Edit\|Write\|MultiEdit' ~/.claude/routing-audit.log | tail -5 || echo "  None found"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi
```

### Full Log Location

```bash
echo ""
echo "📁 Full log file: ~/.claude/routing-audit.log"
echo ""
echo "View full log: cat ~/.claude/routing-audit.log"
echo "Search log: grep 'DIRECT' ~/.claude/routing-audit.log"
echo "Clear log: rm ~/.claude/routing-audit.log"
```

## Interpreting Results

**Log Format:**

```
TIMESTAMP | ROUTING_METHOD | TASK_TYPE | TOOL_USED | FILE_PATH
```

**Key Values:**

- `DIRECT` - Operation bypassed orchestrator (may violate policy)
- `ORCHESTRATOR` - Properly routed through orchestrator
- `SESSION_END` - Session completed

**Policy Violations:**
Look for entries like:

```
2025-11-04 16:30:15 | DIRECT | tool-use | Edit | /Users/you/.claude/agents/test.md
```

This indicates direct file editing that should have been routed through orchestrator.

## Actions

If you see policy violations:

1. Review the file paths to understand what was edited
2. Check if orchestrator routing was appropriate for that task
3. Consider updating validation patterns if false positive
4. Review with team if patterns indicate training needed

See `~/.claude/docs/ROUTING_SAFEGUARDS.md` for more details.
