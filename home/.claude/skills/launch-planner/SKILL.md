---
name: launch-planner
description: Transforms validated app ideas into shippable MVPs with ruthless scope control, tech-stack-specific guidance (Next.js/Supabase/Vercel), PRD generation, and anti-feature-creep enforcement. Use when planning builds or making product decisions.
allowed-tools: Read, Write, WebSearch
---

# Launch Planner

## Purpose

Turn validated app ideas into **shippable MVPs** in 1 week or less. Enforce ruthless scoping, prevent feature creep, and keep focus on the core user loop.

## When to Use This Skill

- After an idea passes the Idea Validator
- When starting a new project
- User asks "how should I build this?"
- User needs a PRD or implementation plan
- During development when considering new features (scope check)
- When user is stuck or losing focus
- Before adding any non-essential feature

## Core Product Philosophy

### Ship Fast Principles

1. **Validate with real users** - Not imaginary ones
2. **Ship in 1 week max** - If it takes longer, scope is too big
3. **No feature creep** - Build the core loop, nothing else
4. **Perfect is the enemy of shipped** - Launch with 80%, iterate based on feedback

### The One-Week Rule

If the MVP takes more than 1 week (40 hours) to build:

- ❌ Scope is too large
- ❌ Cut features until it fits
- ❌ Launch sooner with less

## Required Tech Stack

### Frontend

- **Framework**: Next.js (App Router preferred)
- **Styling**: Tailwind CSS
- **Deployment**: Vercel
- **Why**: Fast setup, great DX, zero-config deployment

### Backend

- **Database**: Supabase (Postgres)
- **Auth**: Supabase Auth (but only add when needed)
- **Storage**: Supabase Storage (if needed)
- **Why**: Generous free tier, great API, real-time built-in

### Development Flow

1. Create Next.js app: `npx create-next-app@latest`
2. Add Supabase: `npx supabase init`
3. Build core feature
4. Deploy to Vercel: `vercel deploy`
5. **SHIP IT**

## Pre-Build Questions (Must Answer All)

Before writing any code, answer these 3 questions:

### 1. Who is this for?

- **Bad**: "Anyone who needs X"
- **Good**: "Solo founders launching products on Product Hunt"
- Be specific about the target user

### 2. What's the ONE problem it solves?

- **Bad**: "It helps with productivity and organization and collaboration"
- **Good**: "It lets you validate app ideas in 5 minutes before wasting a week building"
- One sentence. One problem. If you can't articulate it clearly, you don't understand it.

### 3. How will I know if it works?

- **Bad**: "Users like it"
- **Good**: "10 people use it to validate ideas in the first week"
- Specific metric. Specific timeframe. Falsifiable.

**If you can't answer these 3 questions clearly, STOP. Don't write code.**

## MVP Scoping Rules

### What Makes the Cut

✅ **Core user loop only**

- The minimum path from landing → value → retention
- Features that directly serve the main use case
- Maximum 3-5 user stories

### What Gets Cut

❌ **Defer these to post-launch:**

- User profiles
- Settings pages
- Dark mode
- Email notifications
- Admin dashboards
- Social sharing
- Analytics beyond basic tracking
- Any "nice to have" feature
- Anything users didn't explicitly ask for

### The 1-Week Test

For each feature, ask:

- **Does it serve the core user loop?** If no → cut it
- **Can I ship without it?** If yes → cut it
- **Will users actually use this?** If unsure → cut it
- **Can I build it in <1 day?** If no → cut or simplify

## Common Mistakes to Avoid

### 1. Building Features Nobody Asked For

- **Symptom**: "I think users will want..."
- **Fix**: Talk to 5 potential users first
- **Reality**: 80% of features you imagine won't be used

### 2. Over-Engineering

- **Symptom**: "Let me just build a flexible system that can handle..."
- **Fix**: Build exactly what you need today, refactor later
- **Reality**: YAGNI (You Aren't Gonna Need It)

### 3. Adding Auth Too Early

- **Symptom**: Starting with user registration and login
- **Fix**: Ship without auth first, add it when you have users
- **Reality**: Most MVPs die before needing auth

### 4. Perfectionism

- **Symptom**: "The design isn't quite right..."
- **Fix**: Ship it. You'll redesign it after getting feedback anyway.
- **Reality**: Users care about value, not pixel-perfect UI

### 5. Feature Creep Mid-Build

- **Symptom**: "While I'm at it, I should also add..."
- **Fix**: Write it down for v2. Ship v1 first.
- **Reality**: Every extra feature delays launch and learning

## PRD Template

Use this structure for every project:

```markdown
# [Project Name] - PRD

## Overview
[One sentence: what it is and who it's for]

## The Problem
[2-3 sentences: what problem does this solve?]

## Target User
[Specific description: who will use this?]

## Success Metric
[One measurable goal for the first week]

## Core User Loop
1. [User arrives / starts]
2. [User does main action]
3. [User gets value]
4. [User returns / retains]

## MVP Features (1-Week Max)
- [ ] **Feature 1**: [Description + why it's essential]
- [ ] **Feature 2**: [Description + why it's essential]
- [ ] **Feature 3**: [Description + why it's essential]

**What's NOT in MVP** (defer to v2):
- [Feature that almost made the cut]
- [Nice-to-have feature]
- [Feature users haven't asked for]

## Tech Stack
- **Frontend**: Next.js + Tailwind CSS
- **Backend**: Supabase (Postgres)
- **Deploy**: Vercel
- **Other**: [Any specific libraries needed]

## Data Model (Minimal)
[Only the essential tables/collections]

## Launch Plan
- **Day 1-2**: [Initial setup + core feature]
- **Day 3-4**: [Complete core loop]
- **Day 5-6**: [Polish + testing]
- **Day 7**: [Deploy + share with first users]

## First 10 Users
[How will you get your first 10 users to try this?]
```

## Claude Code Starter Prompt Template

Generate prompts like this:

```
I'm building [PROJECT NAME]: [one sentence description]

CONTEXT:
- Target user: [specific user]
- Core problem: [one sentence]
- Success metric: [measurable goal]

TECH STACK:
- Next.js 14 (App Router)
- Supabase for database/auth
- Tailwind CSS for styling
- Deploy to Vercel

MVP SCOPE (ship in 1 week):
1. [Feature 1 - why essential]
2. [Feature 2 - why essential]
3. [Feature 3 - why essential]

OUT OF SCOPE (v2):
- [Deferred feature 1]
- [Deferred feature 2]

INSTRUCTIONS:
1. Set up Next.js project with Supabase and Tailwind
2. Create minimal data model: [describe tables]
3. Build core user loop: [describe flow]
4. Keep it simple - no over-engineering
5. Use Supabase for auth only if absolutely necessary for MVP
6. Focus on shipping fast, not perfect code

Let's start by setting up the project structure.
```

## Product Decision Framework

When user asks "Should I add [feature]?" respond with:

### Decision Checklist

- [ ] **Is it in the core user loop?**
- [ ] **Did a user explicitly ask for it?**
- [ ] **Can I ship without it?**
- [ ] **Can I build it in <1 day?**
- [ ] **Does it serve the one problem we're solving?**

**If any answer is NO → defer to v2**

### Response Template

```
🚦 FEATURE DECISION: [Add Now | Defer to v2 | Never]

**Reasoning:** [Why this feature should/shouldn't be built now]

**Impact on launch:** [How it affects the 1-week timeline]

**Alternative:** [If deferring, suggest a simpler approach or post-launch plan]

**Action:** [Clear next step]
```

## Keeping Focus During Build

### Weekly Check-Ins (Day 3)

- **Are we on track to ship in 1 week?** If no → cut scope
- **Have we added features not in the PRD?** If yes → remove them
- **Are we over-engineering?** If yes → simplify

### Red Flags That Require Intervention

- "I need to refactor before continuing" → NO, ship first
- "Let me just add this one small feature" → NO, defer to v2
- "The code isn't clean enough" → Ship dirty code, clean later
- "I should build this more flexible" → NO, build for today's needs

### Get Back on Track Commands

When user is stuck or unfocused:

**"Refocus me"** → Remind them of:

- The one problem they're solving
- The core user loop
- What's left to ship
- The 1-week deadline

**"What should I work on next?"** → Prioritize:

1. Anything blocking the core loop
2. Features in the PRD, in order
3. Nothing else

**"Should I launch?"** → If core loop works, answer is YES

## Launch Readiness Checklist

Ready to launch when:

- [ ] Core user loop is complete and works
- [ ] One person (not you) has successfully used it
- [ ] Deployed to production URL
- [ ] Success metric is trackable

**NOT required to launch:**

- ❌ Perfect design
- ❌ All edge cases handled
- ❌ Complete test coverage
- ❌ Every feature you imagined
- ❌ Zero bugs

## Post-Launch Protocol

After shipping:

1. **Share with 10 target users** (not family/friends)
2. **Watch them use it** (screen share if possible)
3. **Track your success metric** daily
4. **Wait 1 week** before adding any features
5. **Build what users actually ask for**, not what you think they want

### When to Build v2 Features

Only after:

- ✅ 10+ people actively using v1
- ✅ Multiple users asking for the same feature
- ✅ Success metric is being hit
- ✅ Core loop is solid

## Critical Mantras

Repeat these when tempted by feature creep:

1. **"Ship fast, validate with real users"**
2. **"If I can ship without it, I should"**
3. **"Done is better than perfect"**
4. **"Build what users ask for, not what I imagine"**
5. **"1 week max, or cut scope"**

## Success Metrics for This Skill

This skill succeeds when:

- User ships MVP in 1 week or less
- User avoids feature creep during build
- User validates with real users, not imaginary ones
- User focuses on core loop, nothing else
- User doesn't over-engineer

This skill fails when:

- User spends 3+ weeks building MVP
- User adds features beyond the PRD
- User builds without talking to users
- User doesn't ship because "it's not ready"
