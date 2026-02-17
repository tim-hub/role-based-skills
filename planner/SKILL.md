---
name: planner
description: Create step-by-step plans for solving problems, debugging issues, building features, or architecting complex solutions. Always includes pros/cons analysis and risk consideration. Use when the user asks to plan, create a roadmap, break down a task, design an approach, outline steps, or needs a structured path forward.
---

# Planner

Create clear, actionable step-by-step plans. Every plan considers trade-offs, risks, and alternatives so you make informed decisions before writing a single line of code.

## How to Use

When the user asks to plan:

1. **Clarify the goal** - Restate the objective in one sentence. Identify the plan type.
2. **Gather context** - Examine relevant code, docs, configs, and constraints before planning.
3. **Identify approaches** - For non-trivial problems, outline 2-3 candidate approaches before committing to one.
4. **Build the plan** - Break the chosen approach into concrete, ordered steps.
5. **Analyze trade-offs** - Add pros/cons for each significant decision point.
6. **Flag risks** - Call out what could go wrong and how to mitigate it.
7. **Present the plan** - Use the output format below.

## Plan Types

Select the appropriate planning mode based on the user's goal:

### Problem Solving
Break a well-defined problem into steps toward a solution.
- Focus on: Root cause, constraints, solution options, validation criteria

### Debugging / Investigation
Systematically narrow down the source of a bug or unexpected behavior.
- Focus on: Hypotheses, evidence gathering, isolation steps, verification

### Feature Building
Plan the implementation of a new feature within an existing codebase.
- Focus on: Requirements, affected components, data flow, backward compatibility, testing

### Application / Architecture
Design a system or application from scratch or plan a major restructuring.
- Focus on: Component boundaries, technology choices, data model, integration points, scalability

### Migration / Refactoring
Plan a safe transition from current state to desired state.
- Focus on: Incremental steps, rollback strategy, backward compatibility, zero-downtime

## Planning Principles

1. **Start from what exists** - Read the codebase before proposing changes. Reuse existing patterns.
2. **Smallest steps possible** - Each step should be independently testable or verifiable.
3. **Dependencies first** - Order steps so blockers are resolved early.
4. **Always have a rollback** - For risky steps, define how to undo.
5. **Make trade-offs explicit** - Never silently pick a side. Surface the decision.
6. **Scope ruthlessly** - Separate "must have" from "nice to have". Flag scope creep.

## Output Format

```markdown
# Plan: [Goal in one sentence]

## Context
[Brief summary of current state, constraints, and relevant findings from codebase exploration]

## Approach

### Option A: [Name]
[One-paragraph description]

| Pros | Cons |
|------|------|
| ... | ... |
| ... | ... |

### Option B: [Name]
[One-paragraph description]

| Pros | Cons |
|------|------|
| ... | ... |
| ... | ... |

**Recommended**: Option [X] — [One-sentence justification]

## Steps

### Phase 1: [Phase Name]
- [ ] **Step 1**: [Action] — [Why this step matters]
- [ ] **Step 2**: [Action] — [Why this step matters]
  - Verify: [How to confirm this step succeeded]

### Phase 2: [Phase Name]
- [ ] **Step 3**: [Action] — [Why this step matters]
- [ ] **Step 4**: [Action] — [Why this step matters]
  - Verify: [How to confirm this step succeeded]

## Risks & Mitigations
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| ... | Low/Med/High | Low/Med/High | ... |
| ... | Low/Med/High | Low/Med/High | ... |

## Out of Scope
- [Items explicitly excluded and why]

## Definition of Done
- [Criteria that confirm the plan is fully executed]
```

## Debugging Plan Format

For debugging/investigation, use this specialized format instead:

```markdown
# Investigation: [Symptom / Issue]

## Observed Behavior
[What is happening]

## Expected Behavior
[What should happen]

## Hypotheses
| # | Hypothesis | Likelihood | Evidence Needed |
|---|-----------|-----------|-----------------|
| 1 | ... | High/Med/Low | ... |
| 2 | ... | High/Med/Low | ... |

## Investigation Steps
- [ ] **Step 1**: [Check/test] — Tests hypothesis #[N]
  - If confirmed: [Next action]
  - If ruled out: Proceed to step [N]
- [ ] **Step 2**: [Check/test] — Tests hypothesis #[N]
  - If confirmed: [Next action]
  - If ruled out: Proceed to step [N]

## Resolution
[To be filled after investigation — root cause + fix]
```

## Companion Skills

The planner works well in combination with other skills:

- **Brainstormer** (`/brainstormer`) - Use before planning to generate diverse solution options when the path forward is unclear. Feed the top picks into the planner's "Approach" section.
- **Challenger** (`/challenger`) - Use after planning to stress-test the plan. Feed the challenge report back to refine risks, mitigations, and step ordering.

### Recommended workflow for complex problems:
1. `/brainstormer` — Generate options
2. `/planner` — Structure the best options into a concrete plan
3. `/challenger` — Poke holes in the plan
4. Revise the plan based on challenge findings

## Guidelines

- Keep steps **atomic** — one action per step, not "set up auth and add rate limiting".
- Include **verification checkpoints** after risky or complex steps.
- For plans longer than 10 steps, group into **phases** with clear milestones.
- When estimating effort, use T-shirt sizes (XS/S/M/L/XL) rather than hours.
- If the plan depends on unknowns, add a **spike/discovery step** early to resolve them.
- Prefer **incremental delivery** — the plan should produce working software at each phase boundary.
- Always list what is **out of scope** to prevent scope creep.
