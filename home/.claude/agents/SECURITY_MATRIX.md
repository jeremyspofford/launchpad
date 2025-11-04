# Security Agents Responsibility Matrix

**Purpose:** Clarify which security agent to use for different security tasks.

---

## Quick Decision Tree

```markdown
Need security help?
    ↓
What stage?
    ↓
    ├─ BEFORE COMMIT → devsecops-scanner
    │   (Pre-commit secrets & vulnerability scan)
    │
    ├─ CODE REVIEW → code-review-agent
    │   (Quality + basic security issues)
    │
    ├─ INFRASTRUCTURE → infrastructure-security-agent
    │   (IaC security audit: Terraform, CDK, CloudFormation)
    │
    └─ COMPREHENSIVE → security-auditor-agent
        (Full OWASP audit: SQL injection, XSS, auth issues)
```

---

## Agent Responsibilities

### 1. devsecops-scanner (Pre-Commit Scanning)

**File:** `devsecops-scanner.md` (157 lines)

**Purpose:** Fast pre-commit security checks

**Scope:**

- ✅ Secrets detection (API keys, passwords, tokens)
- ✅ Hardcoded credentials
- ✅ Basic vulnerability patterns
- ✅ Insecure configurations
- ✅ Dependency vulnerabilities (high-level)

**When to use:**

- Before git commits
- Pre-deployment quick scan
- CI/CD pipeline gates
- Called with `--full` flag for comprehensive repo scan

**NOT responsible for:**

- ❌ OWASP Top 10 analysis
- ❌ Infrastructure-as-Code security
- ❌ Code quality (use code-review-agent)

**Example:**

```bash
# Scan files before commit
devsecops-scanner: "Scan these files for secrets and vulnerabilities"

# Full repo scan
devsecops-scanner --full: "Complete security scan of repository"
```

---

### 2. code-review-agent (Code Quality + Basic Security)

**File:** `code-review-agent.md` (477 lines)

**Purpose:** Comprehensive code review with security as ONE component

**Scope:**

- ✅ Code quality and best practices
- ✅ Performance issues
- ✅ BASIC security issues (obvious SQL injection, XSS)
- ✅ Architecture and maintainability
- ✅ Test coverage
- ✅ Documentation

**When to use:**

- Regular code reviews
- Pull request reviews
- Pre-deployment quality checks
- After implementing features

**NOT responsible for:**

- ❌ Deep OWASP analysis (use security-auditor-agent)
- ❌ Infrastructure security (use infrastructure-security-agent)
- ❌ Secrets scanning (use devsecops-scanner)

**Example:**

```bash
code-review-agent: "Review this PR for quality, performance, and basic security"
```

---

### 3. infrastructure-security-agent (IaC Security)

**File:** `infrastructure-security-agent.md` (545 lines)

**Purpose:** Security audit for Infrastructure-as-Code

**Scope:**

- ✅ Terraform/CDK/CloudFormation security
- ✅ Network configurations (VPCs, security groups, firewalls)
- ✅ IAM policies and permissions
- ✅ Encryption settings (at-rest, in-transit)
- ✅ Public exposure risks
- ✅ Compliance with infrastructure best practices

**When to use:**

- Before deploying infrastructure changes
- Auditing Terraform/CDK code
- Reviewing cloud architecture
- Infrastructure code reviews

**NOT responsible for:**

- ❌ Application code security (use security-auditor-agent)
- ❌ Pre-commit scans (use devsecops-scanner)
- ❌ Code quality (use code-review-agent)

**Example:**

```bash
infrastructure-security-agent: "Audit this Terraform configuration for security issues"
```

---

### 4. security-auditor-agent (Comprehensive OWASP Audit)

**File:** `security-auditor-agent.md` (686 lines)

**Purpose:** Deep, comprehensive security audit

**Scope:**

- ✅ OWASP Top 10 vulnerabilities
- ✅ SQL injection (comprehensive patterns)
- ✅ Cross-site scripting (XSS)
- ✅ Authentication and authorization flaws
- ✅ Session management issues
- ✅ Insecure deserialization
- ✅ Security misconfigurations
- ✅ Sensitive data exposure
- ✅ XML external entities (XXE)
- ✅ Broken access control

**When to use:**

- Before production deployments
- After major security-sensitive changes
- Periodic security audits
- When security is critical concern
- Security compliance requirements

**NOT responsible for:**

- ❌ Pre-commit quick scans (use devsecops-scanner)
- ❌ Infrastructure security (use infrastructure-security-agent)
- ❌ Code quality (use code-review-agent)

**Example:**

```bash
security-auditor-agent: "Comprehensive OWASP security audit of authentication system"
```

---

## Common Scenarios

### Scenario 1: About to Commit Code

**Use:** `devsecops-scanner`

```bash
Task({
  subagent_type: "devsecops-scanner",
  prompt: "Scan these files for secrets before commit: [file list]"
})
```

---

### Scenario 2: Code Review / Pull Request

**Use:** `code-review-agent`

```bash
Task({
  subagent_type: "code-review-agent",
  prompt: "Review this PR for quality, performance, and security"
})
```

---

### Scenario 3: Deploying Infrastructure (Terraform/CDK)

**Use:** `infrastructure-security-agent`

```bash
Task({
  subagent_type: "infrastructure-security-agent",
  prompt: "Audit this Terraform module for security vulnerabilities"
})
```

---

### Scenario 4: Pre-Production Security Audit

**Use:** `security-auditor-agent`

```bash
Task({
  subagent_type: "security-auditor-agent",
  prompt: "Comprehensive security audit before production deployment"
})
```

---

### Scenario 5: Pre-Deployment Validation (Orchestrator Pattern)

**Use:** Multiple agents in parallel via orchestrator

```typescript
// Orchestrator coordinates all security checks
Task({
  subagent_type: "orchestrator-agent",
  prompt: "Run comprehensive pre-deployment validation"
})

// Orchestrator will launch in parallel:
// - devsecops-scanner (secrets)
// - security-auditor-agent (OWASP)
// - infrastructure-security-agent (if IaC changed)
// - code-review-agent (quality)
// - test-runner-agent (tests)
```

---

## Orchestrator Integration

The `orchestrator-agent` understands this matrix and will:

1. Analyze the request
2. Select appropriate security agent(s)
3. Run agents in parallel when independent
4. Synthesize results into coherent report

**Example user request:**
> "Review this code before deployment"

**Orchestrator decision:**

```typescript
// Launches in parallel:
Task({ subagent_type: "code-review-agent", prompt: "..." })
Task({ subagent_type: "security-auditor-agent", prompt: "..." })
Task({ subagent_type: "test-runner-agent", prompt: "..." })
Task({ subagent_type: "devsecops-scanner", prompt: "..." })
```

---

## Summary Table

| Agent | Primary Focus | Speed | When to Use |
|-------|---------------|-------|-------------|
| **devsecops-scanner** | Secrets & Quick Scan | ⚡ Fast (1-2 min) | Pre-commit, CI/CD |
| **code-review-agent** | Code Quality + Basic Security | 🔄 Medium (3-5 min) | PRs, Code Reviews |
| **infrastructure-security-agent** | IaC Security | 🔄 Medium (5-7 min) | Terraform/CDK Reviews |
| **security-auditor-agent** | OWASP Deep Audit | 🐢 Slow (10-15 min) | Pre-prod, Compliance |

---

## Best Practices

1. **Layer security checks** - Use multiple agents for critical deployments
2. **Pre-commit → devsecops-scanner** - Catch secrets early
3. **PR review → code-review-agent** - Quality + basic security
4. **Pre-prod → security-auditor-agent** - Deep OWASP audit
5. **Infrastructure → infrastructure-security-agent** - IaC-specific checks
6. **Let orchestrator decide** - For complex scenarios, let orchestrator choose

---

## Quick Reference Commands

```bash
# Pre-commit scan
/devsecops-scanner "Scan for secrets"

# Code review
/code-review "Review this PR"

# Infrastructure security
/infrastructure-security "Audit this Terraform"

# Comprehensive audit
/security-audit "Full OWASP security check"

# Let orchestrator decide
/orchestrator "Security review before deployment"
```

---

**Last Updated:** November 4, 2025
**Maintained by:** agent-manager
**Review frequency:** Quarterly or when security agents change
