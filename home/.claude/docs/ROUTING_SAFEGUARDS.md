# Orchestrator-First Routing Safeguards

## Overview

This system enforces the orchestrator-first routing policy by validating tool usage and logging routing decisions.

## Components

### 1. Validation Hook (`validate-routing.sh`)

**Purpose**: Blocks direct technical edits that should go through orchestrator

**Behavior**:

- Checks `ROUTED_VIA_ORCHESTRATOR` environment variable
- If set to `1`, allows all operations (orchestrator has approved)
- If NOT set and operation is technical file edit, BLOCKS with error
- Returns exit code 1 to block, 0 to allow

**Technical File Patterns**:

- Code files: `.ts`, `.tsx`, `.js`, `.jsx`, `.py`
- Config files: `.json`, `.yaml`, `.yml`
- Documentation: `.md`
- Scripts: `.sh`, `.bash`
- Special directories: `agents/`, `scripts/`, `.claude/`

**Error Message**:
Clear instructions on how to route through orchestrator properly

### 2. Audit Log (`log-routing-decision.sh`)

**Purpose**: Track all routing decisions for analysis

**Log Format**:

```
TIMESTAMP | ROUTING_METHOD | TASK_TYPE | TOOL_USED | FILE_PATH
```

**Log Location**: `~/.claude/routing-audit.log`

**Example Entries**:

```
2025-11-04 14:23:15 | DIRECT | tool-use | Edit | /Users/name/.claude/agents/test.json
2025-11-04 14:25:30 | SESSION_END | session-complete | various |
```

### 3. Reviewing Audit Log

**View recent routing decisions**:

```bash
tail -50 ~/.claude/routing-audit.log
```

**Count direct vs orchestrator routing**:

```bash
grep "DIRECT" ~/.claude/routing-audit.log | wc -l
grep "ORCHESTRATOR" ~/.claude/routing-audit.log | wc -l
```

**Find blocked operations**:

```bash
# Blocked operations won't appear in log (they failed before execution)
# Check stderr output during session
```

## Integration with Orchestrator

### For orchestrator-agent

When spawning sub-agents, orchestrator MUST set environment variable:

```typescript
Task({
  subagent_type: "backend-agent",
  prompt: "...",
  env: {
    ROUTED_VIA_ORCHESTRATOR: "1"
  }
})
```

This tells validation hook to allow the operation.

### For Direct Users

If you're working directly (not through orchestrator), the hook will block technical edits:

**Wrong**:

```typescript
Edit({ path: "~/.claude/agents/test.json", ... })  // BLOCKED
```

**Right**:

```typescript
Task({
  subagent_type: "orchestrator-agent",
  description: "Update test agent",
  prompt: "Modify test agent to include new capability X"
})
```

## Emergency Bypass

**Only use in true emergencies** (system broken, need manual fix):

```bash
export ROUTED_VIA_ORCHESTRATOR=1
# Now direct edits will work
# Remember to unset after emergency fix
unset ROUTED_VIA_ORCHESTRATOR
```

## Troubleshooting

### False Positives

**Symptom**: Non-technical file blocked

**Solution**: Update `TECHNICAL_PATTERNS` in `validate-routing.sh` to exclude pattern

### Orchestrator Route Still Blocked

**Symptom**: Even with orchestrator, operations blocked

**Cause**: Environment variable not being passed to sub-agents

**Solution**: Verify orchestrator sets `ROUTED_VIA_ORCHESTRATOR=1` in Task calls

### Log File Growing Too Large

**Solution**: Rotate log file periodically

```bash
mv ~/.claude/routing-audit.log ~/.claude/routing-audit.$(date +%Y%m%d).log
gzip ~/.claude/routing-audit.*.log
```

## Testing

### Test Validation Hook

```bash
# Should block (no env var)
~/.claude/scripts/validate-routing.sh Edit ~/.claude/agents/test.json
echo $?  # Should be 1

# Should allow (env var set)
ROUTED_VIA_ORCHESTRATOR=1 ~/.claude/scripts/validate-routing.sh Edit ~/.claude/agents/test.json
echo $?  # Should be 0
```

### Test Audit Log

```bash
~/.claude/scripts/log-routing-decision.sh DIRECT test-run Edit /tmp/test.txt
cat ~/.claude/routing-audit.log | tail -1
```

## Maintenance

### Review Routing Patterns

Monthly review of audit log to identify:

- Frequent direct routing (should use orchestrator)
- Patterns of false positives
- Opportunities for better agent coordination

### Update Technical Patterns

As new file types are added to codebase, update `TECHNICAL_PATTERNS` array in `validate-routing.sh`
