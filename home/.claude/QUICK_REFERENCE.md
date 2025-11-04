# Claude Code Agent System - Quick Reference

**Last Updated:** November 4, 2025  
**Full Analysis:** See `DIRECTORY_ANALYSIS.md`

---

## What You Have

- **26-28 operational agents** (34 files including docs)
- **5 non-technical skills** (design, ideas, roadmaps, marketing)
- **2 custom slash commands**
- **Comprehensive global configuration** in CLAUDE.md & settings.json

---

## Agent Categories at a Glance

### Coordinators (Use These First)

- `orchestrator-agent` - Route technical tasks here
- `project-manager` - Route planning/backlog here

### Problem Diagnosis

- `diagnostic-agent` - Find what's wrong
- `verification-agent` - Prove it's fixed
- `debug-detective` - Runtime debugging

### Development

- `frontend-agent` - React/Next.js UI
- `backend-agent` - Node/Express API
- `database-agent` - Prisma schema/migrations

### Infrastructure & DevOps

- `aws-infrastructure-expert` - AWS infrastructure
- `iac-architect` - Terraform/CDK design
- `monitoring-agent` - Logs, metrics, performance
- `process-manager-agent` - Start/stop servers

### Quality & Security

- `code-review-agent` - Code quality review (primary)
- ~~`code-reviewer`~~ - **DUPLICATE** (delete this)
- `test-runner-agent` - Run and fix tests
- `security-auditor-agent` - Full security audit
- `devsecops-scanner` - Pre-commit security scanning
- `infrastructure-security-agent` - Infrastructure security

### Architecture & Strategy

- `architecture-agent` - System design decisions
- `cost-analysis-agent` - Cost estimation & optimization
- `dependency-agent` - Environment validation

### Git & CI/CD

- `git-workflow-expert-agent` - Git workflows & CI/CD (primary)
- ~~`git-workflow-expert`~~ - **DUPLICATE** (delete this)

### Specialized

- `shell-script-auditor` - Shell script analysis
- `documentation-agent` - Write documentation
- `documentation-auto-updater` - Auto-update on code changes (hooks)
- `monitoring-agent` - System monitoring

### Meta

- `agent-manager` - Create/modify agents
- `async-agent-manager` - Parallel execution simulation

---

## What to Call When

### "Something's broken"

1. orchestrator-agent (it will call diagnostic-agent)

### "I want to fix/implement something"

1. orchestrator-agent

### "Should we do this feature?"

1. project-manager (planning)
2. orchestrator-agent (implementation)

### "What should we work on?"

1. project-manager

### "Is the code good?"

1. code-review-agent (code quality)
2. security-auditor-agent (security)

### "Before deploying"

1. orchestrator-agent (runs all pre-deploy checks in parallel)

### "Just run the tests"

1. test-runner-agent

### "Git workflow help"

1. git-workflow-expert-agent

### "Does this have secrets?"

1. devsecops-scanner (pre-commit)
2. security-auditor-agent (comprehensive)

### "Infrastructure security?"

1. infrastructure-security-agent

### "What will this cost?"

1. cost-analysis-agent

### "How should we design this?"

1. architecture-agent

---

## Critical Issues to Fix

### 1. Delete These (Duplicates)

- `code-reviewer.md` - Keep `code-review-agent.md` instead
- `git-workflow-expert.md` - Keep `git-workflow-expert-agent.md` instead

### 2. Clarify Security Responsibilities

- `devsecops-scanner` → Secrets/exposed credentials
- `security-auditor-agent` → Full security audit (OWASP top 10)
- `code-review-agent` → Code quality (not security focus)
- `infrastructure-security-agent` → Infrastructure-as-code only

### 3. Update Documentation

- Rename `documentation-updater.md` → `documentation-auto-updater.md`
- Update ROUTING_GUIDE.md with clear examples for all agents

---

## Configuration Quick Facts

### Global CLAUDE.md

- 495 lines
- Contains agent routing instructions (CRITICAL)
- Defines tool permissions
- Sets communication preferences

### settings.json

- 87 lines
- Permissions matrix (27 specific permissions)
- Hooks for notifications & doc updates
- Feature flags

### Agent Frontmatter Format

```
---
name: agent-name
description: One-line description
tools: [Tool1, Tool2, Tool3]
model: inherit (or sonnet/haiku)
color: [yellow/purple/red/green/blue/cyan]
---
```

---

## Agents by Purpose

### Code Change Flow

diagnostic → backend/frontend → database → test-runner → code-review → verification

### Deploy Flow

dependency-agent → test-runner-agent → code-review-agent → security-auditor-agent → verification-agent

### Feature Planning Flow

project-manager → database-agent → backend-agent → frontend-agent → test-runner-agent → verification-agent

---

## Unused/Experimental Agents

None identified (all 26-28 agents serve a purpose)

## Agents Needing More Examples

- `cost-analysis-agent` (not mentioned in README workflow examples)
- `architecture-agent` (not featured prominently)

---

## Size Breakdown

- Orchestrator + Project-Manager: 864 lines (core coordinators)
- Security agents: 1,645 lines (4 agents with overlaps)
- Development agents: 1,186 lines (5 agents, well-focused)
- Infrastructure agents: 1,158 lines (6 agents)
- Documentation agents: 406 lines (2 agents)
- Remaining: 3,176 lines (specialized agents, docs, meta-agents)

**Total:** 10,631 lines (very reasonable for 26-28 agents)

---

## Files Worth Reading First

1. **agents/README.md** (676 lines) - Complete system overview
2. **agents/ROUTING_GUIDE.md** (447 lines) - Decision trees
3. **CLAUDE.md** (495 lines) - Global instructions
4. **orchestrator-agent.md** (432 lines) - How coordination works

---

## Action Items

- [ ] Delete `code-reviewer.md`
- [ ] Delete `git-workflow-expert.md`
- [ ] Rename `documentation-updater.md`
- [ ] Create security scanning decision matrix
- [ ] Update ROUTING_GUIDE.md with matrix
- [ ] Update CLAUDE.md to reference agents/README.md

See `DIRECTORY_ANALYSIS.md` for full details and timeline.

---

## Configuration Health Check

Run from ~/.claude/:

```bash
# Count agents
ls -1 agents/*.md | grep -v "ASYNC\|README\|ROUTING\|CLAUDE" | wc -l

# Verify frontmatter
grep -h "^name:" agents/*.md | wc -l

# Check for duplicates
grep -h "^name:" agents/*.md | sort | uniq -d

# Validate markdown
for f in agents/*.md; do
  if ! grep -q "^---" "$f"; then
    echo "Missing frontmatter: $f"
  fi
done
```

---

## Key Design Principles

1. **Single Responsibility:** Each agent has ONE clear purpose
2. **Hierarchy:** User → orchestrator/project-manager → specialists
3. **Evidence-Based:** Agents verify with concrete evidence, not assumptions
4. **Parallel When Safe:** orchestrator runs independent checks in parallel
5. **Sequential When Needed:** Dependencies are respected (diagnose before fix before verify)
6. **Cost Conscious:** Specialized agents minimize token waste

---

## Remember

- The system is **production-ready**
- Most issues are about **consolidation**, not missing functionality
- **orchestrator-agent and project-manager** are your entry points
- **Specialized agents are called by orchestrator**, not directly
- **Three duplicates to remove** for cleaner system

---

**Questions?** See `DIRECTORY_ANALYSIS.md` for comprehensive analysis.
