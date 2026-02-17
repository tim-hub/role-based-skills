---
name: coordinator
description: Orchestrate multiple skills through a phased workflow to solve problems, generate ideas, create plans, or build software. Use when the user asks to coordinate roles, run a full workflow, or when a task benefits from brainstorming, challenging, planning, and implementing in sequence.
---

# Coordinator

Orchestrate skills through a phased workflow: brainstorm, challenge, design/plan, challenge, implement, finish.

**Announce at start:** "Using the coordinator skill to orchestrate this workflow."

## Determine Scope

Classify the request before starting:

| Scope | Phases | Example |
|-------|--------|---------|
| **Idea** | 1-2 | "Help me think through X" |
| **Plan** | 1-4 | "Plan how to build X" |
| **Build** | 1-6 | "Build X for me" |

Ask if unclear: "Is this an idea exploration, a plan, or a full build?"

## Phases

### Phase 1: Brainstorm

1. Load and apply the **brainstormer** skill
   - Generate diverse ideas across multiple thinking frameworks
   - Produce 2-4 ideas per framework, covering 3-5 frameworks
2. Load and apply the **brainstorming** skill
   - Refine the best ideas through collaborative dialogue
   - Present design in sections, validate incrementally

**Output:** Refined ideas with rationale and top picks.

**Checkpoint:** Present top ideas. Continue unless redirected.

### Phase 2: Challenge Ideas

1. Load and apply the **challenger** skill
   - Attack ideas across all dimensions (security, correctness, performance, scalability, UX, maintainability, edge cases)

**Gate:**
- Critical issues found → **STOP**. Present issues, ask how to proceed.
- Medium/low only → Summarize findings, continue automatically.

**Output:** Challenge report with severity ratings.

**For Idea scope:** Stop here. Present final deliverable.

### Phase 3: Design & Plan

Run applicable sub-phases:

**3a. Design** (if UI/UX involved):
- Load and apply the **designer** skill
- Review and improve UX, produce design recommendations

**3b. Plan:**
- Load and apply the **planner** skill
- Create structured plan with approaches, trade-offs, risks

**3c. Implementation Plan** (Build scope only):
- Load and apply the **writing-plans** skill
- Create detailed task-level implementation plan with file paths and code examples

**Checkpoint:** Present the plan. Continue unless redirected.

**For Plan scope:** Stop here. Present final deliverable.

### Phase 4: Challenge Plan

1. Load and apply the **challenger** skill again
   - Evaluate the plan for risks, missing steps, wrong ordering, feasibility

**Gate:**
- Critical issues found → Revise plan based on findings, re-challenge. Max 2 revision cycles.
- Medium/low only → Summarize, continue automatically.

**Output:** Validated, battle-tested plan.

### Phase 5: Implement

1. Load and apply the **test-driven-development** skill
   - TDD is mandatory: no production code without a failing test first
2. Load and apply the **executing-plans** skill
   - Execute plan in controlled batches with review checkpoints

**Within each batch:**
- RED: Write failing test
- GREEN: Minimal code to pass
- REFACTOR: Clean up, stay green
- Review between batches

**Gate:**
- Tests failing after 2 fix attempts → **STOP**. Report issue, ask for direction.
- Batch complete → Brief summary, continue to next batch.

### Phase 6: Finish

1. Load and apply the **finishing-a-development-branch** skill
   - Verify all tests pass
   - Present completion options (merge, PR, keep, discard)
   - Clean up worktree if applicable

## Autonomy Rules

| Situation | Action |
|-----------|--------|
| Challenger finds **critical** issues | **STOP** — present issues, ask for direction |
| Challenger finds medium/low issues | Summarize and continue |
| Between major phases | Brief checkpoint, continue unless redirected |
| Tests failing during implementation | Attempt fix twice; if stuck, **STOP** |
| Ambiguous requirements discovered | **STOP** — ask for clarification |
| Phase not applicable to request | Skip with brief note |

## Workflow Diagram

```
[Request] → Classify scope (Idea / Plan / Build)
     │
     ▼
Phase 1: Brainstorm ──────── brainstormer → brainstorming
     │ checkpoint
     ▼
Phase 2: Challenge Ideas ─── challenger
     │ STOP if critical
     ▼                        ← Idea scope ends here
Phase 3: Design & Plan ───── designer → planner → writing-plans
     │ checkpoint
     ▼                        ← Plan scope ends here
Phase 4: Challenge Plan ──── challenger
     │ STOP if critical → revise → re-challenge
     ▼
Phase 5: Implement ────────── TDD + executing-plans
     │ STOP if stuck
     ▼
Phase 6: Finish ───────────── finishing-a-development-branch
```

## Key Principles

- **One skill at a time** — Load and complete each skill before moving to the next.
- **Challenge gates** — Critical issues block progress; medium/low don't.
- **TDD is non-negotiable** — No implementation code without failing tests first.
- **Incremental validation** — Check with human at phase boundaries.
- **Skip what doesn't apply** — Not every request needs all phases.
- **Autonomy with guardrails** — Run freely, stop when uncertain or blocked.

## Skills Referenced

| Skill | Phase | Purpose |
|-------|-------|---------|
| brainstormer | 1 | Generate diverse ideas via thinking frameworks |
| brainstorming | 1 | Refine ideas through collaborative dialogue |
| challenger | 2, 4 | Adversarial evaluation of ideas and plans |
| designer | 3a | UX review and improvement |
| planner | 3b | Structured plan with trade-offs |
| writing-plans | 3c | Detailed implementation tasks |
| executing-plans | 5 | Batch execution with review checkpoints |
| test-driven-development | 5 | Red-green-refactor cycle |
| finishing-a-development-branch | 6 | Branch completion and cleanup |
