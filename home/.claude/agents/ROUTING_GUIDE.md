# Agent Routing Guide

Quick reference for understanding how requests flow through the agent system.

## The Flow

```
User Request
     ↓
Main Claude Code LLM (reads CLAUDE.md)
     ↓
Decision: What type of task?
     ↓
     ├─ Simple task → Handle directly
     │
     ├─ Technical implementation/debugging → orchestrator-agent
     │        ↓
     │   orchestrator analyzes and decides:
     │        ├─ Which agents to call
     │        ├─ Sequential or parallel?
     │        ├─ What order?
     │        └─ What models to use?
     │        ↓
     │   orchestrator launches agents
     │        ├─ Sequential: one after another
     │        └─ Parallel: multiple Task calls in ONE message
     │        ↓
     │   Agents do their work and return results
     │        ↓
     │   orchestrator synthesizes results
     │        ↓
     │   orchestrator returns comprehensive report
     │
     └─ Project planning/management → project-manager
              ↓
         project-manager analyzes and:
              ├─ Breaks down features into tasks
              ├─ Estimates effort
              ├─ Identifies dependencies
              └─ Creates implementation plan
              ↓
         project-manager returns plan
              ↓
Main LLM presents to user
```

## Decision Matrix for Main LLM

| User Request | Main LLM Action | Reasoning |
|--------------|----------------|-----------|
| "Fix the API error" | Call `orchestrator-agent` | Technical: diagnose → fix → verify |
| "Deploy to production" | Call `orchestrator-agent` | Technical: needs parallel checks |
| "Implement authentication" | Call `orchestrator-agent` | Technical: multi-agent coordination |
| "Run pre-deployment checks" | Call `orchestrator-agent` | Technical: should run in parallel |
| "Analyze infrastructure costs" | Call `orchestrator-agent` | Technical: may involve multiple agents |
| "Plan the authentication feature" | Call `project-manager` | Planning: break down into tasks |
| "What should we work on next?" | Call `project-manager` | Planning: prioritization |
| "Create a roadmap for Q4" | Call `project-manager` | Planning: milestone planning |
| "How long will this feature take?" | Call `project-manager` | Planning: effort estimation |
| "Add this to the backlog" | Call `project-manager` | Planning: backlog management |
| "I want to build authentication" | Call both coordinators | Planning first, then implementation:<br>1. `project-manager` creates plan<br>2. `orchestrator-agent` implements |
| "Read src/api.ts" | Handle directly with `Read` | Simple, single action |
| "Run tests" | Could go either way | Simple: call `test-runner-agent`<br>Complex: call `orchestrator-agent` |
| "Use security-auditor-agent to scan" | Call `security-auditor-agent` | User explicitly named agent |

## What Orchestrator Decides

The orchestrator-agent has intelligence to decide:

### 1. Agent Selection

```typescript
User: "The API returns 500 errors"

orchestrator analyzes:
- Need to diagnose first
- Then fix based on diagnosis
- Then verify fix worked

orchestrator calls:
1. diagnostic-agent (finds root cause)
2. backend-agent (implements fix)
3. verification-agent (confirms working)
```

### 2. Execution Order (Sequential vs Parallel)

**Sequential (dependencies exist):**

```typescript
User: "Fix the database connection issue"

orchestrator decides:
- Must diagnose BEFORE fixing
- Must fix BEFORE verifying

Sequential execution:
1. diagnostic-agent → finds connection pool exhausted
2. database-agent → increases pool size
3. verification-agent → confirms connections work
```

**Parallel (no dependencies):**

```typescript
User: "Run pre-deployment validation"

orchestrator decides:
- Tests don't depend on review
- Review doesn't depend on security
- All can run simultaneously

Parallel execution (ONE message):
Task({ subagent_type: "test-runner-agent", ... })
Task({ subagent_type: "code-review-agent", ... })
Task({ subagent_type: "security-auditor-agent", ... })
Task({ subagent_type: "dependency-agent", ... })
```

### 3. Model Selection

```typescript
orchestrator decides per agent:

Long scans → haiku:
Task({
  subagent_type: "devsecops-scanner",
  model: "haiku"  // Cheaper for scanning
})

Complex decisions → sonnet:
Task({
  subagent_type: "architecture-agent",
  model: "sonnet"  // Needs intelligence
})
```

### 4. Result Synthesis

orchestrator combines agent outputs into coherent report:

**Instead of:**

```
diagnostic-agent found: [wall of text]
backend-agent did: [wall of text]
verification-agent says: [wall of text]

```

**orchestrator produces:**

```markdown
## Task: Fix API 500 Errors

### Root Cause
Database connection pool exhausted (max: 10, active: 10)

### Fix Applied
Increased pool size to 50 in database.ts:15

### Verification
✅ API responds with 200
✅ Connection pool usage: 12/50
✅ No errors in logs for 2 minutes

### Result: FIXED
API is now working correctly.
```

## When Main LLM Should NOT Use Orchestrator

**Simple, single-action tasks:**

```typescript
// User: "What's in src/api.ts?"
Read({ file_path: "/path/to/src/api.ts" })
// Don't need orchestrator for simple file read

// User: "Run this command: npm test"
Bash({ command: "npm test" })
// Don't need orchestrator for single command

// User: "Explain this error: [error message]"

[Explain directly]
// Don't need orchestrator for explanations
```

**User explicitly names agent:**

```typescript
// User: "Use the security-auditor-agent to scan for SQL injection"
Task({ subagent_type: "security-auditor-agent", ... })
// User knows what they want, call it directly
```

## What Project-Manager Decides

The project-manager has intelligence to decide:

### 1. Task Breakdown

```typescript
User: "I want to add user authentication"

project-manager analyzes:
- What components are needed?
- What dependencies exist?
- What's the logical order?

project-manager creates:
1. Database schema for users table
2. Backend: User model + auth service
3. Backend: Login/logout endpoints
4. Frontend: Login form component
5. Frontend: Auth state management
6. Testing: Auth flow tests
7. Documentation: Auth setup guide
```

### 2. Effort Estimation

```typescript
User: "How long will authentication take?"

project-manager estimates:
- Database setup: 2 hours
- Backend implementation: 8 hours
- Frontend implementation: 6 hours
- Testing: 4 hours
- Documentation: 2 hours
Total: ~3 days (22 hours)
```

### 3. Prioritization & Planning

```typescript
User: "What should we work on next?"

project-manager considers:
- Business value
- Dependencies
- Risk
- Team capacity

project-manager recommends:
1. High priority: Fix payment processing bug
2. Medium: Implement authentication (blocks other features)
3. Low: Add dark mode (nice-to-have)
```

### 4. Progress Tracking

```typescript
User: "What's the status of the authentication feature?"

project-manager reports:
✅ Database schema (completed)
✅ Backend auth service (completed)
🔄 Login endpoints (in progress, 60%)
⏳ Frontend login form (not started)
⏳ Testing (not started)
```

## Coordinator Collaboration

project-manager and orchestrator-agent can work together:

**Pattern: Plan → Implement**

```typescript
// Step 1: User requests feature
User: "I want to add authentication"

// Step 2: project-manager creates plan
Task({
  subagent_type: "project-manager",
  prompt: "Plan authentication feature"
})
// Returns: task breakdown, estimates, dependencies

// Step 3: orchestrator-agent implements plan
Task({
  subagent_type: "orchestrator-agent",
  prompt: "Implement authentication based on plan from project-manager"
})
// Executes: database → backend → frontend → tests → verification
```

## Benefits of This Architecture

### 1. Simplified Main LLM Logic

**Before:**

```typescript
// Main LLM has to decide everything:
- Which agents do I need?
- What order?

- Sequential or parallel?
- How do I combine results?
- How do I break down features?
- How do I estimate effort?
```

**After:**

```typescript
// Main LLM just decides:
- Is this technical? → Call orchestrator-agent

- Is this planning? → Call project-manager
- Is this simple? → Handle directly
- Let coordinators handle the rest
```

### 2. Consistent Workflows

**orchestrator-agent ensures technical best practices:**

- Always diagnose before fixing
- Always verify after changes
- Run independent checks in parallel
- Synthesize results coherently

**project-manager ensures planning best practices:**

- Break features into manageable tasks
- Identify dependencies before starting
- Provide realistic estimates
- Track progress systematically

### 3. Optimized Execution

orchestrator maximizes efficiency:

- Parallel execution when safe
- Sequential when dependencies exist
- Right model for each task
- Time estimates for user

### 4. Better User Experience

Users get:

- Single, coherent response (not multiple agent dumps)
- Time estimates before long operations
- Evidence-based results
- Clear next steps

## Example: Complete Flow

**User says:** "Deploy to production"

**1. Main LLM (reads CLAUDE.md):**

```typescript
// CLAUDE.md says: deployment → orchestrator-agent
Task({
  subagent_type: "orchestrator-agent",
  description: "Production deployment",
  prompt: "User wants to deploy to production. Run all pre-deployment checks and deploy if safe."

})
```

**2. orchestrator-agent receives request:**

```typescript
// orchestrator analyzes:
// - Need: tests + security + review + dependency check
// - These are independent → run in parallel
// - Then: if all pass → deploy
//         if any fail → stop and report

```

**3. orchestrator launches parallel checks:**

```typescript
// Single message with 4 Task calls:
Task({ subagent_type: "test-runner-agent", prompt: "Run full test suite" })
Task({ subagent_type: "security-auditor-agent", prompt: "Security scan" })

Task({ subagent_type: "code-review-agent", prompt: "Review recent changes" })
Task({ subagent_type: "dependency-agent", prompt: "Verify environment" })
```

**4. Agents execute in parallel** (8 min vs 20 min sequential)

**5. orchestrator receives all results:**

```
test-runner: ✅ 156/156 tests pass
security: ⚠️  2 medium issues found
code-review: ✅ Looks good
dependency: ✅ All dependencies satisfied
```

**6. orchestrator decides:**

```typescript
// Security issues exist → DO NOT DEPLOY
// orchestrator synthesizes report
```

**7. orchestrator returns to main LLM:**

```markdown
## Deployment Status: ❌ BLOCKED

### Pre-Deployment Check Results

✅ **Tests**: All 156 tests passing
⚠️  **Security**: 2 medium issues found
✅ **Code Review**: No issues
✅ **Dependencies**: All satisfied

### Security Issues Must Be Addressed

1. API endpoint /admin missing authentication (src/api/admin.ts:45)
2. SQL query using string concatenation (src/db/queries.ts:89)


### Recommendation
Fix security issues before deploying to production.

### Next Steps
1. Add authentication to /admin endpoint

2. Use parameterized queries in queries.ts
3. Re-run security scan
4. Deploy once all checks pass
```

**8. Main LLM presents to user**

Clean, actionable report with evidence.

## Summary

**Main LLM's job:**

- Route technical tasks to orchestrator-agent

- Route planning tasks to project-manager
- Handle simple tasks directly
- Present coordinator results to user

**orchestrator-agent's job:**

- Decide which agents to call
- Decide sequential vs parallel
- Launch agents efficiently
- Synthesize coherent results
- Provide evidence and recommendations

**project-manager's job:**

- Break down features into tasks
- Estimate effort and timeline
- Identify dependencies
- Track progress
- Prioritize work

**Specialized agents' job:**

- Do their specific technical work
- Return detailed findings
- Trust coordinators to coordinate

**Result:**

- Simple routing logic for main LLM
- Efficient parallel execution (orchestrator)
- Organized planning and tracking (project-manager)
- Coherent user experience
- Best practices enforced
