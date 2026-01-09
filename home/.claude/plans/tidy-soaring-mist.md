# Claude Code Ultimate Workflow Configuration Plan

**Status**: In Progress - Awaiting Notion page content
**Goal**: Configure comprehensive Claude Code workflow with smart commands, hooks, and documentation

---

## 🎯 Objectives

Based on your request and codebase exploration, we need to:

1. **Smart Slash Commands**
   - Auto-detect git provider (GitLab vs GitHub) based on remote URL
   - Single `/commit-push-pr` command that uses `glab` or `gh` automatically
   - Environment-aware commands (local/dev/stage/prod)
   - Project-specific vs global commands

2. **Hook Configuration**
   - Global hooks (apply to all projects)
   - Project-specific hooks (ft-quoting specific)
   - GitLab-specific automation
   - Pre/post tool use validation

3. **Documentation Strategy**
   - Quick reference "cheat sheet" for daily use
   - Updated CLAUDE.md (global + project-specific)
   - Command examples and workflow guides
   - Agent usage guide (when to use which agent)

4. **Configuration Files**
   - Global settings (`~/.claude/settings.json`)
   - Project settings (`.claude/settings.local.json`)
   - Clear separation of concerns
   - Avoid context bloat while maintaining power

---

## 📊 Current State Analysis

### Existing Configuration ✅

**Global Setup** (`~/.claude/` → `/Users/jeremyspofford/workspace/dotfiles/home/.claude/`):
- `settings.json` - Global permissions and hooks
- `settings.local.json` - Local overrides for testing
- 10+ MCP servers configured:
  - AWS Skills (aws-cdk, aws-cost-ops, serverless-eda)
  - Repomix (explorer, commands, MCP)
  - GitLab MCP server
  - Context7 (documentation)
  - Greptile (code analysis)
  - Playwright (browser automation)
  - Pinecone (vector search)
  - Notion
  - OpenTofu
  - AWS API MCP

**Project Setup** (`/Users/jeremyspofford/workspace/ft-quoting/.claude/`):
- `settings.local.json` - Restricted permissions for safety
- `ralph-loop.local.md` - Active Ralph Loop state
- Infrastructure subdirectory with separate settings

**Git Provider Detection**:
- Current projects use **GitLab** (self-hosted: `git@client`)
- CI/CD via `.gitlab-ci.yml` (modular configuration)
- No GitHub projects detected yet
- Need smart detection for future multi-provider support

**Documentation**:
- Strong existing docs: `CLAUDE.md`, `LOCAL-DEV-GUIDE.md`, infrastructure guides
- **Gap**: No quick reference cheat sheet
- **Gap**: Commands scattered across multiple files
- **Gap**: No "what agent to use when" guide

**Skills**:
- Skills directory exists but is **empty**
- No custom slash commands yet
- Opportunity to build from scratch

**Git Hooks**:
- Lefthook configured for pre-push TypeScript validation
- No Claude-specific hooks beyond what's in global config

---

## 🚧 Pending Information

**Waiting for Notion page content to finalize**:
- Specific slash commands you want
- Hook preferences and workflow automation desires
- Documentation format preferences
- Global vs project-specific strategy details
- Agent usage patterns you prefer

---

## 📋 Planned Implementation

### Phase 1: Smart Slash Commands

**Git Provider Auto-Detection Utility**

Create a reusable skill that detects git provider and CI/CD setup using secure command execution:

```typescript
// .claude/skills/git-utils/detect-provider.ts
import { execFile } from 'child_process'
import { promisify } from 'util'
import fs from 'fs'

const execFileAsync = promisify(execFile)

export async function detectGitProvider(): Promise<'gitlab' | 'github' | 'unknown'> {
  try {
    // Safely get git remote URL
    const { stdout } = await execFileAsync('git', ['remote', 'get-url', 'origin'])
    const remoteUrl = stdout.trim()

    // Check remote URL patterns
    if (remoteUrl.includes('github.com')) return 'github'
    if (remoteUrl.includes('gitlab') || remoteUrl.includes('git@client')) return 'gitlab'

    // Fallback: Check for CI/CD files
    if (fs.existsSync('.gitlab-ci.yml')) return 'gitlab'
    if (fs.existsSync('.github/workflows')) return 'github'

    return 'unknown'
  } catch (error) {
    console.error('Failed to detect git provider:', error)
    return 'unknown'
  }
}
```

**Smart Commands to Create**:

1. **`/commit-push-pr`** (or `/commit`)
   - Auto-detects GitLab vs GitHub
   - Uses `glab` for GitLab, `gh` for GitHub
   - Commits with conventional commit format
   - Pushes to remote
   - Opens MR/PR with template

2. **`/switch-env`**
   - Quick environment switching (local/dev/stage/prod)
   - Updates `.env` files
   - Runs appropriate npm scripts
   - Shows current environment status

3. **`/deploy`**
   - Environment-aware deployment
   - Runs appropriate build → deploy pipeline
   - Shows deployment status
   - Links to deployed resources

4. **`/rollback`** (GitLab-specific)
   - Uses existing rollback infrastructure
   - Shows available versions
   - Executes rollback commands
   - Validates success

5. **`/quick-ref`**
   - Opens quick reference documentation
   - Shows common commands for current context
   - Environment-specific tips

### Phase 2: Hook Configuration

**Global Hooks** (`~/.claude/settings.json`):
- `SessionStart` - Load context, show environment
- `PreToolUse` - Validate dangerous operations
- `PostToolUse` - Log actions, update documentation
- `Notification` - Slack/Teams integration (optional)

**Project Hooks** (`.claude/settings.local.json`):
- `SessionStart` - Show project-specific tips, active branches
- `PreToolUse` - Extra validation for production operations
- `PostToolUse` - Update CLAUDE.md if configuration changes

**GitLab-Specific Hooks**:
- Detect MR context and show relevant checks
- Validate CI/CD pipeline status before deployment
- Auto-tag commits with environment

### Phase 3: Documentation Updates

**Global CLAUDE.md** (`~/CLAUDE.md` or `~/.claude/CLAUDE.md`):
- Your preferred workflow patterns
- Global slash commands
- When to use which MCP server
- Agent selection guide

**Project CLAUDE.md** (`/Users/jeremyspofford/workspace/ft-quoting/CLAUDE.md`):
- Update with new slash commands
- Add quick reference section
- Link to detailed docs

**Quick Reference Guide** (NEW):
- Single markdown file: `CLAUDE-QUICK-REF.md`
- Command cheat sheet organized by context
- Environment switching reference
- Common troubleshooting (30-second fixes)
- File location quick lookup
- When to use which agent/tool

### Phase 4: Agent Usage Guide

**When to Use Each Agent**:

| Agent Type | Use When | Examples |
|------------|----------|----------|
| **Explore** | Understanding codebase, finding patterns | "How does error handling work?", "Find all API routes" |
| **Plan** | Designing implementation before coding | "Add new feature", "Refactor authentication" |
| **Bash** | Running commands, git operations | Deployment, testing, builds |
| **general-purpose** | Complex multi-step tasks | Research + implementation |
| **code-reviewer** | After writing code, before commits | PR review, style checking |
| **pr-test-analyzer** | Analyzing test coverage in PRs | "Are tests sufficient?" |
| **silent-failure-hunter** | Finding suppressed errors | Error handling review |

### Phase 5: Configuration File Strategy

**Separation of Concerns**:

1. **Global Config** (rarely changes):
   - MCP server configurations
   - General permissions
   - Universal hooks
   - Cross-project skills

2. **Project Config** (security & context):
   - Project-specific permissions (restrictive)
   - Local context overrides
   - Project-specific hooks
   - Environment variables

3. **Quick Reference** (frequently referenced):
   - Command cheat sheets
   - Workflow guides
   - Separate from CLAUDE.md to avoid bloat

**Context Management Strategy**:
- Keep CLAUDE.md focused on **patterns and architecture**
- Move **commands and procedures** to quick reference
- Use **skills** for reusable automation (not documentation)
- Use **hooks** for automatic workflow enforcement

---

## 🎬 Next Steps

1. **Review Notion pages** - Understand your specific workflow preferences
2. **Refine slash command list** - Based on your actual needs
3. **Design hook configuration** - Global + project-specific
4. **Create quick reference template** - Structure for easy daily use
5. **Update CLAUDE.md files** - Global and project-specific
6. **Implement smart git detection** - Reusable utility
7. **Create custom skills** - Starting with `/commit-push-pr`

---

## 📝 Notes & Questions

**Awaiting clarification on**:
- [ ] Specific slash commands from your Notion page
- [ ] Hook preferences and workflow automation
- [ ] Documentation format preferences (style, length, organization)
- [ ] Global vs project-specific strategy details
- [ ] Which MCP servers you use most frequently
- [ ] Agent usage patterns you prefer

**Assumptions (to be validated)**:
- You want smart provider detection (not separate commands for GitLab/GitHub)
- You prefer concise documentation over comprehensive
- You want automatic workflow enforcement via hooks
- Quick reference should be scannable in 30 seconds

---

**Plan Status**: ✅ Complete - Ready for implementation

---

## 🎯 Implementation Summary

Based on your Notion pages and codebase analysis, this plan implements a production-ready Claude Code workflow with:

1. **Smart Git Provider Detection** - Auto-detects GitLab/GitHub, single `/commit-push-pr` command
2. **Inner Loop Commands** - `/commit-push-pr`, `/iac-verify`, `/review-changes`, `/quick-ref`
3. **Specialized Agents** - `@iac-reviewer`, `@code-simplifier`, `@pipeline-helper`
4. **Intelligent Hooks** - Auto-formatting, notifications
5. **Team Documentation** - Quick reference, agent usage guide

---

## 📁 Files to Create

### Global (`~/.claude/`)

**Scripts** (executable):
- `scripts/detect-git-provider.sh` - Detects GitLab vs GitHub
- `scripts/git-cli-wrapper.sh` - Executes glab or gh automatically
- `scripts/iac-verify.sh` - Auto-detects CDK/Terraform/Pulumi and verifies
- `scripts/auto-format.sh` - Auto-formats after Edit/Write

**Settings**:
- `settings.json` - Add PostToolUse hook for auto-formatting
- `CLAUDE.md` - Add sections for custom commands and git detection

### Project (`.claude/`)

**Skills** (slash commands):
- `skills/commit-push-pr.md` - Inner loop automation
- `skills/iac-verify.md` - Infrastructure verification
- `skills/review-changes.md` - Review uncommitted changes
- `skills/quick-ref.md` - Display quick reference

**Agents** (subagents):
- `agents/iac-reviewer.md` - AWS CDK specialist
- `agents/code-simplifier.md` - Refactoring specialist
- `agents/pipeline-helper.md` - GitLab CI/CD troubleshooter

**Documentation**:
- `QUICK-REFERENCE.md` - Team cheat sheet (keep open while working)
- `AGENT-USAGE-GUIDE.md` - When to use which agent/tool

**Settings**:
- `settings.local.json` - Update permissions for new commands

---

## 🚀 Implementation Phases

### Phase 1: Core Scripts (Priority: Critical)

Create foundation utilities that everything else depends on.

**Files**:
1. `~/.claude/scripts/detect-git-provider.sh`
   - Returns "gitlab" or "github" or "unknown"
   - Checks remote URL patterns (github.com, gitlab, git@client)
   - Falls back to CI file detection (.gitlab-ci.yml vs .github/)

2. `~/.claude/scripts/git-cli-wrapper.sh`
   - Executes `glab` or `gh` based on detected provider
   - Translates `pr` ↔ `mr` commands automatically

3. `~/.claude/scripts/iac-verify.sh`
   - Detects CDK/Terraform/Pulumi automatically
   - Runs appropriate verification (cdk synth, terraform validate, etc.)

**Verification**:
```bash
cd /Users/jeremyspofford/workspace/ft-quoting
~/.claude/scripts/detect-git-provider.sh  # Should output "gitlab"
~/.claude/scripts/git-cli-wrapper.sh mr list
~/.claude/scripts/iac-verify.sh  # Should run CDK verification
```

### Phase 2: Essential Commands (Priority: High)

Inner loop automation for daily workflows.

**Files**:
1. `.claude/skills/commit-push-pr.md`
   - Stage → commit → push → create MR/PR
   - Uses conventional commits format
   - Runs lefthook pre-push validation
   - Auto-detects provider via git-cli-wrapper.sh

2. `.claude/skills/iac-verify.md`
   - Wraps iac-verify.sh script
   - Shows results in Claude context
   - Provides remediation suggestions

3. `.claude/skills/review-changes.md`
   - Shows git status, staged/unstaged diffs
   - Smart filtering (hide package-lock, dist/, etc.)
   - Offers to run `/commit-push-pr` if ready

**Verification**:
```bash
# In Claude Code
/commit-push-pr
/iac-verify
/review-changes
```

### Phase 3: Specialized Agents (Priority: High)

Domain experts for complex tasks.

**Files**:
1. `.claude/agents/iac-reviewer.md`
   - AWS CDK specialist (ft-quoting uses CDK)
   - Reviews for security, cost, best practices
   - Checks BaseStack pattern, naming conventions
   - Generates structured review report

2. `.claude/agents/code-simplifier.md`
   - Refactoring specialist
   - Reduces complexity without changing behavior
   - Preserves test coverage

3. `.claude/agents/pipeline-helper.md`
   - GitLab CI/CD troubleshooter
   - Knows ft-quoting pipeline architecture
   - Debugs failures, suggests optimizations

**Verification**:
```bash
# In Claude Code
@iac-reviewer review infrastructure/lib/api-stack.ts
@code-simplifier <paste complex code>
@pipeline-helper the build:frontend job failed
```

### Phase 4: Documentation (Priority: Medium)

Make everything discoverable and team-shareable.

**Files**:
1. `.claude/QUICK-REFERENCE.md`
   - Single-page cheat sheet
   - All commands, agents, workflows
   - Open in side panel while working

2. `.claude/AGENT-USAGE-GUIDE.md`
   - Decision tree: "When to use what?"
   - Common scenarios with workflows
   - Command reference table

3. `.claude/skills/quick-ref.md`
   - Skill that displays QUICK-REFERENCE.md
   - Makes documentation accessible via `/quick-ref`

**Verification**:
```bash
/quick-ref  # Should display quick reference
cat .claude/QUICK-REFERENCE.md
```

### Phase 5: Hooks & Automation (Priority: Low)

Intelligent automation for quality of life.

**Files**:
1. `~/.claude/scripts/auto-format.sh`
   - Auto-formats TypeScript (prettier)
   - Auto-formats Python (black)
   - Auto-formats Markdown (prettier)

2. `~/.claude/settings.json`
   - Add PostToolUse hook for auto-format.sh
   - Set timeout: 10 seconds
   - Fail gracefully if formatter not found

**Verification**:
- Edit a TypeScript file in Claude Code
- Check that prettier runs automatically
- Verify formatting is correct

### Phase 6: Team Rollout (Priority: Team)

Enable all team members to use the workflow.

**Actions**:
1. Commit `.claude/` directory to git
2. Update project README with setup instructions
3. Share quick reference in team channel
4. Create onboarding guide

**Team Setup**:
```bash
cd ft-quoting
git pull  # Get latest .claude/ configs

# Copy scripts to global
cp -r .claude/scripts ~/.claude/scripts
chmod +x ~/.claude/scripts/*.sh

# Usage: See .claude/QUICK-REFERENCE.md
```

---

## 🔍 Key Design Decisions

### Git Provider Detection Strategy

**Approach**: Remote URL pattern matching with CI file fallback

**Rationale**:
- Self-hosted GitLab uses custom domain (`git@client`)
- Standard patterns work for github.com and gitlab.com
- CI files provide reliable fallback
- No external dependencies needed

**Implementation**:
```bash
# Method 1: Remote URL
git remote get-url origin
# → git@client:alertventure/vividcloud/ft-quoting.git → "gitlab"

# Method 2: CI files
[[ -f .gitlab-ci.yml ]] → "gitlab"
[[ -f .github/workflows/*.yml ]] → "github"
```

### Configuration Separation

**Global vs Project**:

| Type | Location | Purpose | Version Control |
|------|----------|---------|-----------------|
| **Scripts** | `~/.claude/scripts/` | Reusable utilities | Dotfiles repo |
| **Hooks** | `~/.claude/settings.json` | Personal automation | Dotfiles repo |
| **Skills** | `.claude/skills/` | Team commands | Project git |
| **Agents** | `.claude/agents/` | Team subagents | Project git |
| **Docs** | `.claude/*.md` | Team reference | Project git |

**Rationale**:
- Scripts are executable, need global PATH access
- Skills/agents are project-specific, should be in version control
- Documentation should be with the code it documents
- Hooks are personal (different team members may want different automation)

### Verification Strategy

**Principle**: Give Claude a way to verify its work

**For Infrastructure**:
```bash
npm run build          # TypeScript compilation
cdk synth --quiet      # CloudFormation validation
cdk diff               # Preview changes
npm test               # Unit tests
```

**For Backend**:
```bash
npm run typecheck:be   # TypeScript
npm run test:be        # Unit tests
npm run build:be       # Compilation
npm run local:be       # Runtime test
```

**For Frontend**:
```bash
npm run typecheck:fe   # TypeScript
npm run test:fe        # Unit tests
npm run build:fe       # Vite build
```

### Security Considerations

**Script Permissions**:
- All scripts: 755 (executable by user, readable by all)
- Settings: 644 (readable only)
- No secrets in configuration files

**Command Validation**:
- Pre-push hook runs typecheck (catches errors before CI)
- iac-verify runs before infrastructure commits
- Auto-formatting never overwrites on error

**Scope Limitations**:
```json
{
  "permissions": {
    "allow": [
      "Bash(npm run typecheck:*)",
      "Bash(glab:*)",
      "Bash(gh:*)",
      "Bash(~/.claude/scripts/*:*)"
    ]
  }
}
```

---

## 📊 Expected Outcomes

### Time Savings

**Before**:
- Commit + push + MR: ~5 minutes (manual git commands, find MR URL)
- Infrastructure verification: ~3 minutes (remember all commands)
- Code review setup: ~2 minutes (git diff, check files)

**After**:
- Commit + push + MR: ~30 seconds (`/commit-push-pr`)
- Infrastructure verification: ~15 seconds (`/iac-verify`)
- Code review setup: ~10 seconds (`/review-changes`)

**Weekly savings per developer**: ~2-3 hours

### Quality Improvements

- **100% infrastructure verification** before commit (previously manual)
- **Consistent commit messages** (conventional commits enforced)
- **Automatic code formatting** (no more "fix formatting" commits)
- **Expert reviews** available on-demand (iac-reviewer, code-simplifier)

### Team Benefits

- **Shared knowledge** via git-committed configs
- **Onboarding acceleration** (quick reference + agents)
- **Reduced tribal knowledge** (workflows documented)
- **Consistent practices** (everyone uses same commands)

---

## 🧪 Testing Strategy

### Unit Testing (Per Component)

**Scripts**:
```bash
# Test detect-git-provider.sh
cd /path/to/gitlab/repo && ~/.claude/scripts/detect-git-provider.sh
# Expected: "gitlab"

cd /path/to/github/repo && ~/.claude/scripts/detect-git-provider.sh
# Expected: "github"

# Test git-cli-wrapper.sh
~/.claude/scripts/git-cli-wrapper.sh mr list
# Expected: Executes `glab mr list`

# Test iac-verify.sh
cd /path/to/ft-quoting/infrastructure
~/.claude/scripts/iac-verify.sh
# Expected: Runs CDK verification, exits 0
```

**Skills**:
```bash
# In Claude Code
/commit-push-pr --dry-run  # If supported
/iac-verify  # Should work in infrastructure/
/review-changes  # Should show current changes
/quick-ref  # Should display cheat sheet
```

**Agents**:
```bash
# In Claude Code
@iac-reviewer review infrastructure/lib/compute-stack.ts
# Expected: Structured review report

@code-simplifier [paste complex function]
# Expected: Simplified version with comparison

@pipeline-helper the test:backend job is failing
# Expected: Debugging suggestions
```

### Integration Testing (Full Workflows)

**Test 1: Complete Inner Loop**:
```bash
# 1. Make small change
echo "// test comment" >> apps/server/src/lambda.ts

# 2. Review
/review-changes

# 3. Commit + MR
/commit-push-pr "test: verify workflow"

# 4. Verify MR created
glab mr view

# 5. Cleanup
glab mr close <id>
git reset HEAD~1
git checkout apps/server/src/lambda.ts
```

**Test 2: Infrastructure Workflow**:
```bash
# 1. Make change
# Add comment to infrastructure/lib/api-stack.ts

# 2. Verify
/iac-verify

# 3. Get review
@iac-reviewer review my changes

# 4. Preview
cd infrastructure && cdk diff --context environment=dev

# 5. Cleanup
git checkout infrastructure/lib/api-stack.ts
```

### Security Testing

**Permissions Check**:
```bash
# Verify scripts not world-writable
ls -la ~/.claude/scripts/*.sh | grep -v "rwxr-xr-x"
# Expected: No output (all should be 755)

# Verify no secrets in configs
grep -ri "password\|secret\|key\|token" .claude/
# Expected: Only examples, no real values
```

**Hook Safety**:
```bash
# Verify hooks fail gracefully
~/.claude/scripts/auto-format.sh /nonexistent/file
echo $?
# Expected: 0 (exits successfully even on error)
```

---

## 📝 Critical Files Reference

### Must Create (Priority Order)

1. `~/.claude/scripts/detect-git-provider.sh` - Foundation
2. `~/.claude/scripts/git-cli-wrapper.sh` - Git automation
3. `~/.claude/scripts/iac-verify.sh` - Infrastructure verification
4. `.claude/skills/commit-push-pr.md` - Most-used command
5. `.claude/QUICK-REFERENCE.md` - Team documentation
6. `.claude/agents/iac-reviewer.md` - High-value expert
7. `~/.claude/scripts/auto-format.sh` - Quality of life
8. `.claude/settings.local.json` - Security permissions

### Can Defer

- `skills/quick-ref.md` - Nice to have, quick ref is readable directly
- `agents/code-simplifier.md` - Useful but not daily need
- `agents/pipeline-helper.md` - Only needed when pipeline breaks
- `AGENT-USAGE-GUIDE.md` - Can start with quick reference only

---

## 🎓 Learning Resources

### For Team Members

- **Quick Reference** - Open `.claude/QUICK-REFERENCE.md` in side panel
- **Agent Guide** - Read `.claude/AGENT-USAGE-GUIDE.md` for scenarios
- **Notion Pages** - Original vision and best practices
- **Claude Code Docs** - https://code.claude.com/docs

### For Maintenance

- **Boris Cherny's Tips** - Reddit post linked in Notion
- **AWS CDK Best Practices** - For iac-reviewer updates
- **GitLab CI Docs** - For pipeline-helper updates
- **Conventional Commits** - https://www.conventionalcommits.org/

---

## ✅ Success Criteria

### Week 1
- [ ] Core scripts working (detect-provider, git-wrapper, iac-verify)
- [ ] `/commit-push-pr` functional
- [ ] `/iac-verify` functional
- [ ] Quick reference created

### Week 2
- [ ] All three agents operational
- [ ] Documentation complete (quick ref + agent guide)
- [ ] Auto-formatting hook working
- [ ] Tested with real workflows

### Week 3
- [ ] Team onboarding complete
- [ ] 50%+ team adoption of commands
- [ ] No major bugs reported
- [ ] Feedback collected

### Week 4
- [ ] 80%+ team using commands
- [ ] Measured time savings (2-3 hrs/week/person)
- [ ] Documentation updates based on feedback
- [ ] Maintenance schedule established

---

**Ready for Implementation**: All designs complete, verification strategies defined, rollout plan established.
