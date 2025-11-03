# Async Agent Workflow Examples

Real-world examples of using background agents for improved productivity.

## Example 1: Security Audit While Developing

**Scenario**: You're implementing a new API feature and want a comprehensive security audit without blocking your work.

```typescript
// Morning: Start comprehensive security scan
const securityScan = Task({
  subagent_type: "devsecops-scanner",
  description: "Full repository security scan",
  prompt: "Perform comprehensive security scan with --full flag. Check for secrets, vulnerabilities, insecure patterns, and dependency issues.",
  run_in_background: true,
  model: "haiku"  // Cheaper model for background work
})

console.log(`Security scan started: ${securityScan.agent_id}`)

// Continue implementing your feature
// ... work on API endpoints, write tests, etc ...

// Lunch time: Check progress
AgentOutput({ agent_id: securityScan.agent_id })
// [PROGRESS:75] Analyzing dependency vulnerabilities...

// Afternoon: Scan complete, review results
const results = AgentOutput({ agent_id: securityScan.agent_id })
// [RESULT] Security scan complete. 5 issues found (2 high, 3 medium)

// Address findings before deploying
```

**Benefits:**
- Don't wait 10-15 minutes for security scan
- Scan runs while you're productive
- Results ready when you need them

---

## Example 2: Parallel Pre-Deployment Checks

**Scenario**: Before deploying, you want comprehensive validation across multiple dimensions.

```typescript
// Launch all pre-deployment checks in parallel
const agents = [
  Task({
    subagent_type: "test-runner-agent",
    description: "Run full test suite",
    prompt: "Execute complete test suite including unit, integration, and e2e tests. Report all failures with stack traces.",
    run_in_background: true
  }),
  Task({
    subagent_type: "code-review-agent",
    description: "Review recent changes",
    prompt: "Review all changes since last deployment. Focus on security, performance, and code quality.",
    run_in_background: true
  }),
  Task({
    subagent_type: "security-auditor-agent",
    description: "Security audit",
    prompt: "Audit authentication, authorization, data validation, and potential injection vulnerabilities.",
    run_in_background: true
  }),
  Task({
    subagent_type: "dependency-agent",
    description: "Validate environment",
    prompt: "Verify all dependencies, environment variables, and system requirements are satisfied.",
    run_in_background: true
  })
]

console.log("4 pre-deployment checks running in background...")

// Continue preparing deployment scripts, updating docs, etc.

// Check all agents
ListAgents()
// agent-test [running]     test-runner-agent (3m 45s)
// agent-review [complete]  code-review-agent (completed 2m ago)
// agent-sec [running]      security-auditor-agent (4m 12s)
// agent-deps [complete]    dependency-agent (completed 4m ago)

// Wait for remaining agents
// ... once all complete ...

// Review all results
agents.forEach(agent => {
  const result = AgentOutput({ agent_id: agent.agent_id })
  console.log(`${agent.description}: ${result.status}`)
})

// Make go/no-go decision based on results
```

**Benefits:**
- 4 checks run concurrently instead of sequentially (15min → 5min)
- Deploy with confidence knowing everything was validated
- Can address issues while other checks continue

---

## Example 3: Multi-Region AWS Cost Analysis

**Scenario**: Analyze AWS costs across all regions and accounts to find optimization opportunities.

```typescript
// Start comprehensive cost analysis (can take 20-30 minutes)
const costAnalysis = Task({
  subagent_type: "cost-analysis-agent",
  description: "AWS cost analysis - all accounts",
  prompt: `
    Analyze AWS costs across:
    - All linked accounts in organization
    - All regions
    - Last 3 months of data
    - Identify top 10 cost drivers
    - Find optimization opportunities (unused resources, right-sizing, etc.)
    - Estimate potential savings
  `,
  run_in_background: true,
  timeout_minutes: 45  // Override default timeout
})

console.log(`Cost analysis started: ${costAnalysis.agent_id}`)

// Work on other tasks - feature development, bug fixes, etc.

// Check progress periodically
AgentOutput({ agent_id: costAnalysis.agent_id })
// [PROGRESS:30] Analyzed us-east-1, us-west-2 (2 of 8 regions)
// [PROGRESS:60] Completed regional analysis, analyzing account patterns
// [PROGRESS:85] Identifying optimization opportunities

// Eventually get complete report
const report = AgentOutput({ agent_id: costAnalysis.agent_id })
// [RESULT] Cost analysis complete. Found $45,000/month in potential savings
```

**Benefits:**
- Don't block 30+ minutes waiting for cost analysis
- Run analysis during development, review during planning
- Use cheaper haiku model for cost-effective background work

---

## Example 4: Background Log Monitoring During Development

**Scenario**: Keep a monitoring agent watching application logs while you develop and fix issues.

```typescript
// Start monitoring agent at beginning of debug session
const monitor = Task({
  subagent_type: "monitoring-agent",
  description: "Watch application logs",
  prompt: `
    Monitor application logs in real-time. Watch for:
    - ERROR and WARN level messages
    - Stack traces
    - Performance degradation
    - API errors (4xx, 5xx)

    Report significant patterns or spikes.
  `,
  run_in_background: true,
  timeout_minutes: 120  // Let it run for 2 hours
})

// Implement fixes, make changes, restart services
// ... development work ...

// Periodically check what monitor has found
AgentOutput({
  agent_id: monitor.agent_id,
  filter: "ERROR|CRITICAL"  // Only show serious issues
})

// After implementing fix, check if errors stopped
AgentOutput({ agent_id: monitor.agent_id })
// [PROGRESS] Monitoring for 45 minutes. Detected 3 error patterns:
// 1. AuthenticationError: Invalid token (23 occurrences, stopped at 14:35)
// 2. DatabaseConnectionError (5 occurrences, stopped at 14:42)
// 3. ValidationError: Missing required field (ongoing, 8 occurrences)

// Kill monitor when debug session complete
KillAgent({ agent_id: monitor.agent_id })
```

**Benefits:**
- Continuous monitoring without manual log tailing
- Pattern detection across development session
- Verify fixes by seeing errors stop
- Focus on coding, not log watching

---

## Example 5: Staged Deployment with Verification

**Scenario**: Deploy to multiple environments sequentially, with verification after each.

```typescript
// Deploy to dev, stage, prod in sequence
// Each deployment runs in background with verification

// 1. Deploy to dev
const devDeploy = Task({
  subagent_type: "aws-infrastructure-expert",
  description: "Deploy to dev",
  prompt: "Deploy application stack to dev environment. Run smoke tests after deployment.",
  run_in_background: true
})

// Start working on next feature while deploy runs
// ...

// Wait for dev completion
let devResult = AgentOutput({ agent_id: devDeploy.agent_id })
while (devResult.status === "running") {
  await sleep(30000)  // Check every 30 seconds
  devResult = AgentOutput({ agent_id: devDeploy.agent_id })
}

if (devResult.status === "completed" && devResult.exit_code === 0) {
  // 2. Deploy to stage
  const stageDeploy = Task({
    subagent_type: "aws-infrastructure-expert",
    description: "Deploy to stage",
    prompt: "Deploy application stack to stage environment. Run smoke tests.",
    run_in_background: true
  })

  // Continue working...

  // Wait for stage completion
  let stageResult = AgentOutput({ agent_id: stageDeploy.agent_id })
  while (stageResult.status === "running") {
    await sleep(30000)
    stageResult = AgentOutput({ agent_id: stageDeploy.agent_id })
  }

  if (stageResult.status === "completed") {
    // 3. Deploy to prod
    const prodDeploy = Task({
      subagent_type: "aws-infrastructure-expert",
      description: "Deploy to production",
      prompt: "Deploy application stack to PRODUCTION. Execute deployment checklist.",
      run_in_background: true
    })

    // Monitor production deployment closely
    while (true) {
      const prodResult = AgentOutput({ agent_id: prodDeploy.agent_id })
      console.log(`Prod deployment: ${prodResult.progress.current_step}`)

      if (prodResult.status !== "running") break
      await sleep(10000)  // Check every 10 seconds for prod
    }
  }
}

// View deployment summary
ListAgents({ status: "completed" })
```

**Benefits:**
- Deploy to multiple environments without babysitting
- Work on other tasks between deployments
- Automatic progression with verification
- Quick feedback if issues arise

---

## Example 6: Code Review During Feature Implementation

**Scenario**: Get continuous code review feedback while implementing a large feature.

```typescript
// Implement feature over several hours/days
// Run periodic background code reviews to catch issues early

// After implementing auth layer
const authReview = Task({
  subagent_type: "code-review-agent",
  description: "Review authentication changes",
  prompt: "Review authentication implementation for security issues, best practices, and code quality.",
  run_in_background: true
})

// Continue implementing API endpoints
// ...

// After implementing API layer
const apiReview = Task({
  subagent_type: "code-review-agent",
  description: "Review API endpoints",
  prompt: "Review API endpoint implementation for RESTful design, error handling, validation, and documentation.",
  run_in_background: true
})

// Continue implementing database layer
// ...

// After implementing database layer
const dbReview = Task({
  subagent_type: "code-review-agent",
  description: "Review database changes",
  prompt: "Review database schema, migrations, and queries for performance, indexes, and data integrity.",
  run_in_background: true
})

// Check all reviews
ListAgents({ status: "completed" })

// Address feedback incrementally
[authReview, apiReview, dbReview].forEach(review => {
  const feedback = AgentOutput({ agent_id: review.agent_id })
  console.log(feedback.output)
  // Address issues while context is fresh
})
```

**Benefits:**
- Catch issues early in development cycle
- Get feedback while context is fresh
- Incremental reviews easier than monolithic end review
- Keep moving forward while reviews run

---

## Example 7: Parallel Infrastructure Analysis

**Scenario**: Analyze infrastructure from multiple perspectives simultaneously.

```typescript
// Comprehensive infrastructure assessment
const analyses = [
  Task({
    subagent_type: "security-auditor-agent",
    description: "Infrastructure security audit",
    prompt: "Audit AWS infrastructure for security best practices: IAM, networking, encryption, logging.",
    run_in_background: true
  }),
  Task({
    subagent_type: "cost-analysis-agent",
    description: "Cost optimization analysis",
    prompt: "Identify cost optimization opportunities: unused resources, right-sizing, reserved instances.",
    run_in_background: true
  }),
  Task({
    subagent_type: "infrastructure-security-agent",
    description: "Compliance check",
    prompt: "Check infrastructure compliance with SOC2, HIPAA, and company security policies.",
    run_in_background: true
  }),
  Task({
    subagent_type: "aws-infrastructure-expert",
    description: "Architecture review",
    prompt: "Review architecture for scalability, reliability, and best practices. Suggest improvements.",
    run_in_background: true
  })
]

console.log("4 infrastructure analyses running...")

// Wait for all to complete
// Use this time for other work

// Generate comprehensive report
console.log("## Infrastructure Assessment")
analyses.forEach(analysis => {
  const result = AgentOutput({ agent_id: analysis.agent_id })
  console.log(`\n### ${analysis.description}`)
  console.log(result.output)
})
```

**Benefits:**
- 4 perspectives analyzed in parallel (60min → 15min)
- Comprehensive assessment without sequential delays
- Each agent specializes in their domain
- Combined insights for better decision-making

---

## Example 8: Test-Driven Development with Background Tests

**Scenario**: Write tests, run them in background while implementing features.

```typescript
// TDD workflow with background test execution

// 1. Write failing tests
// ... write test cases ...

// 2. Run tests in background
const testRun1 = Task({
  subagent_type: "test-runner-agent",
  description: "Run tests - iteration 1",
  prompt: "Run all tests. Expect failures for new features.",
  run_in_background: true
})

// 3. Implement feature
// ... write implementation ...

// 4. Check test results
const results1 = AgentOutput({ agent_id: testRun1.agent_id })
// 15 tests failed (expected)

// 5. Run tests again in background
const testRun2 = Task({
  subagent_type: "test-runner-agent",
  description: "Run tests - iteration 2",
  prompt: "Run all tests. Check if new implementation fixes failing tests.",
  run_in_background: true
})

// 6. Refactor while tests run
// ... improve code quality ...

// 7. Check test results
const results2 = AgentOutput({ agent_id: testRun2.agent_id })
// 8 tests still failing

// 8. Fix remaining issues
// ... debug and fix ...

// 9. Final test run
const testRun3 = Task({
  subagent_type: "test-runner-agent",
  description: "Run tests - final",
  prompt: "Run all tests. Verify all tests pass.",
  run_in_background: true
})

// 10. Verify success
const results3 = AgentOutput({ agent_id: testRun3.agent_id })
// All tests passing ✅
```

**Benefits:**
- Tests run while you write code
- Faster feedback loop
- No context switching waiting for tests
- Encourages running tests frequently

---

## Pro Tips for Async Agents

### 1. Use Cheaper Models for Background Work

```typescript
// Background tasks don't need Sonnet 4.5
Task({
  subagent_type: "devsecops-scanner",
  prompt: "Scan for secrets",
  run_in_background: true,
  model: "haiku"  // Much cheaper, still effective
})
```

### 2. Set Appropriate Timeouts

```typescript
// Quick tasks: shorter timeout
Task({
  subagent_type: "code-review-agent",
  prompt: "Review small change",
  run_in_background: true,
  timeout_minutes: 5
})

// Long tasks: longer timeout
Task({
  subagent_type: "cost-analysis-agent",
  prompt: "Analyze entire organization",
  run_in_background: true,
  timeout_minutes: 60
})
```

### 3. Filter Output for Relevant Information

```typescript
// Only show errors and warnings
AgentOutput({
  agent_id: "agent-123",
  filter: "ERROR|WARN|CRITICAL"
})

// Only show progress updates
AgentOutput({
  agent_id: "agent-456",
  filter: "\\[PROGRESS"
})
```

### 4. Kill Stuck Agents

```typescript
// If agent seems stuck or taking too long
ListAgents({ status: "running" })
// agent-abc running for 45 minutes (expected 10)

KillAgent({ agent_id: "agent-abc" })
// Review partial output to understand what went wrong
```

### 5. Name Agents Descriptively

```typescript
// Bad: generic description
Task({
  subagent_type: "security-auditor-agent",
  description: "Security check",  // ❌ Not helpful
  run_in_background: true
})

// Good: specific description
Task({
  subagent_type: "security-auditor-agent",
  description: "Security audit - payment API v2",  // ✅ Clear
  run_in_background: true
})
```

### 6. Check Status Before Starting Duplicates

```typescript
// Don't start duplicate agents
ListAgents({ status: "running" })
// If security scan already running, don't start another

// Check first
const runningAgents = ListAgents({ status: "running" })
if (!runningAgents.includes("devsecops-scanner")) {
  Task({
    subagent_type: "devsecops-scanner",
    prompt: "Full scan",
    run_in_background: true
  })
}
```

---

## When NOT to Use Background Agents

**Don't use background execution for:**

1. **Quick tasks** (<30 seconds) - overhead not worth it
2. **Interactive tasks** - agents that need user input
3. **Sequential dependencies** - when Agent B needs Agent A's output
4. **Critical path operations** - deployment steps that must succeed sequentially
5. **Modifying state** - git commits, file writes, destructive operations

**Use synchronous execution instead:**

```typescript
// Quick code review - just wait for it
Task({
  subagent_type: "code-review-agent",
  description: "Review small change",
  prompt: "Review 10-line change in auth.ts"
  // No run_in_background - just wait 15 seconds
})

// Deployment that needs immediate verification
Task({
  subagent_type: "aws-infrastructure-expert",
  description: "Deploy critical hotfix",
  prompt: "Deploy hotfix to production. Verify immediately."
  // No run_in_background - need immediate feedback
})
```

---

## Summary

Background agents dramatically improve productivity by:

- Running long tasks asynchronously while you work
- Enabling parallel execution of independent analyses
- Providing continuous feedback during development
- Maximizing expensive Claude Sonnet time

Use them liberally for long-running, independent, analysis-focused tasks.
