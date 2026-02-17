# UX Heuristics Reference

Detailed reference for Nielsen's 10 Usability Heuristics. Use when you need to cite specific heuristics in a review.

## 1. Visibility of System Status
The system should keep users informed about what is going on through timely feedback.
- Show loading indicators for operations > 300ms
- Confirm successful actions (toast, inline message)
- Show progress for multi-step operations

## 2. Match Between System and Real World
Use language and concepts familiar to the user, not system-oriented terms.
- "Remove" not "Delete record from database"
- Date formats matching user's locale
- Icons that map to real-world metaphors

## 3. User Control and Freedom
Users make mistakes. Provide clear exits and undo.
- Close/cancel on every modal and dialog
- Undo for destructive actions (soft delete, trash)
- Back navigation always available

## 4. Consistency and Standards
Follow platform conventions and internal patterns.
- Same action = same word everywhere (don't mix "Save" / "Submit" / "Confirm" for the same concept)
- Consistent layout patterns across pages
- Standard keyboard shortcuts

## 5. Error Prevention
Design to prevent errors before they happen.
- Disable invalid options rather than showing error after selection
- Type-ahead / autocomplete for known values
- Confirmation for irreversible actions

## 6. Recognition Rather Than Recall
Minimize memory load. Make options and actions visible.
- Show recent items / search history
- Inline help and contextual hints
- Visible navigation (don't rely solely on memorized paths)

## 7. Flexibility and Efficiency of Use
Accelerators for expert users without cluttering the novice experience.
- Keyboard shortcuts for power users
- Bulk actions for lists
- Customizable defaults / preferences

## 8. Aesthetic and Minimalist Design
Every extra element competes with relevant information.
- Remove decorative elements that don't aid comprehension
- Use whitespace to separate groups
- One primary action per screen section

## 9. Help Users Recognize, Diagnose, and Recover from Errors
Error messages should be in plain language, indicate the problem, and suggest a solution.
- Bad: "Error 422"
- Good: "Email address is already in use. Try logging in instead."

## 10. Help and Documentation
Even well-designed systems need help. Make it searchable and task-focused.
- Contextual help near the feature
- Tooltips for non-obvious controls
- Onboarding for complex features
