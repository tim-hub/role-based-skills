---
name: reviewer
description: Review code changes from git commit history for quality, security, and adherence to codebase patterns. Use when the user asks to review commits, review code changes, review git history, or perform a code review on recent changes.
---

# Reviewer

Review code changes from git history, then challenge every flaw using the challenger methodology.

## Inputs

The user may provide:
- **Two commit hashes**: review changes from `<start_hash>` to `<end_hash>`
- **One commit hash**: review that single commit
- **No commit hashes**: review the last commit (`HEAD~1..HEAD`), stashed uncommited changes or unstashed changes

## Workflow

Copy this checklist and track progress:

```
Review Progress:
- [ ] Step 1: Resolve commit range
- [ ] Step 2: Gather change context
- [ ] Step 3: Read changed files for pattern context
- [ ] Step 4: Analyze changes
- [ ] Step 5: Produce challenge report
```

### Step 1: Resolve Commit Range

Determine the commit range based on user input:

| Input | Git range |
|-------|-----------|
| Two hashes: `<start>` `<end>` | `<start>..<end>` |
| One hash: `<hash>` | `<hash>~1..<hash>` |
| No hashes | `HEAD~1..HEAD` |

Run: `git log --oneline <range>` to confirm the commits exist and list them.

### Step 2: Gather Change Context

Run these commands to collect the full picture:

```bash
# List all changed files
git diff --name-status <range>

# Get the full diff with context
git diff <range>

# Get commit messages for intent
git log --format="%h %s%n%b" <range>
```

### Step 3: Read Changed Files for Pattern Context

For each **modified** file (not deleted), read the full current version to understand:
- Existing code style and conventions
- Patterns used in the surrounding code
- How similar functionality is implemented elsewhere in the same file

For **new** files, find similar files in the same directory or module to establish expected patterns:

```bash
# Find sibling files for pattern reference
ls <directory_of_new_file>/
```

Read 1-2 sibling files to understand local conventions.

### Step 4: Analyze Changes

Review each change against these criteria:

**Pattern Adherence** (primary focus alongside challenger dimensions):
- Does the change follow the existing code style in the file?
- Are naming conventions consistent with the codebase?
- Does it reuse existing utilities rather than reinventing?
- Does it follow established architectural patterns in the module?
- Are imports organized consistently with the rest of the file?
- Does error handling follow the existing pattern?

### Step 5: Produce Challenge Report

Apply the **Challenger** methodology from `/Users/hbai/.cursor/skills/challenger/SKILL.md`. Read that skill and follow its challenge dimensions and output format.

Add one extra dimension to the challenger report:

### 8. Pattern Adherence
- Deviations from existing code style
- Inconsistent naming with surrounding code
- Reinvented utilities that already exist
- Architectural pattern violations
- Import style inconsistencies

## Output Format

Structure the final output as:

```
## Code Review: <short description of changes>

### Commits Reviewed
- `<hash>` <message>
- ...

### Files Changed
- A: <new files>
- M: <modified files>
- D: <deleted files>

## Challenge Report

### Critical (must fix)
- **[DIMENSION]**: Description. Why it's dangerous. Attack/failure scenario.

### High Risk (strongly recommend fixing)
- **[DIMENSION]**: Description. Impact. Scenario.

### Medium Risk (should consider)
- **[DIMENSION]**: Description. Impact. Scenario.

### Low Risk (nitpick / hardening)
- **[DIMENSION]**: Description.

### Summary
X critical, Y high, Z medium, W low issues found.
Verdict: SAFE / RISKY / DANGEROUS
```

## Rules

1. **Always read the actual changed code** — never guess from file names alone.
2. **Always read surrounding code** — pattern adherence requires full file context.
3. **Be specific** — cite exact files, lines, and functions.
4. **Never say "looks good"** — there is always something to challenge.
5. **Prioritize ruthlessly** — critical issues first, nitpicks last.
6. **Challenge assumptions** — if the author assumes X, ask "what if not X?"
7. **Question missing things** — missing validation? missing tests? missing error handling?
