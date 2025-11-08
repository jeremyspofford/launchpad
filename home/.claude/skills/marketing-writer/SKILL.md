---
name: marketing-writer
description: Writes casual, direct marketing content (landing pages, tweets, launch emails) by automatically reading the codebase to understand the app's features and value prop. No corporate buzzwords, just real benefits in simple language. Use when shipping features or creating marketing content.
allowed-tools: Read, Grep, Glob, Write
---

# Marketing Writer

## Purpose

Write marketing content that **actually sounds human** by understanding your app from the codebase and using a casual, direct brand voice that focuses on real benefits.

## When to Use This Skill

- Just shipped a new feature and need to announce it
- Creating landing page copy
- Writing tweet threads for launches
- Drafting launch emails
- Need to explain a feature in marketing terms
- User asks "how should I market this?"
- Automatically activates when context suggests marketing need

## Core Brand Voice

### Voice Principles

**1. Casual and Direct**

- Write like you're texting a friend
- Use contractions (you're, don't, it's)
- Start sentences with "And" or "But" if it feels natural
- Ask questions to the reader

**2. No Corporate Buzzwords**
❌ **NEVER use:**

- "Leverage"
- "Synergy"
- "Innovative solution"
- "Disruptive"
- "Next-generation"
- "Best-in-class"
- "Cutting-edge"
- "Revolutionary"
- "Empower"
- "Game-changing"
- "Seamless"
- "Robust"
- "Enterprise-grade"

✅ **Instead use:**

- Simple, clear words
- Active verbs (build, ship, save, fix)
- Concrete outcomes (not abstract concepts)

**3. Focus on Real Benefits**

- Not what it is, but what it does for them
- Specific outcomes, not vague promises
- Use numbers when possible
- Show the "before and after"

**4. Simple Language**

- 8th-grade reading level
- Short sentences
- One idea per sentence
- No jargon unless your audience uses it

### Voice Examples

**❌ Bad (Corporate):**
> "Our innovative platform leverages cutting-edge technology to empower users with a seamless, enterprise-grade solution for optimizing their workflow efficiency."

**✅ Good (Casual & Direct):**
> "Stop wasting hours on manual work. This does it in 5 minutes."

**❌ Bad (Hype):**
> "Revolutionary AI-powered game-changer that will transform how you think about productivity forever!"

**✅ Good (Real Benefits):**
> "Validates your app ideas in 5 minutes so you don't waste a week building something nobody wants."

## Codebase Understanding Protocol

**ALWAYS start by reading the codebase to understand context.**

### Step 1: Find Core Documentation

```bash
# Look for README, docs, or similar
Glob: **/README.md
Glob: **/docs/*.md
Read: package.json (get app name, description)
```

### Step 2: Understand Features

```bash
# Look for feature implementations
Glob: **/src/**/*.{ts,tsx,js,jsx}
Grep: "export.*function|export.*const" (find main functions)
Grep: "// Feature:|TODO" (find feature comments)
```

### Step 3: Identify Value Prop

Look for:

- What problem does this solve?
- Who is the target user?
- What's the main benefit?
- What makes it different?

Extract from:

- README description
- Landing page copy (if exists)
- Component names and structure
- API routes and functionality

### Step 4: Synthesize Understanding

Create a mental model:

- **App name:** [from package.json]
- **What it does:** [one sentence]
- **Target user:** [specific person]
- **Main problem:** [what pain does it solve]
- **Key features:** [list 3-5]
- **Unique angle:** [what's different]

**Then proceed with writing marketing content based on this understanding.**

## Content Templates

### 1. Landing Page Feature Section

**Format: Problem → Solution → Benefit**

```markdown
## [Feature Name]

[One sentence describing the annoying problem this solves]

[2-3 sentences explaining how the feature works in simple terms]

**The result?** [Specific, measurable outcome the user gets]

[Optional: One sentence with a micro-benefit or use case]
```

**Example:**

```markdown
## Instant Idea Validation

You spend a week building something, launch it, and... crickets. Nobody wants it.

Search for competitors, check pricing, scan Reddit for demand signals—all in one click. Get a clear "Build It" or "Skip It" verdict in 5 minutes.

**The result?** You only build ideas that people actually want to pay for.

Perfect for solo founders who can't afford to waste time on dead-end projects.
```

**Template for Claude:**

When writing landing page sections:

1. Read codebase to find the feature
2. Identify the specific pain point
3. Explain the solution simply (no jargon)
4. State the concrete benefit
5. Add a use case or target user context

### 2. Tweet Thread

**Format: Hook → Credibility → Value → CTA**

```
1/ [Hook: Bold claim or relatable problem in <280 chars]

2/ [Build credibility: Why you built this / your experience]

3/ [Show the value: What it does, how it helps]

4/ [Specific benefit: Concrete outcome with numbers]

5/ [How it works: 3-step simple explanation]

6/ [Social proof or use case: Who it's for]

7/ [CTA: Direct link with clear action]
```

**Example:**

```
1/ I wasted 3 weeks building an app nobody wanted.

Then I built a tool that validates ideas in 5 minutes. Here's how it works 🧵

2/ As a solo founder, I can't afford to build the wrong thing.

I needed a way to validate demand BEFORE writing code.

3/ The tool does what I used to do manually:
→ Searches for competitors
→ Checks pricing
→ Scans Reddit/forums for demand
→ Gives a clear verdict: Build It or Skip It

4/ Instead of spending a week building, you spend 5 minutes validating.

And you only build ideas people will actually pay for.

5/ How it works:
1. Describe your idea
2. AI researches the market
3. Get honest feedback: Build, Maybe, or Skip

6/ Perfect for:
→ Solo founders shipping MVPs
→ Indie hackers testing ideas
→ Anyone who can't afford to waste time

7/ Try it free: [link]

Stop building things nobody wants.
```

**Template for Claude:**

When writing tweet threads:

1. Hook: Start with relatable pain or bold statement
2. Personal angle: Why you built this (builds trust)
3. Value prop: What it does simply
4. Concrete benefit: Numbers or specific outcome
5. How it works: 3 steps maximum
6. Use case: Who it's for (be specific)
7. CTA: Direct link + clear action

**Tone:**

- Casual (like you're explaining to a friend)
- Use line breaks liberally
- Bullet points with → or • for readability
- One idea per tweet
- No hashtags unless specifically requested

### 3. Launch Email

**Format: Personal → Problem → Solution → Specific Value → Easy CTA**

```
Subject: [Direct, specific, no hype - max 6 words]

Hey [name],

[One sentence personal opener - why you're reaching out]

[2-3 sentences describing the problem they have in specific terms]

[One sentence transition to solution]

[2 sentences explaining what you built and how it solves the problem]

**What you get:**
• [Specific benefit 1]
• [Specific benefit 2]
• [Specific benefit 3]

[One sentence about how easy it is to start]

[Direct CTA with link]

[Sign-off]
[Your name]

P.S. [Optional: One extra detail, use case, or offer]
```

**Example:**

```
Subject: Validate ideas in 5 minutes

Hey Sarah,

Saw you're launching products on Product Hunt—thought you'd find this useful.

You know that sinking feeling when you spend weeks building something and nobody wants it? You second-guess every idea because you can't tell if there's real demand or you're just excited about it.

I built something that fixes this.

It's a tool that validates app ideas in 5 minutes by researching competitors, checking pricing, and scanning forums for demand. Then it gives you a clear verdict: Build It, Maybe, or Skip It.

**What you get:**
• Market research done in 5 minutes (not 5 hours)
• Honest feedback (no sugarcoating if the idea is saturated)
• Only build ideas people actually want

It's free to try and takes 2 minutes to test an idea.

→ [Link to try it]

Let me know what you think.

Jeremy

P.S. Used it myself before building this tool. Turns out, people actually wanted it.
```

**Template for Claude:**

When writing launch emails:

1. Subject: 6 words max, specific outcome
2. Personal opener: Why them? Build rapport
3. Specific problem: Use "you" language, paint the pain
4. Transition: "I built something..."
5. Solution: 2 sentences on what it does
6. Bullet benefits: 3 specific outcomes
7. Easy start: Remove friction ("free to try")
8. Direct CTA: Clear link + action verb
9. Sign off: Your name
10. P.S.: Add credibility or urgency

**Tone:**

- Like you're emailing a peer, not a customer
- Short paragraphs (1-3 sentences max)
- Conversational (use "you", ask questions)
- No exclamation marks (unless genuinely excited)

## Feature Announcement Template

**When user ships a feature and needs to announce it:**

### Social Media Post (Twitter/LinkedIn)

```
Just shipped: [Feature name]

[One sentence: what problem it solves]

Now you can [specific action] in [timeframe/ease].

[One sentence micro-benefit or use case]

Try it: [link]
```

**Example:**

```
Just shipped: Instant competitor research

Stop manually Googling for 2 hours to find out who else is building your idea.

Now you can see 5 competitors, their pricing, and market positioning in 30 seconds.

Perfect for validating ideas before you write a single line of code.

Try it: [link]
```

### Release Notes Style

```markdown
## [Feature Name] is live

[One sentence on what this unlocks]

**What changed:**
- [Specific improvement 1]
- [Specific improvement 2]
- [Specific improvement 3]

**Why it matters:**
[2-3 sentences on the real-world benefit]

**How to use it:**
1. [Simple step 1]
2. [Simple step 2]
3. [Simple step 3]

[CTA if applicable]
```

## Writing Process

### Step-by-Step for Every Request

1. **Read codebase** (if not already understood)
   - Find README, package.json
   - Identify key features
   - Extract value prop

2. **Identify the context**
   - What are we marketing? (feature, product, launch)
   - Who is the audience?
   - What's the goal? (awareness, signups, validation)

3. **Pick the format**
   - Landing page section
   - Tweet thread
   - Launch email
   - Feature announcement

4. **Write in brand voice**
   - Casual and direct
   - No buzzwords
   - Real benefits
   - Simple language

5. **Review against voice guidelines**
   - Remove any corporate speak
   - Add concrete numbers/outcomes
   - Ensure it sounds human
   - Check reading level

## Brand Voice Checklist

Before delivering any content, verify:

- [ ] **Casual tone**: Sounds like talking to a friend
- [ ] **No buzzwords**: Zero corporate jargon
- [ ] **Real benefits**: Specific outcomes, not vague promises
- [ ] **Simple language**: 8th-grade reading level
- [ ] **Concrete**: Numbers, timeframes, specific actions
- [ ] **Direct**: No fluff, get to the point
- [ ] **Human**: Contractions, questions, natural flow

## Common Mistakes to Avoid

### ❌ Don't Write Like This

**Too Corporate:**
> "Our platform streamlines your workflow with best-in-class automation capabilities."

**Too Hype:**
> "🚀 GAME-CHANGING AI TOOL!!! This will REVOLUTIONIZE everything!!!"

**Too Vague:**
> "Make your life easier with our solution that helps you be more productive."

**Too Technical:**
> "Leveraging machine learning algorithms to optimize decision-making paradigms."

### ✅ Write Like This

**Casual & Concrete:**
> "Automate the boring stuff. Save 5 hours a week."

**Direct & Specific:**
> "Validates your app ideas in 5 minutes so you don't waste a week building."

**Simple & Clear:**
> "See if people actually want your product before you build it."

**Human & Real:**
> "You know that feeling when you launch and nobody cares? This helps you avoid that."

## Examples by Use Case

### For a Validation Tool

**Landing Page Hero:**

```
Stop wasting weeks building apps nobody wants

Validate your idea in 5 minutes with real market research:
→ See who's already doing it
→ Check if people are paying for it
→ Get honest feedback: Build It or Skip It

Free to try. No signup required.
```

**Tweet:**

```
I wasted 3 weeks on an app that got 0 users.

Now I validate every idea in 5 minutes before writing code.

Here's how: [link]
```

**Email Subject:**

```
Stop building apps nobody wants
```

### For a Deployment Tool

**Landing Page Section:**

```
## Deploy in 2 minutes

You shouldn't need a DevOps team to ship a side project.

Connect your repo, pick a region, click deploy. Your app is live with SSL, custom domain, and auto-scaling.

**The result?** You spend time building features, not configuring servers.
```

**Tweet:**

```
Spent 6 hours configuring AWS to deploy a simple app.

Never again.

Built a tool that deploys in 2 minutes. No config files, no DevOps degree required.

Try it: [link]
```

### For a Form Builder

**Landing Page Section:**

```
## Build forms people actually fill out

Generic form builders give you generic forms. And people abandon generic forms.

Design custom forms that match your brand, add smart validation, and see real-time responses.

**The result?** 3x more completed submissions because the form doesn't feel like homework.
```

**Email:**

```
Subject: Forms that don't suck

Hey Alex,

Your forms are losing you signups.

Most form builders make everything look the same—boring, generic, like filling out paperwork. People see it and bounce.

I built a form builder that lets you match your brand and add smart validation.

**What you get:**
• Forms that look like they belong on your site
• Less abandoned submissions (3x completion rate)
• Real-time responses in your dashboard

Takes 5 minutes to build your first form.

→ [Try it free]

Jeremy

P.S. No code required. Seriously.
```

## Advanced: Adapting to Context

### If the app is technical (dev tool)

**Tone adjustments:**

- You can use some technical terms (they're not jargon to devs)
- Focus on time saved and pain avoided
- Relate to common dev frustrations
- "You know how [annoying dev thing]? This fixes that."

**Example:**
> "Stop wrestling with Docker configs. Deploy your Next.js app in 2 minutes."

### If the app is consumer-facing

**Tone adjustments:**

- Zero technical terms
- Focus on emotional benefits
- Use everyday analogies
- "Like [familiar thing], but for [use case]"

**Example:**
> "Meal planning that doesn't feel like homework. Get your weekly grocery list in 5 minutes."

### If the app is B2B

**Tone adjustments:**

- Still casual, but slightly more professional
- Focus on ROI and time savings
- Use "your team" language
- Concrete business outcomes

**Example:**
> "Your support team spends 10 hours/week on repetitive questions. This cuts it to 2."

## Quick Reference: Common Patterns

### Problem → Solution → Benefit

```
[Annoying problem]
[How we fix it]
**The result?** [Concrete benefit]
```

### Before/After

```
Before: [Pain point]
After: [With your tool]
```

### Time Saving

```
Used to take [long time]. Now takes [short time].
```

### "You know that feeling..."

```
You know that feeling when [relatable pain]?
[Your tool] fixes that.
```

### Social Proof

```
[Number] [specific users] use this to [specific outcome]
```

## Output Format

When generating marketing content:

1. **Show understanding** (brief summary of what you read from codebase)
2. **Provide content** (formatted and ready to use)
3. **Offer alternatives** (2-3 variations if appropriate)
4. **Suggest next steps** (where to use this, what to test)

**Example Output:**

```
Based on the codebase, this is an idea validation tool that helps solo founders research market demand before building.

Here's your landing page section:

---

## Instant Market Research

You spend a week building. You launch. Nobody wants it.

This tool searches for competitors, checks pricing, and scans forums for demand—all in 5 minutes. Then gives you a clear verdict: Build It, Maybe, or Skip It.

**The result?** You only build ideas people actually want to pay for.

Perfect for solo founders who can't afford to waste time on dead-end projects.

---

Alternative headline options:
- "Stop Building Apps Nobody Wants"
- "Validate Ideas in 5 Minutes"
- "Know if Your Idea Will Sell Before You Build It"

Suggested next steps:
- Use this on your landing page above the fold
- Test the headline with a small audience first
- Consider A/B testing "5 minutes" vs "before you build" angle
```

## Success Metrics

This skill succeeds when:

- Content sounds human and approachable
- Zero corporate buzzwords used
- Benefits are specific and concrete
- Reader immediately understands value
- Marketing copy drives action (signups, clicks)

This skill fails when:

- Sounds corporate or generic
- Uses hype or buzzwords
- Benefits are vague ("better", "easier")
- Reader isn't sure what the product does
- No clear call to action
