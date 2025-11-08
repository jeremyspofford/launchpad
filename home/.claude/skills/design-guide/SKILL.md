---
name: design-guide
description: Enforces clean, modern UI design principles with minimal aesthetic, neutral color palettes, 8px grid spacing, proper typography hierarchy, and Tailwind CSS implementation. Use when building any UI component or reviewing design decisions.
allowed-tools: Read, Write
---

# Design Guide

## Purpose

Ensure every UI component looks **clean, modern, and professional** by enforcing consistent design principles, spacing, typography, and color usage.

## When to Use This Skill

- Building any UI component (buttons, forms, cards, modals, etc.)
- Creating new pages or layouts
- User asks "how should I style this?"
- Reviewing design decisions
- Setting up Tailwind config
- Before writing any component markup

## Core Design Principles

### 1. Clean and Minimal

- **Lots of white space** - Let content breathe
- **Not cluttered** - Remove unnecessary elements
- **One thing per screen** - Focus user attention
- **Subtract, don't add** - When in doubt, remove

### 2. Neutral Color Palette

- **Base**: Grays and off-whites (not pure #FFF or #000)
- **ONE accent color** used sparingly for CTAs and important actions
- **NO generic purple/blue gradients**
- **NO rainbow color schemes**

### 3. Consistent Spacing (8px Grid)

Use only these values:

- `8px` - Tight spacing (icon gaps, inline elements)
- `16px` - Standard spacing (between related items)
- `24px` - Medium spacing (between sections)
- `32px` - Large spacing (between major sections)
- `48px` - Extra large spacing (page sections)
- `64px` - Massive spacing (hero sections)

**Never use random values like 12px, 18px, 21px**

### 4. Typography Hierarchy

- **Minimum body text**: 16px (1rem)
- **Maximum 2 fonts**: One for headings, one for body (or same font, different weights)
- **Clear hierarchy**: h1 → h2 → h3 → body → small
- **Line height**: 1.5-1.6 for body text, 1.2-1.3 for headings
- **Font weights**: Use 400 (normal), 600 (semibold), 700 (bold) max

### 5. Shadows

- **Subtle, not heavy** - Think elevation, not decoration
- **3 shadow levels max**: small, medium, large
- **Never overdone** - Most elements don't need shadows

### 6. Rounded Corners

- **Not everything needs to be rounded**
- **Consistent border radius**: 4px (subtle), 8px (standard), 12px (prominent)
- **Never mix** random border-radius values

### 7. Interactive States

Every interactive element MUST have:

- **Hover**: Subtle change (slightly darker, shadow appears)
- **Active**: Clear pressed state
- **Disabled**: Obviously non-interactive (reduced opacity, no cursor)
- **Focus**: Visible focus ring for accessibility

### 8. Mobile-First

- **Design for mobile first**, enhance for desktop
- **Touch targets**: Minimum 44px × 44px for buttons
- **Readable on small screens** - No tiny text
- **Stack vertically** on mobile, horizontal on desktop

## Tailwind CSS Configuration

Use this as your starting point:

```js
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        // Neutral base (choose ONE off-white/gray palette)
        neutral: {
          50: '#fafafa',
          100: '#f5f5f5',
          200: '#e5e5e5',
          300: '#d4d4d4',
          400: '#a3a3a3',
          500: '#737373',
          600: '#525252',
          700: '#404040',
          800: '#262626',
          900: '#171717',
        },
        // ONE accent color (choose based on brand)
        accent: {
          DEFAULT: '#3b82f6', // blue example
          50: '#eff6ff',
          100: '#dbeafe',
          500: '#3b82f6',
          600: '#2563eb',
          700: '#1d4ed8',
        },
      },
      spacing: {
        // 8px grid system (already in Tailwind but be explicit)
        // 2 = 8px, 4 = 16px, 6 = 24px, 8 = 32px, 12 = 48px, 16 = 64px
      },
      fontSize: {
        // Minimum 16px for body text
        'body': ['16px', { lineHeight: '1.5' }],
        'sm': ['14px', { lineHeight: '1.5' }],
        'lg': ['18px', { lineHeight: '1.5' }],
        'xl': ['20px', { lineHeight: '1.4' }],
        '2xl': ['24px', { lineHeight: '1.3' }],
        '3xl': ['30px', { lineHeight: '1.2' }],
        '4xl': ['36px', { lineHeight: '1.2' }],
      },
      boxShadow: {
        'sm': '0 1px 2px 0 rgba(0, 0, 0, 0.05)',
        'DEFAULT': '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)',
        'md': '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)',
        'lg': '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)',
        // NO xl, 2xl shadows - too heavy
      },
      borderRadius: {
        'sm': '4px',
        'DEFAULT': '8px',
        'md': '8px',
        'lg': '12px',
        // NO excessive rounding
      },
    },
  },
}
```

## Component Patterns

### Buttons

**Good Example:**

```jsx
// Primary CTA
<button className="
  px-6 py-3
  bg-accent-600 text-white
  rounded-md
  shadow-sm
  font-medium
  hover:bg-accent-700
  active:bg-accent-800
  disabled:opacity-50 disabled:cursor-not-allowed
  transition-colors
">
  Create Account
</button>

// Secondary
<button className="
  px-6 py-3
  bg-white text-neutral-700
  border border-neutral-300
  rounded-md
  hover:bg-neutral-50
  active:bg-neutral-100
  disabled:opacity-50
  transition-colors
">
  Cancel
</button>

// Ghost/Text button
<button className="
  px-4 py-2
  text-neutral-700
  hover:bg-neutral-100
  rounded-md
  transition-colors
">
  Learn More
</button>
```

**Bad Example:**

```jsx
❌ <button className="px-5 py-2.5 bg-gradient-to-r from-purple-500 to-blue-500 text-white rounded-3xl shadow-2xl">
  Rainbow Gradient Button
</button>
```

### Cards

**Good Example:**

```jsx
// Option 1: Border only
<div className="
  p-6
  bg-white
  border border-neutral-200
  rounded-lg
">
  <h3 className="text-xl font-semibold mb-2">Card Title</h3>
  <p className="text-neutral-600">Card content goes here.</p>
</div>

// Option 2: Subtle shadow only (not both!)
<div className="
  p-6
  bg-white
  shadow-sm
  rounded-lg
">
  <h3 className="text-xl font-semibold mb-2">Card Title</h3>
  <p className="text-neutral-600">Card content goes here.</p>
</div>
```

**Bad Example:**

```jsx
❌ <div className="p-3 bg-white border-4 border-purple-500 shadow-2xl rounded-3xl">
  Heavy border AND heavy shadow
</div>
```

### Forms

**Good Example:**

```jsx
<form className="space-y-6">
  {/* Input field */}
  <div>
    <label
      htmlFor="email"
      className="block text-sm font-medium text-neutral-700 mb-2"
    >
      Email Address
    </label>
    <input
      id="email"
      type="email"
      className="
        w-full
        px-4 py-3
        border border-neutral-300
        rounded-md
        text-neutral-900
        placeholder:text-neutral-400
        focus:outline-none
        focus:ring-2
        focus:ring-accent-500
        focus:border-transparent
        disabled:bg-neutral-100
        disabled:cursor-not-allowed
      "
      placeholder="you@example.com"
    />
  </div>

  {/* Error state */}
  <div>
    <label className="block text-sm font-medium text-neutral-700 mb-2">
      Password
    </label>
    <input
      type="password"
      className="
        w-full
        px-4 py-3
        border-2 border-red-500
        rounded-md
        focus:outline-none
        focus:ring-2
        focus:ring-red-500
      "
    />
    <p className="mt-2 text-sm text-red-600">
      Password must be at least 8 characters
    </p>
  </div>
</form>
```

**Bad Example:**

```jsx
❌ <input className="px-2 py-1 text-xs border-neutral-500 rounded-full bg-gradient-to-r from-pink-500 to-yellow-500" />
```

### Modals/Dialogs

**Good Example:**

```jsx
<div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4">
  <div className="
    bg-white
    rounded-lg
    shadow-lg
    max-w-md
    w-full
    p-6
  ">
    <h2 className="text-2xl font-semibold mb-4">Confirm Action</h2>
    <p className="text-neutral-600 mb-6">
      Are you sure you want to delete this item?
    </p>
    <div className="flex gap-3 justify-end">
      <button className="px-4 py-2 text-neutral-700 hover:bg-neutral-100 rounded-md">
        Cancel
      </button>
      <button className="px-4 py-2 bg-red-600 text-white hover:bg-red-700 rounded-md">
        Delete
      </button>
    </div>
  </div>
</div>
```

### Navigation

**Good Example:**

```jsx
<nav className="border-b border-neutral-200">
  <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div className="flex justify-between items-center h-16">
      <div className="flex items-center gap-8">
        <span className="text-xl font-semibold">Logo</span>
        <div className="hidden md:flex gap-6">
          <a href="#" className="text-neutral-700 hover:text-neutral-900">
            Features
          </a>
          <a href="#" className="text-neutral-700 hover:text-neutral-900">
            Pricing
          </a>
          <a href="#" className="text-neutral-700 hover:text-neutral-900">
            About
          </a>
        </div>
      </div>
      <button className="px-4 py-2 bg-accent-600 text-white rounded-md hover:bg-accent-700">
        Sign In
      </button>
    </div>
  </div>
</nav>
```

## Color Usage Rules

### Do ✅

- **Background**: `bg-neutral-50` or `bg-white`
- **Text**: `text-neutral-900` (headings), `text-neutral-700` (body), `text-neutral-500` (muted)
- **Borders**: `border-neutral-200` or `border-neutral-300`
- **Primary CTA**: `bg-accent-600` (ONE accent color)
- **Hover states**: Slightly darker shade of base color

### Don't ❌

- NO `bg-gradient-to-r` unless explicitly brand-specific and approved
- NO random colors like `bg-pink-400`, `text-yellow-600` without purpose
- NO more than ONE accent color per app
- NO pure black text (`text-black`) - use `text-neutral-900`
- NO pure white backgrounds on white - use `bg-neutral-50`

## Spacing Checklist

Use this for every component:

- [ ] **Padding**: Multiple of 8px (use `p-2`, `p-4`, `p-6`, `p-8`)
- [ ] **Margin/Gap**: Multiple of 8px (use `gap-2`, `gap-4`, `gap-6`, `gap-8`)
- [ ] **Section spacing**: `mb-6`, `mb-8`, `mb-12`, `mb-16`
- [ ] **Container max-width**: `max-w-7xl` or `max-w-4xl` for reading content
- [ ] **No random spacing**: Never `p-5`, `gap-7`, `m-13`

## Typography Scale

```jsx
// Headings
<h1 className="text-4xl font-bold text-neutral-900 mb-4">
  Page Title
</h1>

<h2 className="text-3xl font-semibold text-neutral-900 mb-4">
  Section Title
</h2>

<h3 className="text-2xl font-semibold text-neutral-900 mb-3">
  Subsection
</h3>

// Body text
<p className="text-base text-neutral-700 leading-relaxed mb-4">
  Regular paragraph text goes here. Minimum 16px font size.
</p>

// Small/muted text
<p className="text-sm text-neutral-500">
  Helper text or captions
</p>

// Never use text-xs unless absolutely necessary (labels, badges)
```

## Bad Design Anti-Patterns

### ❌ Rainbow Gradients

```jsx
// NEVER
<div className="bg-gradient-to-r from-purple-500 via-pink-500 to-blue-500">
```

### ❌ Tiny Unreadable Text

```jsx
// NEVER - too small
<p className="text-xs">Important information here</p>

// Use text-sm minimum for body content
<p className="text-sm">Better, but still small</p>
```

### ❌ Inconsistent Spacing

```jsx
// NEVER - random values
<div className="mb-3 mt-5 pt-7 pb-9">
  <div className="gap-2.5">
    <div className="p-3.5">

// Always use 8px grid
<div className="mb-4 mt-4 pt-6 pb-6">
  <div className="gap-4">
    <div className="p-4">
```

### ❌ Every Element Different Color

```jsx
// NEVER
<div>
  <button className="bg-blue-500">Button 1</button>
  <button className="bg-green-500">Button 2</button>
  <button className="bg-purple-500">Button 3</button>
  <div className="bg-yellow-200 border-pink-500 text-red-600">
    Rainbow disaster
  </div>
</div>

// Use neutral base + ONE accent
<div>
  <button className="bg-accent-600">Primary</button>
  <button className="bg-white border border-neutral-300">Secondary</button>
  <button className="text-neutral-700 hover:bg-neutral-100">Ghost</button>
</div>
```

### ❌ Mixed Border Styles

```jsx
// NEVER - inconsistent rounding
<div className="rounded-sm">
  <div className="rounded-lg">
    <div className="rounded-full">
    </div>
  </div>
</div>

// Pick ONE border-radius and stick with it
<div className="rounded-lg">
  <div className="rounded-lg">
    <div className="rounded-lg">
    </div>
  </div>
</div>
```

## Accessibility Requirements

Every UI component MUST have:

- [ ] **Keyboard navigation**: All interactive elements accessible via keyboard
- [ ] **Focus states**: Visible focus ring (`focus:ring-2 focus:ring-accent-500`)
- [ ] **Color contrast**: Minimum 4.5:1 for text (WCAG AA)
- [ ] **Touch targets**: 44px minimum on mobile
- [ ] **Labels**: Proper `<label>` for all form inputs
- [ ] **ARIA attributes**: When semantic HTML isn't enough

## Quick Reference: Common Patterns

### Page Container

```jsx
<div className="min-h-screen bg-neutral-50">
  <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
    {/* Content */}
  </div>
</div>
```

### Section Spacing

```jsx
<section className="mb-12">
  <h2 className="text-3xl font-semibold mb-6">Section Title</h2>
  <div className="space-y-4">
    {/* Content with consistent vertical spacing */}
  </div>
</section>
```

### Grid Layout

```jsx
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
  {/* Cards or items */}
</div>
```

### Loading States

```jsx
<button
  disabled
  className="px-6 py-3 bg-accent-600 text-white rounded-md opacity-50 cursor-not-allowed"
>
  <span className="inline-flex items-center gap-2">
    <svg className="animate-spin h-5 w-5" /* spinner icon */>
    Loading...
  </span>
</button>
```

### Empty States

```jsx
<div className="text-center py-12">
  <p className="text-neutral-500 mb-4">No items found</p>
  <button className="px-4 py-2 bg-accent-600 text-white rounded-md">
    Create New Item
  </button>
</div>
```

## Design Review Checklist

Before considering a component "done":

- [ ] Uses only neutral colors + ONE accent color
- [ ] All spacing is multiple of 8px (8, 16, 24, 32, 48, 64)
- [ ] Text is minimum 16px for body content
- [ ] Shadows are subtle (sm or DEFAULT only)
- [ ] Border radius is consistent (8px or 12px)
- [ ] All interactive elements have hover/active/disabled states
- [ ] Has visible focus states for keyboard navigation
- [ ] Looks good on mobile (responsive)
- [ ] No gradients (unless explicitly approved)
- [ ] Not cluttered - has breathing room

## When in Doubt

Follow these rules:

1. **Less is more** - Remove elements before adding
2. **Consistent spacing** - When unsure, use 16px or 24px
3. **Neutral first** - Gray scale everything, add ONE accent color
4. **Subtle shadows** - Use `shadow-sm` or `shadow` only
5. **Simple borders** - `border-neutral-200` is safe
6. **Standard rounding** - `rounded-lg` (8px) is safe
7. **Readable text** - `text-base` (16px) is safe

## Success Metrics

This skill succeeds when:

- UI looks clean and professional
- Consistent spacing throughout
- Uses neutral palette with ONE accent color
- No unnecessary gradients or colors
- Typography is readable and well-sized
- Mobile-friendly and accessible

This skill fails when:

- Cluttered UI with random spacing
- Rainbow color scheme
- Tiny unreadable text
- Gradients everywhere
- Inconsistent styling
