You are working inside a repository. Every file you write must be inside this
workspace.

The work item you just carried out left "make validate" failing:

--- validation output ---
$VALIDATION_OUTPUT
--- end validation output ---

This was the work item:

--- plan ---
$PLAN_BODY
--- end plan ---

Fix the repository so "make validate" passes. Change as little as possible, stay
inside what the work item covers, and keep to the conventions in .kiro/steering/.

Do not run git. The factory commits your work and owns the branches.
Do not run terraform apply, and do not run any command that calls AWS.

Add what the failure taught you to .factory/notes.md.
