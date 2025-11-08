---
name: roadmap-builder
description: Prioritizes features using Impact vs Effort matrix and stage-based rules (Retention > Core > Monetization > Growth). Challenges feature ideas, prevents feature creep, and keeps roadmap focused on real user needs. Use when deciding what to build next or evaluating new feature requests.
allowed-tools: Read, Write, Grep, Glob
---

# Roadmap Builder

## Purpose

Help you decide **what to build next** by ruthlessly prioritizing features, challenging ideas, and preventing feature creep with a clear prioritization framework.

## When to Use This Skill

- Deciding what to build next
- Evaluating a feature request
- User asks "should we add [feature]?"
- Planning the next sprint/milestone
- After shipping MVP and need to prioritize
- When roadmap feels overwhelming
- Before adding any non-essential feature

## Core Prioritization Framework

### Impact vs Effort Matrix

**Always evaluate features on two dimensions:**

```
HIGH IMPACT
    │
    │  Build Soon      Build Now
    │  (Plan it)       (Do it)
    │
────┼────────────────────────────
    │
    │  Maybe Later    Build Last
    │  (If ever)      (Skip it)
    │
LOW IMPACT              HIGH EFFORT
```

**Priority Order:**

1. **High Impact, Low Effort** → Build NOW
2. **High Impact, High Effort** → Build SOON (plan carefully)
3. **Low Impact, Low Effort** → Build LAST (if time permits)
4. **Low Impact, High Effort** → SKIP IT (never worth it)

### Impact Scoring

**High Impact = Moves key metrics:**

- Increases retention (users come back)
- Serves core use case (why they're here)
- Directly drives revenue
- Reduces churn (prevents users leaving)
- Increases referrals (users share it)

**Low Impact = Nice to have:**

- "Would be cool" features
- Edge cases affecting <5% of users
- Internal tooling
- Polish/cosmetic changes
- Features nobody asked for

### Effort Scoring

**Low Effort = <3 days:**

- Simple UI changes
- Basic CRUD operations
- Using existing patterns
- No new dependencies

**High Effort = >1 week:**

- Complex logic
- New infrastructure
- External integrations
- Significant refactoring
- Requires new skills/tools

## Category Priority Order

**Always prioritize in this order:**

### 1. Retention (Highest Priority)

Features that make users come back:

- Fix friction in existing flows
- Improve onboarding
- Add core loop improvements
- Reduce abandonment
- Make existing features better

**Why first:** If users don't come back, nothing else matters.

### 2. Core Features

Features that serve the main use case:

- Essential functionality users signed up for
- Features completing the core loop
- Features users explicitly requested (multiple times)

**Why second:** Users need the core product to work well.

### 3. Monetization

Features that drive revenue:

- Payment flows
- Premium features
- Usage-based billing
- Upgrade prompts (subtle, not annoying)

**Why third:** Can't grow if you can't make money.

### 4. Growth (Lowest Priority)

Features that acquire new users:

- Referral programs
- Social sharing
- SEO improvements
- Marketing integrations

**Why last:** Growth is pointless if retention is broken.

**Exception:** Only prioritize Growth earlier if you have:

- Product-market fit validated
- Strong retention (>40% week-over-week)
- Working monetization

## Stage-Based Rules

### Pre-Launch (No Users Yet)

**ONLY build:**

- Core loop features (minimum path to value)
- Features in the MVP PRD
- Features blocking launch

**NEVER build:**

- User profiles
- Settings pages
- Admin dashboards
- Analytics beyond basics
- Social sharing
- Any "nice to have" feature
- Features users haven't explicitly requested (because you have no users yet!)

**Rule:** If you can launch without it, don't build it.

### Post-Launch (1-100 Users)

**ONLY build:**

- Features users explicitly request (3+ users asking for same thing)
- Retention improvements (fix where users drop off)
- Critical bugs blocking core use case
- Payment/monetization (when ready to charge)

**NEVER build:**

- Features you think users want (ask them first)
- Features only 1 user requested
- Growth features (you don't have retention yet)
- Features for imaginary future users

**Rule:** Talk to users weekly. Build what they ask for, not what you imagine.

### Growth Phase (100+ Active Users)

**NOW you can build:**

- Features that reduce churn (highest priority)
- Features that increase sharing/referrals
- Features that improve monetization
- Power user features (if data shows they're needed)

**Still NEVER build:**

- Features nobody asked for
- Features you can't measure impact of
- Features that don't fit one of the 4 categories above

**Rule:** Let data and user feedback drive decisions.

## The Three Questions

**Ask about EVERY feature before building:**

### 1. Does this serve the core use case?

**If YES:**

- Does it improve the main reason users are here?
- Does it make the core loop faster/easier/better?
- Is it essential or nice-to-have?

**If NO:**

- Why are we building this?
- Does it support retention or monetization?
- Can we defer to v2?

### 2. Will users actually use this or just say they want it?

**Validate demand:**

- Have 3+ users explicitly asked for this?
- Are users trying to hack this together already?
- Is this solving a painful problem or just "nice to have"?

**Warning signs:**

- Only 1 user asked for it
- You think it would be cool
- "Users might want this..."
- "It would be nice if..."

**Better approach:**

- Ask users: "If we built [feature], would you use it weekly?"
- Show mockup: "Would you pay for this?"
- Track: "How many users are hitting this limitation?"

### 3. Can we fake it first to validate demand?

**Before building, try:**

- **Manual MVP:** Do it manually for 10 users
- **Wizard of Oz:** Fake the feature, fulfill manually
- **Landing page test:** Add button, count clicks
- **Email survey:** "Would you use [feature]?"

**Only build if:**

- Manual version is too time-consuming (proof of demand)
- Users actively try to use the fake version
- You have commitment, not just interest

**Example:**

- Don't build CSV export → Offer to email them a CSV manually
- Don't build integrations → Use Zapier first
- Don't build automation → Do it manually for 10 users

## Red Flags (Stop and Rethink)

### 🚩 Feature Creep

**Symptom:**

- "While we're at it, let's also add..."
- Roadmap has 20+ features
- Adding features because competitors have them
- Building features that sound cool

**Fix:**

- Review: Does this serve core use case?
- Cut: Remove anything not directly serving retention/core/monetization
- Defer: Move "nice to haves" to v2 backlog

### 🚩 Premature Optimization

**Symptom:**

- Optimizing before you have users
- "Let's build this flexible so we can scale later"
- Refactoring instead of shipping new value
- Building infrastructure before proving the feature works

**Fix:**

- Ship the hacky version first
- Validate demand before optimizing
- Optimize only when it becomes a real bottleneck
- Remember: most products never need to scale

### 🚩 Building for Imaginary Users

**Symptom:**

- "Users will probably want..."
- "Our target user would love..."
- Zero user requests, all assumptions
- Building what you want, not what users asked for

**Fix:**

- Talk to 5 real users this week
- Show them mockups, gauge reaction
- Only build what they explicitly ask for
- Defer everything else to v2

## Feature Evaluation Process

Use this for every feature request:

### Step 1: Understand Context

```
- What stage are we in? (Pre-launch, Post-launch, Growth)
- Who requested this? (Team idea, 1 user, 3+ users, data insight)
- What problem does it solve?
- What category is it? (Retention, Core, Monetization, Growth)
```

### Step 2: Score Impact & Effort

```
Impact: High or Low? (Does it move key metrics?)
Effort: <3 days or >1 week?
Quadrant: Build Now, Build Soon, Build Last, or Skip?
```

### Step 3: Ask The Three Questions

```
1. Does this serve the core use case?
2. Will users actually use this?
3. Can we fake it first to validate?
```

### Step 4: Apply Stage Rules

```
Pre-launch: Is it in the MVP? If no → defer
Post-launch: Did 3+ users ask for it? If no → defer
Growth: Does it reduce churn or increase sharing? If no → defer
```

### Step 5: Make Decision

```
✅ Build Now: High impact, low effort, serves stage needs
📅 Build Soon: High impact, high effort, plan carefully
🤔 Maybe Later: Low impact, low effort, defer to backlog
❌ Skip It: Low impact, high effort, or doesn't serve stage
```

## Decision Templates

### Build Now Decision

```
✅ BUILD NOW: [Feature Name]

**Why:**
- Category: [Retention/Core/Monetization/Growth]
- Impact: High - [specific metric it improves]
- Effort: Low - [estimated time]
- Stage fit: [why it's right for current stage]

**User need:**
- [X] users explicitly requested this
- Current pain: [specific problem they're experiencing]
- Expected outcome: [how this solves it]

**Next steps:**
1. [Define scope]
2. [Create task breakdown]
3. [Ship in X days]
```

### Defer/Skip Decision

```
❌ DEFER TO V2: [Feature Name]

**Why:**
- Category: [Retention/Core/Monetization/Growth]
- Impact: Low - [why it won't move key metrics]
- Effort: [High/Medium] - [estimated time]
- Stage mismatch: [why wrong timing]

**Better alternative:**
[What to do instead, or what to build first]

**Reconsider when:**
- [Specific condition that would make this worth building]
```

### Challenge Decision

```
🤔 NEEDS VALIDATION: [Feature Name]

**Concerns:**
- [ ] No user requests (assumption-driven)
- [ ] Low impact on key metrics
- [ ] High effort for uncertain return
- [ ] Doesn't serve current stage

**Before building:**
1. [Validation step 1 - e.g., "Survey 10 users"]
2. [Validation step 2 - e.g., "Create landing page test"]
3. [Validation step 3 - e.g., "Offer manual version"]

**Decision criteria:**
If [X users say yes / Y% click / Z usage], then build.
Otherwise, defer.
```

## Roadmap Organization

### Current Sprint (This Week)

**Only include:**

- 1-3 features maximum
- All from "Build Now" category
- Clear definition of done

### Next Sprint (Next 2 Weeks)

**Plan ahead:**

- 2-5 features from "Build Soon"
- Prioritized by category order
- Dependencies identified

### Backlog (Future)

**Everything else:**

- Organized by category
- Sorted by impact/effort score
- Revisit monthly

### v2 Parking Lot

**Deferred features:**

- Good ideas, wrong timing
- Low impact, low effort
- Not serving current stage
- Reconsider after next milestone

## Common Scenarios

### Scenario 1: User Requests Feature

**Process:**

1. Thank them for feedback
2. Ask: "How often would you use this?"
3. Check: Have others asked for this?
4. If 1 request → add to backlog, monitor
5. If 3+ requests → evaluate with framework
6. If high impact, low effort → build soon
7. Update user when shipped or deferred

### Scenario 2: Competitor Launches Feature

**Process:**

1. Don't panic (they might be wrong)
2. Ask: Did any users ask for this?
3. Evaluate: Is this core to their value prop?
4. Check: Does it fit our roadmap category priorities?
5. If no user demand → ignore
6. If users asking → evaluate with framework
7. Remember: You're not building their product

### Scenario 3: Team Wants "Cool" Feature

**Process:**

1. Ask: What problem does this solve?
2. Ask: Which users need this?
3. Ask: What's the impact on key metrics?
4. If no clear answers → defer to v2
5. If good answers → evaluate with framework
6. Remember: Cool ≠ Valuable

### Scenario 4: Overwhelming Roadmap

**Process:**

1. Review all features against stage rules
2. Cut everything not serving current stage
3. Re-score remaining by impact/effort
4. Keep only top 5 for next month
5. Move rest to v2 parking lot
6. Remember: You can't build everything

## Integration with Other Skills

### Works with Launch Planner

- Launch Planner defines MVP scope
- Roadmap Builder defines what comes after MVP
- Together they prevent scope creep

### Works with Idea Validator

- Idea Validator says "build this product"
- Roadmap Builder says "here's what to build next"
- Both use similar validation frameworks

### Works with Marketing Writer

- When feature ships, trigger Marketing Writer
- Roadmap Builder decides what to ship
- Marketing Writer decides how to announce it

## Monthly Roadmap Review

**Do this monthly:**

### Review Last Month

- [ ] What did we ship?
- [ ] Did it have the expected impact?
- [ ] What did we learn?

### Evaluate Current Stage

- [ ] Pre-launch, Post-launch, or Growth?
- [ ] Are stage priorities still right?
- [ ] Should we adjust focus?

### Re-prioritize Backlog

- [ ] New user requests to add?
- [ ] Features to promote from v2?
- [ ] Features to cut entirely?

### Set Next Month Goals

- [ ] 3-5 features maximum
- [ ] All align with stage priorities
- [ ] Clear success metrics

## Key Principles

### Do ✅

- **Start with user requests** (not team ideas)
- **Validate before building** (fake it first)
- **Focus on one category** at a time
- **Ship small, iterate fast**
- **Measure impact** of every feature
- **Cut ruthlessly** when in doubt

### Don't ❌

- **Build for imaginary users** (talk to real ones)
- **Add features because competitors have them**
- **Optimize before proving** (ship hacky v1)
- **Try to build everything** (focus wins)
- **Ignore stage rules** (timing matters)
- **Skip validation** (fake it first)

## Quick Reference: Decision Tree

```
New Feature Idea
    ↓
Does it serve core use case?
    ↓ NO → Defer to v2
    ↓ YES
    ↓
Have 3+ users requested it?
    ↓ NO → Validate first
    ↓ YES
    ↓
Can we fake it to validate demand?
    ↓ YES → Fake it first
    ↓ NO (already validated)
    ↓
What's current stage?
    ↓
    ├─ Pre-launch → Only if in MVP
    ├─ Post-launch → Only if retention/core
    └─ Growth → Only if reduces churn or increases sharing
    ↓
Score: Impact vs Effort
    ↓
    ├─ High Impact, Low Effort → Build Now
    ├─ High Impact, High Effort → Build Soon
    ├─ Low Impact, Low Effort → Build Last
    └─ Low Impact, High Effort → Skip It
```

## Output Format

When evaluating a feature:

```
# Feature Evaluation: [Feature Name]

## Context
- **Requested by:** [Team/1 user/3+ users/Data insight]
- **Current stage:** [Pre-launch/Post-launch/Growth]
- **Category:** [Retention/Core/Monetization/Growth]

## Scoring
- **Impact:** [High/Low] - [Reason]
- **Effort:** [<3 days/>1 week] - [Reason]
- **Quadrant:** [Build Now/Soon/Last/Skip]

## Three Questions
1. **Serves core use case?** [Yes/No - Explanation]
2. **Will users actually use it?** [Evidence or validation needed]
3. **Can we fake it first?** [Yes/No - How]

## Stage Rules Check
- [✅/❌] Fits stage priorities
- [Explanation of why/why not]

## Decision
[✅ Build Now / 📅 Build Soon / 🤔 Needs Validation / ❌ Defer]

**Reasoning:**
[2-3 sentences on why this is the right decision]

**Next steps:**
1. [Specific action]
2. [Specific action]
3. [Specific action]

**Reconsider if:**
[Conditions that would change this decision]
```

## Success Metrics

This skill succeeds when:

- Roadmap stays focused (5 or fewer active features)
- Features ship that users actually use
- Team doesn't build things nobody asked for
- Stage priorities are respected
- Feature creep is prevented
- Every feature has clear impact

This skill fails when:

- Roadmap has 20+ features
- Team builds features nobody uses
- Ignoring stage rules
- Building for imaginary users
- No validation before building
- Can't explain impact of features
