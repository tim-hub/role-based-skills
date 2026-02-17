#!/bin/bash

# Script to rename all directories starting with "skill-" to remove the "skill-" prefix
# Processes nested directories first to avoid path conflicts

set -e  # Exit on any error

echo "Starting directory renaming process..."

# Change to the skills directory
cd "/Users/hbai/.codeium/windsurf/skills"

# First, rename nested directories (innermost first)
echo "Renaming nested directories..."


echo "Nested directories renamed successfully."

# Now rename top-level directories
echo "Renaming top-level directories..."


mv "skill-executing-plans" "executing-plans"
mv "skill-finishing-a-development-branch" "finishing-a-development-branch"
mv "skill-receiving-code-review" "receiving-code-review"
mv "skill-requesting-code-review" "requesting-code-review"
mv "skill-root-cause-tracing" "root-cause-tracing"
mv "skill-sharing-skills" "sharing-skills"
mv "skill-subagent-driven-development" "subagent-driven-development"
mv "skill-systematic-debugging" "systematic-debugging"
mv "skill-test-driven-development" "test-driven-development"
mv "skill-testing-anti-patterns" "testing-anti-patterns"
mv "skill-testing-skills-with-subagents" "testing-skills-with-subagents"
mv "skill-using-git-worktrees" "using-git-worktrees"
mv "skill-verification-before-completion" "verification-before-completion"
mv "skill-writing-plans" "writing-plans"
mv "skill-writing-skills" "writing-skills"

echo "Top-level directories renamed successfully."

# Verify the changes
echo "Verifying renamed directories..."
echo "Current directories:"
ls -la | grep -E "^[d].*/" | grep -v "^d.*\.\." | grep -v "^d.*\.$" | awk '{print $9}' | sort

echo "Directory renaming completed successfully!"
