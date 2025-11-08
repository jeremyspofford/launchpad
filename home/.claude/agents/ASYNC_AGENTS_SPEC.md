# Async Agent Execution Specification

## Overview

This specification defines how Claude Code agents can run asynchronously in the background, similar to how the Bash tool supports `run_in_background`. This enables long-running agent tasks to execute without blocking the main conversation flow.

## Use Cases

1. **Long-running scans**: Security scans, code analysis, comprehensive reviews
2. **Expensive operations**: Cost analysis across AWS accounts, multi-region infrastructure reviews
3. **Parallel workflows**: Run tests while implementing features, scan while documenting
4. **Background monitoring**: Keep diagnostic agents watching logs during development
5. **Multi-step deployments**: Deploy to multiple environments concurrently

## Architecture

### Storage Structure

Background agents require temporary storage for state and output:

```
~/.claude/tmp/agents/
├── agent-{timestamp}-{random}/
│   ├── metadata.json      # Agent metadata and status
│   ├── output.log         # Incremental output stream
│   ├── result.md          # Final result (when complete)
│   └── error.log          # Error output (if any)
```

**metadata.json structure:**

```json
{
  "agent_id": "agent-1730654321-abc",
  "subagent_type": "devsecops-scanner",
  "description": "Full security scan",
  "status": "running|completed|failed",
  "started_at": "2025-11-03T14:23:45Z",
  "completed_at": "2025-11-03T14:28:12Z",
  "working_directory": "/Users/user/project",
  "model": "haiku",
  "exit_code": 0,
  "progress": {
    "current_step": "Scanning files",
    "percent_complete": 65,
    "last_update": "2025-11-03T14:26:30Z"
  }
}
```

### Cleanup Policy

- Completed agent data retained for 24 hours
- Failed agent data retained for 48 hours (for debugging)
- Running agents terminated on session end (with warning)
- User can manually cleanup with `rm -rf ~/.claude/tmp/agents/agent-*`

## Tool Specifications

### 1. Task Tool (Extended)

**New Parameter: `run_in_background`**

```typescript
Task({
  subagent_type: "devsecops-scanner",
  description: "Full security scan",
  prompt: "Perform comprehensive security scan with --full flag",
  run_in_background: true,  // NEW: Run async
  model: "haiku"  // Optional: cheaper model for background work
})
```

**Returns (when `run_in_background: true`):**

```json
{
  "agent_id": "agent-1730654321-abc",
  "status": "running",
  "message": "Agent started in background. Use AgentOutput to check progress."
}
```

**Returns (when `run_in_background: false` or unset):**

```
[Normal synchronous agent response with full output]
```

### 2. AgentOutput Tool (NEW)

Retrieves output from a running or completed background agent.

**Parameters:**

```typescript
{
  agent_id: string,        // Required: The agent ID to check
  filter?: string          // Optional: Regex filter (like BashOutput)

}
```

**Example Usage:**

```typescript
AgentOutput({

  agent_id: "agent-1730654321-abc"
})
```

**Returns:**

```json
{
  "agent_id": "agent-1730654321-abc",
  "status": "running",
  "output": "[PROGRESS] Scanning 150 files...\n[PROGRESS] Found 3 issues...",
  "progress": {
    "current_step": "Analyzing authentication/",
    "percent_complete": 65,

    "last_update": "2025-11-03T14:26:30Z"
  }
}
```

**When Complete:**

```json
{
  "agent_id": "agent-1730654321-abc",
  "status": "completed",
  "exit_code": 0,

  "output": "[RESULT] Security scan complete.\n\n## Findings\n...",
  "completed_at": "2025-11-03T14:28:12Z",
  "duration_seconds": 267
}
```

**When Failed:**

```json
{
  "agent_id": "agent-1730654321-abc",

  "status": "failed",
  "exit_code": 1,
  "error": "Failed to access repository: Permission denied",
  "completed_at": "2025-11-03T14:25:10Z"
}
```

**Behavior:**

- Returns only NEW output since last check (like BashOutput)
- If `filter` provided, only matching lines returned
- Always includes current status and progress

### 3. ListAgents Tool (NEW)

Lists all background agents (running and recent completed).

**Parameters:**

```typescript
{
  status?: "running" | "completed" | "failed" | "all"  // Default: "all"
}

```

**Example Usage:**

```typescript
ListAgents()
// or
ListAgents({ status: "running" })
```

**Returns:**

```
Background Agents:

RUNNING:
  agent-1730654321-abc  devsecops-scanner    Full security scan (5m 23s)
  agent-1730654400-def  cost-analysis-agent  AWS cost analysis (2m 10s)

COMPLETED (last 24h):
  agent-1730650000-ghi  code-review-agent    Review API changes (completed 1h ago)
  agent-1730648000-jkl  test-runner-agent    Integration tests (completed 2h ago)


FAILED:
  agent-1730652000-mno  aws-infrastructure-expert  Deploy to prod (failed 45m ago)

Use AgentOutput(agent_id) to view output.
Use KillAgent(agent_id) to terminate running agents.
```

### 4. KillAgent Tool (NEW)

Terminates a running background agent.

**Parameters:**

```typescript
{
  agent_id: string  // Required: The agent ID to kill
}
```

**Example Usage:**

```typescript
KillAgent({ agent_id: "agent-1730654321-abc" })

```

**Returns:**

```json
{
  "agent_id": "agent-1730654321-abc",
  "killed": true,
  "status": "terminated",
  "output": "[PARTIAL OUTPUT] Scanned 89 of 150 files...",
  "message": "Agent terminated. Partial results available."
}
```

**Behavior:**

- Gracefully terminates agent process
- Preserves partial output for review
- Updates metadata.json with "terminated" status

## Agent Output Format Requirements

Agents running in background MUST follow this output protocol:

### Progress Updates

```markdown
[PROGRESS] Starting security scan...
[PROGRESS] Scanning directory: src/
[PROGRESS] Analyzing 150 files for vulnerabilities
[PROGRESS] Current: authentication/auth-service.ts (89/150)
```

### Progress Markers (Optional but Recommended)

```markdown
[PROGRESS:45] Halfway through file analysis
```

This allows the system to extract percentage completion.

### Final Results

```markdown
[RESULT] Security scan complete

## Summary
- Files scanned: 150
- Issues found: 3
- Severity: 1 high, 2 medium

## Detailed Findings
...
```

### Error Handling

```markdown
[ERROR] Failed to access file: permissions denied
[WARNING] Skipping binary file: dist/bundle.js
```

## Implementation Guidelines

### For Agent Developers

When creating/updating agents that may run in background:

1. **Emit Progress**: Use `[PROGRESS]` markers frequently
2. **Structured Output**: Clear sections with markdown headers
3. **Incremental Results**: Show results as they're found
4. **Error Handling**: Graceful failures with clear error messages
5. **Resume Capability**: Design agents to handle partial state

**Example: devsecops-scanner in background mode**

```markdown
[PROGRESS] Starting comprehensive security scan
[PROGRESS] Scanning for hardcoded secrets...
[PROGRESS:10] Completed secret scanning (0 issues found)
[PROGRESS] Scanning for dependency vulnerabilities...
[PROGRESS:30] Completed dependency scan (2 issues found)
[PROGRESS] Analyzing code patterns for security issues...
[PROGRESS:50] Scanning authentication patterns...
[PROGRESS:70] Scanning authorization checks...
[PROGRESS:90] Generating report...
[RESULT] Security scan complete

## Executive Summary
Scanned 150 files in 4m 23s
Found 5 issues (1 high, 2 medium, 2 low)

## Detailed Findings
[...]
```

### For Claude Code Core

Implementation requirements:

1. **Process Management**: Spawn agents as separate processes
2. **Output Streaming**: Capture stdout/stderr to output.log
3. **Status Tracking**: Update metadata.json as agent progresses
4. **Resource Limits**: Enforce timeouts (configurable, default 30min)
5. **Concurrent Limit**: Max N concurrent background agents (default 5)
6. **Cleanup Daemon**: Periodic cleanup of old agent data

## Usage Patterns

### Pattern 1: Fire and Forget

```typescript
// Start long scan, continue working
const scan = Task({
  subagent_type: "devsecops-scanner",
  prompt: "Full repository security scan",
  run_in_background: true,
  model: "haiku"
})

// ... work on other tasks ...

// Check results later
AgentOutput({ agent_id: scan.agent_id })
```

### Pattern 2: Parallel Agents

```typescript
// Launch multiple agents concurrently
const agents = [
  Task({
    subagent_type: "test-runner-agent",
    prompt: "Run full test suite",
    run_in_background: true
  }),
  Task({
    subagent_type: "code-review-agent",
    prompt: "Review recent changes",
    run_in_background: true
  }),
  Task({
    subagent_type: "security-auditor-agent",
    prompt: "Security audit",
    run_in_background: true
  })
]

// Continue working...

// Check all results
ListAgents({ status: "completed" })
```

### Pattern 3: Monitoring Progress

```typescript
// Start long operation
const deploy = Task({
  subagent_type: "aws-infrastructure-expert",
  prompt: "Deploy to all regions",
  run_in_background: true
})

// Poll for progress
while (true) {
  const status = AgentOutput({ agent_id: deploy.agent_id })
  if (status.status === "completed") break

  console.log(`Progress: ${status.progress.percent_complete}%`)
  // ... wait and check again ...
}
```

### Pattern 4: Background Monitoring

```typescript
// Start monitoring agent
const monitor = Task({
  subagent_type: "monitoring-agent",
  prompt: "Watch application logs for errors",
  run_in_background: true
})

// Let it run while you work on fixes
// ... implement features ...

// Check what it found
AgentOutput({ agent_id: monitor.agent_id })
```

## Configuration

### User Settings

Users should be able to configure:

```json
{
  "background_agents": {
    "max_concurrent": 5,
    "default_timeout_minutes": 30,
    "cleanup_after_hours": 24,
    "auto_kill_on_session_end": true,
    "notification_on_complete": true  // OS notification
  }
}
```

### Per-Agent Timeout Override

```typescript
Task({
  subagent_type: "cost-analysis-agent",
  prompt: "Analyze costs across all accounts",
  run_in_background: true,
  timeout_minutes: 60  // Override default 30min
})
```

## Error Handling

### Agent Timeout

After timeout, agent is killed and marked as failed:

```json
{
  "status": "failed",
  "error": "Agent exceeded timeout (30 minutes)",
  "output": "[PARTIAL] Last output before timeout..."
}
```

### Agent Crash

If agent process crashes:

```json
{
  "status": "failed",
  "exit_code": 139,
  "error": "Agent process crashed (SIGSEGV)",
  "output": "[Available output before crash]"
}
```

### Resource Exhaustion

If max concurrent agents reached:

```
Error: Maximum concurrent background agents reached (5/5)
Currently running:
- agent-123: devsecops-scanner (8m)
- agent-456: test-runner (3m)
...

Wait for an agent to complete or use KillAgent to terminate one.
```

## Security Considerations

1. **Isolation**: Background agents should not have elevated permissions
2. **Resource Limits**: CPU/memory limits to prevent resource exhaustion
3. **Audit Trail**: Log all background agent invocations
4. **Access Control**: Respect same tool permissions as foreground agents
5. **Output Sanitization**: Scrub secrets from logs before storage

## Future Enhancements

### Phase 2 Features

1. **Agent Dependencies**: Agent B waits for Agent A completion
2. **Agent Pipelines**: Chain agents in workflows
3. **Scheduled Agents**: Run agents on cron-like schedule
4. **Agent Pause/Resume**: Pause long-running agents
5. **Agent Checkpointing**: Save/restore agent state
6. **Collaborative Agents**: Multiple agents sharing context
7. **Agent Priority**: High-priority agents get resources first
8. **Web Dashboard**: View all background agents in browser

### Phase 3 Features

1. **Distributed Agents**: Run on remote compute
2. **Agent Pools**: Reusable agent instances
3. **Event-Driven Agents**: Trigger on file changes, webhooks, etc.
4. **Agent Marketplace**: Share agent configurations
5. **Multi-User Agents**: Shared agents across team

## Migration Path

### Existing Agents

All existing agents work unchanged. Background execution is **opt-in**:

```typescript
// Old way (still works)
Task({
  subagent_type: "code-review-agent",
  prompt: "Review changes"
})
// Blocks until complete, returns full output

// New way (opt-in)
Task({
  subagent_type: "code-review-agent",
  prompt: "Review changes",
  run_in_background: true  // NEW
})
// Returns agent_id immediately
```

### Agent Updates

Agents don't need modification to support background execution, but should be updated to:

1. Emit `[PROGRESS]` markers for better UX
2. Handle graceful termination (SIGTERM)
3. Produce incremental results
4. Include progress estimates

## Testing Strategy

### Test Cases

1. **Basic Background Execution**: Start agent, check output, verify completion
2. **Multiple Concurrent Agents**: Start 5 agents, verify all complete
3. **Agent Timeout**: Verify timeout enforcement and cleanup
4. **Agent Termination**: Kill running agent, verify graceful shutdown
5. **Output Filtering**: Test regex filtering like BashOutput
6. **Progress Tracking**: Verify progress percentage extraction
7. **Error Handling**: Test agent crashes, timeouts, resource limits
8. **Cleanup**: Verify old agent data is removed
9. **Session End**: Verify agents terminate on session end
10. **Resume After Crash**: Test agent recovery mechanisms

## Documentation Requirements

1. Update main CLAUDE.md with async agent patterns

2. Update agent-manager.md with background agent creation guidelines
3. Update each agent's README with background execution notes
4. Create user-facing docs on when/how to use background agents
5. Add troubleshooting guide for stuck/failed agents

## Success Metrics

- Agent execution time doesn't block user workflow
- Users can run 3+ agents concurrently without issues
- Background agents complete successfully >95% of the time
- Progress updates visible within 5 seconds of check
- Resource usage remains reasonable (CPU < 80%, memory < 2GB per agent)

## Implementation Priority

**P0 (MVP):**

- Task tool `run_in_background` parameter
- AgentOutput tool
- ListAgents tool
- Basic status tracking (running/completed/failed)
- Output streaming to logs

**P1 (Enhanced):**

- KillAgent tool
- Progress percentage extraction
- Timeout enforcement
- Concurrent agent limits
- Cleanup daemon

**P2 (Polish):**

- OS notifications on completion
- Progress bars in CLI
- Agent dependencies/pipelines
- Enhanced error recovery
- Performance optimizations
