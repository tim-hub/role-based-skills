---
name: brainstormer
description: Generate brainstorm ideas from multiple thinking frameworks and perspectives. Use when the user asks to brainstorm, ideate, explore options, think through a problem, generate alternatives, or needs creative input on any topic.
---

# Brainstormer

Generate diverse ideas by applying structured thinking frameworks to any problem. Each framework forces a different angle, reducing blind spots and expanding the solution space.

## How to Use

When the user asks to brainstorm:

1. **Clarify the problem** - Restate the problem/goal in one sentence to confirm understanding.
2. **Select frameworks** - Pick 3-5 frameworks from the list below based on the problem type. Use more for open-ended problems, fewer for constrained ones.
3. **Generate ideas per framework** - Apply each selected framework, producing 2-4 ideas each.
4. **Present results** - Use the structured output format below.
5. **Synthesize** - End with a "Top Picks" section combining the strongest ideas across frameworks.

## Thinking Frameworks

### First Principles
Break the problem down to its fundamental truths. Remove all assumptions. Rebuild from scratch.
- Best for: Architecture decisions, challenging "we've always done it this way"

### SCAMPER
Apply each lens to the existing solution or concept:
- **S**ubstitute - What component can be replaced?
- **C**ombine - What can be merged together?
- **A**dapt - What can be borrowed from elsewhere?
- **M**odify - What can be enlarged, shrunk, or reshaped?
- **P**ut to other use - Can it serve a different purpose?
- **E**liminate - What can be removed entirely?
- **R**everse - What if we flip the order or logic?
- Best for: Improving existing features, refactoring, UX iteration

### Reverse Thinking (Inversion)
Ask "How would we make this fail?" or "What's the opposite of what we want?" Then invert those answers into solutions.
- Best for: Risk analysis, finding hidden failure modes, defensive design

### Analogy Transfer
Find a solved problem in a different domain that shares structural similarities. Map the solution back.
- Best for: Novel problems, cross-domain innovation, finding proven patterns

### Constraint Manipulation
Deliberately add or remove constraints to shift thinking:
- "What if we had unlimited time/budget?"
- "What if this had to ship tomorrow?"
- "What if we could only use 10% of the code?"
- Best for: Breaking deadlocks, scope negotiation, MVP definition

### Five Whys
Ask "why" repeatedly to drill to root cause, then brainstorm solutions at the deepest level.
- Best for: Debugging, root cause analysis, problem reframing

### Stakeholder Perspectives
Consider the problem through the eyes of different stakeholders:
- End user, Developer, Product manager, Business/revenue, Security/compliance, Operations/SRE
- Best for: Feature design, trade-off decisions, prioritization

## Framework Selection Guide

| Problem Type | Recommended Frameworks |
|---|---|
| New feature / greenfield | First Principles, Analogy Transfer, Stakeholder Perspectives |
| Improve existing solution | SCAMPER, Constraint Manipulation, Stakeholder Perspectives |
| Debugging / incident | Five Whys, Reverse Thinking, Constraint Manipulation |
| Architecture / design | First Principles, Reverse Thinking, Analogy Transfer |
| Stuck / no ideas | Constraint Manipulation, SCAMPER, Reverse Thinking |
| Strategy / prioritization | Stakeholder Perspectives, First Principles, Constraint Manipulation |

## Output Format

Present ideas grouped by framework in this structure:

```markdown
## Brainstorm: [Problem Statement]

### [Framework Name]
| # | Idea | Rationale | Effort | Impact |
|---|------|-----------|--------|--------|
| 1 | ... | ... | Low/Med/High | Low/Med/High |
| 2 | ... | ... | Low/Med/High | Low/Med/High |

### [Next Framework Name]
| # | Idea | Rationale | Effort | Impact |
|---|------|-----------|--------|--------|
| 1 | ... | ... | Low/Med/High | Low/Med/High |

---

### Top Picks
The strongest ideas across all frameworks, with brief justification:
1. **[Idea]** - Why this stands out
2. **[Idea]** - Why this stands out
3. **[Idea]** - Why this stands out
```

## Guidelines

- Prefer **quantity over perfection** in the generation phase; filter in the synthesis.
- Flag any idea that carries significant risk or trade-off.
- If the problem is domain-specific, weave in relevant domain knowledge.
- Keep each idea description to 1-2 sentences. Elaborate only if the user asks.
- When ideas conflict, present both sides rather than picking one silently.
