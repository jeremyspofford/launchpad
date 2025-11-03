# Claude Code Agents

## Overview

This directory contains a hierarchical agent system where **you only talk to the ORCHESTRATOR**, which manages all sub-agents autonomously.

## Architecture

```txt
YOU (User)
  ↓
  ┌─────────────────────────────────────────────┐
  │ PROJECT-MANAGER (task/feature/timeline mgmt)│
  │   - What to build & when                    │
  │   - Reduces context load on orchestrator    │
  └─────────────────────┬───────────────────────┘
                        ↓
  ┌─────────────────────────────────────────────┐
  │ ORCHESTRATOR (workflow coordination)        │
  │   - How to build it                         │
  │   - Delegates to sub-agents                 │
  └─────────────────────┬───────────────────────┘
                        ↓
  ├── Core Agents (workflow management)
  │   ├── diagnostic-agent (runs FIRST - finds root causes)
  │   ├── verification-agent (runs LAST - proves it works)
  │   └── process-manager-agent (manages servers/processes)
  │
  ├── Specialized Domain Agents
  │   ├── frontend-agent (React/Next.js/UI)
  │   ├── backend-agent (Node/Express/API)
  │   ├── database-agent (Prisma/schema/migrations)
  │   ├── monitoring-agent (logs/metrics/health)
  │   ├── architecture-agent (system design)
  │   └── documentation-agent (README/docs)
  │
  └── System Agents (meta-level)
      ├── agent-manager (manages agents themselves)
      ├── code-review-agent (security/quality)
      ├── test-runner-agent (runs tests)
      └── dependency-agent (env validation)

```

## How to Use

You can talk to **project-manager** OR **orchestrator**:

**Talk to project-manager for:**

- "What should we work on next?"
- "Add authentication to the backlog"
- "What's our project status?"
- "Show me the roadmap"
- Feature planning & task management

**Talk to orchestrator for:**

- "Fix this bug"
- "Implement dark mode"
- "Debug why API is broken"
- Technical implementation & coordination

### Example: Project-Manager Workflow

**You:** "Project-manager, what should we work on next?"

**Project-manager:**

1. Reviews current tasks and backlog
2. Prioritizes work
3. Recommends next steps
4. Delegates technical work to orchestrator
5. Tracks progress

### Example: Orchestrator Workflow

**You:** "Orchestrator, the API isn't working."

**Orchestrator:**

1. Calls diagnostic-agent to find root cause
2. Calls process-manager-agent to restart services
3. Calls verification-agent to prove fix works
4. Reports back to you (or project-manager) with evidence

## Agent Roles

### 1. Orchestrator Agent (`orchestrator-agent.md`)

**YOUR MAIN INTERFACE** - The only agent you talk to.

**What it does:**

- Receives your requests
- Analyzes what needs to be done
- Delegates to appropriate sub-agents in correct order
- Synthesizes their reports
- Returns ONE comprehensive response

**Example Flow:**

```txt
You: "Something's broken"
↓
Orchestrator analyzes → Calls diagnostic-agent
↓
Diagnostic reports: "Old backend process from 16:59 still running"
↓
Orchestrator decides → Calls process-manager-agent
↓
Process Manager: Kills old (PID 52959), starts new (PID 69420)
↓
Orchestrator decides → Calls verification-agent
↓
Verification: curl test shows API returns data
↓
Orchestrator reports to YOU:
  ✅ Fixed - old process killed, new one works
  Evidence: [curl output showing 253 reps]

```

### 2. Diagnostic Agent (`diagnostic-agent.md`)

**ALWAYS RUNS FIRST** for any "not working" issue.

**What it does:**

- Checks what processes are running
- Reviews logs for errors
- Tests endpoints directly
- Compares file timestamps vs process start times
- **Identifies root cause with evidence**

**Example output:**

```txt
Root Cause: Backend PID 52959 started at 16:59,
but code changes were at 17:04.
Old server still serving outdated code.

Recommended: Call process-manager-agent to restart.

```

### 3. Verification Agent (`verification-agent.md`)

**ALWAYS RUNS LAST** to prove fixes actually work.

**What it does:**

- Tests endpoints with curl
- Checks logs for successful requests
- Verifies process state
- **Provides proof, not assumptions**

**Example output:**

```txt
✅ VERIFIED: curl shows 253 representatives
✅ VERIFIED: Backend PID 69420 running on port 5001
⚠️ UNCERTAIN: Frontend needs hard refresh (no requests in logs)

```

### 4. Process Manager Agent (`process-manager-agent.md`)

**Manages all running processes cleanly.**

**What it does:**

- Kills old/duplicate processes
- Starts fresh servers
- Verifies services started correctly
- Reports what's running where

**Example output:**

```txt
Killed: PID 52959, 49386, 41279 (old backends)
Started: PID 69420 (backend on 5001)
Started: PID 69421 (frontend on 3003)
Health Check: ✅ All services running

```

### 5. Test Runner Agent (`test-runner-agent.md`)

**Runs tests and reports failures with fixes.**

**What it does:**

- Runs unit, integration, e2e tests
- Collects failures with stack traces
- Analyzes failure patterns
- Suggests specific fixes

**Example output:**

```txt
Tests: 148/156 passing (8 failures)

Failed: GET /representatives/:id
Cause: Test using hardcoded ID not in DB
Fix: Use dynamic ID from seed data

Failed: Representatives page load
Cause: Missing null check on name.full
Fix: Add `rep.name?.full || 'Unknown'`

```

### 6. Code Review Agent (`code-review-agent.md`)

**Reviews code BEFORE commit/deploy.**

**What it does:**

- Scans for security issues (SQL injection, exposed secrets)
- Finds common mistakes (null checks, error handling)
- Checks performance (N+1 queries, memory leaks)
- Validates best practices

**Example output:**

```txt
🔴 HIGH: SQL injection risk at routes/reps.js:45
🔴 HIGH: Exposed API key at config/api.js:12
🟡 MEDIUM: Missing null check at index.jsx:160
🟢 LOW: Unused import at index.jsx:4

Must fix before deploy: 2 high severity issues

```

### 7. Dependency Agent (`dependency-agent.md`)

**Validates environment setup.**

**What it does:**

- Checks package versions
- Validates environment variables
- Verifies configuration consistency
- Detects port conflicts

**Example output:**

```txt
✅ Node v20.10.0 (required: v18+)
✅ All packages installed
❌ REDIS_URL not set
⚠️ Port config mismatch: Backend=5001, Frontend API=5000

Health Score: 75/100 (Good, minor issues)

Action: Set REDIS_URL in backend .env

```

## How Agents Are Triggered

Agents are called using the `Task` tool:

```typescript
Task({
  subagent_type: "verification-agent",
  description: "Verify backend API changes",
  prompt: "Verify that the representatives API endpoint returns data after my code changes. Check: 1) Which process is running on port 5001, 2) When it started vs file modification times, 3) curl test the endpoint, 4) Check logs for errors"
})

```

## Creating New Agents

To create a new agent:

1. Create `[agent-name].md` in this directory
2. Include sections:
   - **Purpose** - What this agent does
   - **When to Use** - Trigger conditions
   - **What It Does** - Actions it takes
   - **Checklist** - Specific commands to run
   - **Output Format** - Structure of report

3. Document it in this README

## Agent Design Principles

### 1. Evidence Over Assumptions

Agents must gather concrete evidence (logs, outputs, process states) rather than making assumptions.

### 2. Structured Output

Agents return formatted reports with clear sections:

- What was checked
- Evidence found
- Verified facts
- Unverified items
- Next steps

### 3. Cost Consciousness

Agents should minimize token usage by:

- Running specific diagnostic commands
- Returning only relevant evidence
- Avoiding redundant checks

### 4. Single Responsibility

Each agent has one clear job. Don't create "do everything" agents.

### 8. Frontend Agent (`frontend-agent.md`)

**React/Next.js UI specialist.**

**What it does:**

- Build/modify React components
- Fix frontend bugs
- Implement UI/UX designs
- State management (hooks, context)
- Next.js routing and SSR
- Tailwind CSS styling
- Theme system integration

### 9. Backend Agent (`backend-agent.md`)

**Node.js/Express API specialist.**

**What it does:**

- Create/modify API endpoints
- Prisma database queries
- Authentication & authorization
- Middleware implementation
- Error handling & validation
- API response formatting

### 10. Database Agent (`database-agent.md`)

**Prisma schema & migration specialist.**

**What it does:**

- Design database schema
- Create migrations
- Optimize queries
- Add indexes
- Set up relations
- Database seeding

### 11. Monitoring Agent (`monitoring-agent.md`)

**Logs, metrics, and system health specialist.**

**What it does:**

- Analyze application logs
- Track performance metrics
- Monitor resource usage
- Identify error patterns
- Check API response times
- Database performance analysis

### 12. Architecture Agent (`architecture-agent.md`)

**System design and patterns specialist.**

**What it does:**

- Design new features
- Refactor code structure
- Make technology choices
- API design decisions
- Scalability planning
- Code organization

### 13. Documentation Agent (`documentation-agent.md`)

**Technical writing specialist.**

**What it does:**

- Write README files
- Create API documentation
- Document architecture
- Add code comments
- Write user guides
- Create troubleshooting guides

### 14. Project Manager (`project-manager.md`)

**High-level coordinator for task management, feature planning, and timelines.**

**What it does:**

- Track tasks, todos, features
- Manage project work and timelines
- Reduce context load on orchestrator
- Delegate technical work to orchestrator
- Provide project status reports
- Prioritize work

**Position:** Sits ABOVE orchestrator in hierarchy

### 15. Agent Manager (`agent-manager.md`)

**Meta-agent that manages the agent system itself.**

**What it does:**

- Create new agents
- Modify existing agents
- Update agent documentation
- Maintain README.md
- Update CLAUDE.md
- Optimize agent system

### 16. Cost Analysis Agent (`cost-analysis-agent.md`)

**Cost analysis and optimization specialist.**

**What it does:**

- Review infrastructure and resource usage
- Estimate monthly operational costs
- Identify cost optimization opportunities
- Analyze deployment targets and pricing
- Provide cost-cutting recommendations
- Project cost growth scenarios

**Use when:**

- Before deploying to production
- Planning infrastructure changes
- Budget concerns arise
- Quarterly cost audits needed

### 17. Infrastructure Security Agent (`infrastructure-security-agent.md`)

**Infrastructure security specialist.**

**What it does:**

- Review infrastructure-as-code for security issues
- Validate network configurations
- Audit encryption settings (at rest and in transit)
- Check IAM policies and access controls
- Identify publicly exposed services
- Recommend security best practices

**Use when:**

- Before deploying to production
- Reviewing infrastructure changes
- During security audits
- After security incidents

### 18. Security Auditor Agent (`security-auditor-agent.md`)

**Comprehensive security auditor (code + infrastructure).**

**What it does:**

- Scan code for vulnerabilities (SQL injection, XSS, etc.)
- Audit authentication and authorization
- Review secrets management
- Check for hardcoded credentials
- Scan dependencies for vulnerabilities
- Audit infrastructure security configurations
- Provide detailed remediation guidance

**Use when:**

- Before deploying to production
- After significant code changes
- During security reviews
- When vulnerability reported

### 19. Git Workflow Expert Agent (`git-workflow-expert-agent.md`)

**Git workflow and CI/CD specialist.**

**What it does:**

- Review code changes and patterns
- Design branching strategies (GitFlow, GitHub Flow)
- Create/optimize GitLab CI or GitHub Actions pipelines
- Add security scanning to CI/CD
- Implement deployment automation
- Optimize build performance with caching and parallelization

**Use when:**

- Setting up new project CI/CD
- After significant code changes
- When build times are slow
- Adding new services or dependencies
- Deployment pipeline needs improvement

## Agent Collaboration Patterns

**Agents can now work together when it benefits problem-solving.** Each agent has a "Collaboration with Other Agents" section that explains when to call other agents.

### Common Collaboration Workflows

#### 1. Debug & Fix Workflow

```txt
diagnostic-agent (find root cause)
  ↓
process-manager-agent (restart services if needed)
  ↓
verification-agent (prove fix works)

```

**Example**: Representatives page not loading

- diagnostic-agent identifies old frontend process
- process-manager-agent restarts frontend
- verification-agent tests page loads correctly

#### 2. Feature Development Workflow

```txt
database-agent (schema changes)
  ↓
backend-agent (API endpoints)
  ↓
frontend-agent (UI components)
  ↓
verification-agent (end-to-end testing)

```

**Example**: Adding search feature

- database-agent adds search indexes
- backend-agent creates `/api/search` endpoint
- frontend-agent builds SearchBar component
- verification-agent tests search works

#### 3. Performance Optimization Workflow

```txt
monitoring-agent (identify bottleneck)
  ↓
database-agent (optimize queries) + backend-agent (improve API)
  ↓
verification-agent (measure improvement)

```

**Example**: Slow API responses

- monitoring-agent finds slow queries
- database-agent adds indexes
- backend-agent optimizes query logic
- verification-agent confirms performance improved

#### 4. Security Review Workflow

```txt
code-review-agent (find vulnerabilities)
  ↓
backend-agent (fix security issues) OR frontend-agent (fix XSS)
  ↓
test-runner-agent (regression testing)
  ↓
verification-agent (confirm security fix)

```

**Example**: SQL injection risk found

- code-review-agent identifies vulnerability
- backend-agent implements parameterized queries
- test-runner-agent runs security tests
- verification-agent proves fix works

#### 5. Deployment Readiness Workflow

```txt
dependency-agent (validate environment)
  ↓
test-runner-agent (all tests pass)
  ↓
code-review-agent (quality check)
  ↓
verification-agent (final smoke test)

```

**Example**: Preparing for production deploy

- dependency-agent checks all packages/env vars
- test-runner-agent confirms all tests pass
- code-review-agent reviews recent changes
- verification-agent does final API tests

### Key Collaboration Principles

1. **Agents delegate expertise** - When an agent encounters something outside its domain, it calls the appropriate specialist
2. **Evidence flows between agents** - One agent's findings inform the next agent's work
3. **Workflows can be parallel or sequential** - Independent work happens in parallel, dependent work happens sequentially
4. **No infinite loops** - Agents don't call themselves, and collaboration has clear termination
5. **Always verify** - verification-agent runs last to prove work succeeded

### Collaboration Examples

**diagnostic-agent calling monitoring-agent:**

```txt
Found errors in backend logs, but pattern unclear.
Calling monitoring-agent to analyze error frequency and correlation with events.

```

**backend-agent calling frontend-agent:**

```txt
Implemented search API endpoint at `/api/representatives/search`.
Calling frontend-agent to integrate endpoint into SearchBar component.

```

**verification-agent calling diagnostic-agent:**

```txt
Verification failed: API returns 500 error.
Calling diagnostic-agent to find new root cause.

```

## Future Agent Ideas

Potential agents to create:

- **security-scanner** - Dedicated security vulnerability scanning
- **performance-profiler** - Deep performance analysis and optimization
- **deployment-verifier** - Confirms deployment success and rollback if needed
- **docker-agent** - Container and Docker Compose specialist

## Integration with CLAUDE.md

The rules in `CLAUDE.md` reference these agents:

- Rule 2 requires verification before claiming completion
- Rule 7 emphasizes cost awareness
- Golden Rule: Diagnose → Fix → Verify (agents help with verify step)

## Troubleshooting

**Agent not being called:**

- Check if trigger conditions in agent docs match the scenario
- Verify Claude has access to Task tool
- Review CLAUDE.md rules to ensure they reference the agent

**Agent returns insufficient evidence:**

- Update agent's checklist with more specific commands
- Add examples of expected output format
- Clarify what "verified" vs "not verified" means

**Too expensive:**

- Reduce number of diagnostic commands in checklist
- Focus on most critical checks only
- Use head/tail to limit log output
