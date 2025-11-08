---
description: Enable/disable emergency bypass for orchestrator-first routing validation
---

# Emergency Bypass for Routing Validation

Temporarily bypass orchestrator-first routing validation when system needs manual intervention.

## ⚠️ WARNING ⚠️

**Only use this in true emergencies:**

- Orchestrator system is broken and needs fixing
- Critical bug requires immediate manual fix
- Agent system is unresponsive

**Do NOT use for convenience.** The routing policy exists for good reasons.

## Task Instructions

### Check Current Status

First, check if bypass is currently active:

```bash
if [ -n "$ROUTED_VIA_ORCHESTRATOR" ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🟢 Emergency Bypass: ACTIVE"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Routing validation is currently bypassed."
  echo "Direct file edits are allowed."
  echo ""
  echo "To disable: /emergency-bypass off"
else
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔴 Emergency Bypass: INACTIVE"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Normal routing validation is active."
  echo "Technical edits require orchestrator routing."
  echo ""
  echo "To enable: /emergency-bypass on"
fi
```

### User Decision Required

Ask the user what they want to do:

- `on` - Enable emergency bypass
- `off` - Disable emergency bypass
- `status` - Check current status (already shown above)

Use AskUserQuestion tool to get user's choice.

### If User Chooses "on" - Enable Bypass

```bash
export ROUTED_VIA_ORCHESTRATOR=1
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Emergency Bypass ENABLED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⚠️  Routing validation is now bypassed for this session."
echo "⚠️  Direct file edits are allowed."
echo ""
echo "Remember to disable when emergency is resolved:"
echo "  /emergency-bypass off"
echo ""
echo "This bypass only affects the current Claude Code session."
echo "New sessions will have validation re-enabled."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

### If User Chooses "off" - Disable Bypass

```bash
unset ROUTED_VIA_ORCHESTRATOR
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Emergency Bypass DISABLED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Normal routing validation has been restored."
echo "Technical work must be routed through orchestrator-agent."
echo ""
echo "Use the orchestrator-first policy for all technical tasks:"
echo ""
echo "  Task({{"
echo "    subagent_type: \"orchestrator-agent\","
echo "    description: \"Brief description\","
echo "    prompt: \"[Your request here]\""
echo "  }})"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

## Usage Examples

### Enable bypass for emergency fix

```
User: /emergency-bypass
Claude: [Shows status, asks if you want to enable/disable/check status]
User: on
Claude: [Enables bypass, shows confirmation]
```

### Check if bypass is active

```
User: /emergency-bypass
Claude: [Shows current status]
User: status
Claude: [Confirms current state]
```

### Disable bypass after fix

```
User: /emergency-bypass
Claude: [Shows status]
User: off
Claude: [Disables bypass, confirms normal operation]
```

## Audit Trail

All bypass enable/disable actions should be logged. The user should manually note in the audit log why bypass was used:

```bash
~/.claude/scripts/log-routing-decision.sh 'EMERGENCY_BYPASS_ENABLED' 'manual-intervention' 'bypass' 'User initiated emergency bypass'
```

When disabled:

```bash
~/.claude/scripts/log-routing-decision.sh 'EMERGENCY_BYPASS_DISABLED' 'manual-intervention' 'bypass' 'User disabled emergency bypass'
```

## Recovery

If you forget to disable bypass and start a new session, don't worry:

- Environment variables don't persist across sessions
- New sessions automatically have validation enabled
- No permanent damage from forgetting to disable

## See Also

- View audit log: `/audit-log`
- Routing safeguards documentation: `~/.claude/docs/ROUTING_SAFEGUARDS.md`
- Main configuration: `~/.claude/CLAUDE.md`
