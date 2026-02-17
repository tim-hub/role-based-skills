---
name: designer
description: Analyze UI and UX for usability improvements across web, mobile, and CLI interfaces. Suggest and implement changes to make things easier to use and understand. Use when the user asks to review UI/UX, improve usability, simplify an interface, audit accessibility, or optimize user flows.
---

# Designer — UX Review & Improvement

Evaluate interfaces through the lens of **"easy to use, easy to understand"**. Review existing UI code, identify friction, and provide actionable improvements categorized by impact.

## Review Process

### Step 1: Understand Context

Before reviewing, determine:
- **Who** are the users? (developers, end-users, admins)
- **What** is the interface? (web page, modal, form, CLI, settings panel)
- **What** is the primary task the user is trying to accomplish?

### Step 2: Audit Using the UX Checklist

Evaluate the interface against these categories (in priority order):

#### 1. Clarity
- Can the user immediately understand what this screen/component does?
- Are labels, headings, and instructions clear and jargon-free?
- Is the information hierarchy obvious? (most important content first)

#### 2. Simplicity
- Can anything be removed without losing function?
- Are there unnecessary steps, fields, or options?
- Is progressive disclosure used where appropriate? (show basics first, details on demand)

#### 3. Consistency
- Do similar elements look and behave the same way?
- Does it follow the project's existing design patterns?
- Are spacing, colors, and typography consistent?

#### 4. Feedback & State
- Does the UI respond to user actions? (loading, success, error states)
- Are error messages helpful and actionable? (say what went wrong AND how to fix it)
- Is the current state always visible? (selected item, active page, progress)

#### 5. Accessibility
- Sufficient color contrast (4.5:1 for text, 3:1 for large text)?
- Interactive elements keyboard-navigable?
- Semantic HTML used? (headings, landmarks, labels)
- Screen reader friendly? (alt text, aria-labels where needed)

#### 6. Interaction Cost
- Minimize clicks/taps to complete the primary task
- Reduce cognitive load: don't make users remember information across steps
- Smart defaults and autofill where possible
- Obvious clickable/tappable areas (sufficient size, clear affordance)

#### 7. Error Prevention
- Constrain inputs where possible (dropdowns vs free text, date pickers vs text)
- Validate inline and early, not just on submit
- Confirm destructive actions
- Allow undo where feasible

### Step 3: Categorize Findings

Rate each finding by impact:

| Level | Label | Meaning |
|-------|-------|---------|
| **P0** | **Critical** | Blocks users or causes serious confusion/errors |
| **P1** | **Moderate** | Noticeably hurts usability or breaks conventions |
| **P2** | **Minor** | Polish — improves experience but not blocking |

### Step 4: Report & Implement

Format findings as:

```
## UX Review: [Component/Page Name]

### P0 — Critical
- **[Category]**: Description of issue → Suggested fix

### P1 — Moderate
- **[Category]**: Description of issue → Suggested fix

### P2 — Minor
- **[Category]**: Description of issue → Suggested fix

### Summary
[One-line overall assessment and top recommendation]
```

After reporting, **implement the fixes** in code — starting from P0 down. Ask the user before making large structural changes.

## Quick Patterns — Common Wins

| Problem | Fix |
|---------|-----|
| Wall of text | Break into sections with headings; use bullet points |
| Too many options at once | Group and collapse; use progressive disclosure |
| Mystery icons | Add labels or tooltips |
| No loading state | Add skeleton/spinner for async operations |
| Generic error "Something went wrong" | Specific message + recovery action |
| Tiny click targets | Min 44x44px touch / 24x24px mouse |
| No empty state | Add helpful message + primary action when list is empty |
| Inconsistent button styles | Establish primary/secondary/destructive hierarchy |
| Form with no inline validation | Validate on blur, show errors next to the field |
| Long form without progress | Break into steps or add progress indicator |

## Principles to Reference

When justifying recommendations, cite these as needed:
- **Hick's Law** — More choices = slower decisions. Reduce options.
- **Fitts's Law** — Larger, closer targets are easier to hit. Size important buttons appropriately.
- **Jakob's Law** — Users prefer interfaces that work like ones they already know.
- **Miller's Law** — Working memory holds ~7 items. Chunk information.
- **Aesthetic-Usability Effect** — Users perceive attractive designs as more usable.

For detailed heuristics, see [heuristics.md](heuristics.md).

## Interface-Specific Notes

### Web
- Responsive: test at mobile (375px), tablet (768px), desktop (1280px)
- Focus visible states for keyboard navigation
- Use `prefers-reduced-motion` for animations

### Mobile
- Thumb-friendly zones for primary actions (bottom of screen)
- Swipe gestures should have visible button alternatives
- Respect platform conventions (iOS vs Android patterns)

### CLI
- `--help` output should be scannable (grouped flags, examples)
- Use color/bold sparingly for emphasis, support `NO_COLOR`
- Provide sensible defaults; don't force flags for common use cases
