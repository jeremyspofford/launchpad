---
name: idea-validator
description: Provides brutally honest, quick validation of app/product ideas with market analysis, demand assessment, feasibility check, and monetization potential. Use when evaluating new project ideas before building.
allowed-tools: WebSearch, WebFetch, Read, Write
---

# Idea Validator

## Purpose

Give brutally honest, research-backed feedback on app ideas **before** investing time building them. Save builders from spending weeks on ideas that won't work.

## When to Use This Skill

- User is considering a new app/product idea
- User asks "should I build this?"
- User wants validation on an idea
- Before starting any new project
- When presented with multiple ideas to choose from

## Evaluation Framework

Assess each idea across 5 critical dimensions:

### 1. Market Analysis

- **Is this crowded?** Search for existing solutions
- **Who else is doing this?** List 3-5 direct competitors
- **What's different?** Identify the unique angle (if any)
- **Red flags**: "100+ similar apps", "dominated by big players", "graveyard of failed attempts"

### 2. Demand Assessment

- **Do people actually want this?** Look for evidence: Reddit threads, forum posts, complaints about current solutions
- **Or do they just say they do?** Distinguish between "would be nice" vs "I desperately need this"
- **Is this a painkiller or vitamin?** Painkillers solve urgent problems, vitamins are "nice to have"
- **Red flags**: "No evidence of demand", "people can live without this", "scratching your own itch only"

### 3. Feasibility Check

- **Can a solo builder ship this in 2-4 weeks?** Be realistic about scope
- **What's the MVP?** Define the absolute minimum version
- **Tech complexity**: Simple CRUD? Complex ML? Real-time features?
- **Red flags**: "Requires months of development", "needs specialized expertise", "marketplace with network effects"

### 4. Monetization Potential

- **How would this make money?** Subscription? One-time? Usage-based? Ads?
- **Are people paying for similar things?** Look for evidence
- **What's the price point?** $5/mo? $50/mo? $500?
- **Red flags**: "No clear monetization path", "expects users to pay for free alternatives", "AdSense is the only revenue model"

### 5. Interest Factor

- **Is this boring or compelling?** Be honest
- **Would you personally use this?** If no, big red flag
- **Is this trendy or timeless?** Riding a wave vs solving fundamental problems
- **Red flags**: "Solving a problem nobody has", "boring to build and boring to use", "just a feature, not a product"

## Research Instructions

1. **Search for competitors**: Use WebSearch to find 3-5 similar products
2. **Check demand signals**: Search Reddit, HN, Twitter for related complaints or requests
3. **Price research**: Find what similar products charge
4. **Tech stack check**: Assess complexity realistically

## Output Format

Deliver a concise, actionable verdict:

### 🚦 VERDICT: [Build It | Maybe | Skip It]

**Why:** (2-3 brutally honest sentences about why this idea is worth pursuing or should be avoided)

### 📊 Market Snapshot

- **Existing Solutions:** [List 3-5 competitors with brief notes]
- **Market Position:** [Crowded | Niche Opportunity | Blue Ocean | Graveyard]

### 💰 Monetization Reality Check

- **Pricing Model:** [What would work]
- **Comparable Products:** [What others charge]
- **Revenue Potential:** [Realistic assessment]

### ⚙️ Build Feasibility

- **MVP Scope:** [What's the absolute minimum]
- **Time Estimate:** [Realistic for solo builder]
- **Tech Complexity:** [Low | Medium | High]

### 🎯 What Would Make This Stronger

- [3-5 specific suggestions to improve the idea]
- Focus on: differentiation, demand validation, reduced scope, or monetization

## Critical Rules

1. **Be brutally honest** - Better to hear "no" now than after 100 hours of work
2. **Back up claims with research** - Use WebSearch to find real data
3. **Don't sugarcoat** - If the idea has been done 100 times, say so directly
4. **Suggest improvements** - Even bad ideas can have good kernels
5. **Reality check the timeline** - Most builders underestimate by 3-5x
6. **Monetization is non-negotiable** - "Build it and they will come" doesn't work

## Example Verdicts

**Build It Example:**
"Unique angle on an existing problem with clear evidence of demand and realistic 2-week MVP scope. Monetization path is proven by similar products at $20-50/mo."

**Maybe Example:**
"Interesting idea but market is crowded. Would need a very specific niche or unique distribution advantage to stand out. Consider pivoting to [specific suggestion]."

**Skip It Example:**
"This exact idea has been executed by 20+ products, including well-funded startups. No clear differentiation and no evidence people would switch from existing free solutions."

## Research Checklist

Before delivering verdict, verify:

- [ ] Found at least 3 competitors via WebSearch
- [ ] Checked pricing of similar products
- [ ] Searched for demand signals (Reddit, forums, Twitter)
- [ ] Realistically assessed build time for solo developer
- [ ] Identified specific differentiation or lack thereof
- [ ] Evaluated monetization against market reality

## Anti-Patterns to Avoid

- ❌ Cheerleading without research
- ❌ "Just build it and see what happens"
- ❌ Ignoring obvious competitors
- ❌ Underestimating build complexity
- ❌ Assuming demand without evidence
- ❌ "If you build it they will come" mentality

## Success Metrics

This Skill succeeds when:

- It **prevents** wasting time on doomed ideas
- It **validates** strong ideas with market evidence
- It **improves** weak ideas with specific suggestions
- It delivers **honest** feedback, not what the builder wants to hear
