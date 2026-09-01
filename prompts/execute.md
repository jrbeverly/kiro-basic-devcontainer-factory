You are working inside a repository. Every file you write must be inside this
workspace.

Carry out this one work item:

--- plan ---
$PLAN_BODY
--- end plan ---

This repository's conventions are in .kiro/steering/. Follow them; where the plan
conflicts with them, the conventions win.

The plan is a brief, not a specification. Where it names something the provider
does not have, read the schema, do what the provider actually supports, and record
it in your notes.

Leave "make validate" passing.

Do not run git. The factory commits your work and owns the branches.
Do not run terraform apply, and do not run any command that calls AWS.

Write what you learn to .factory/notes.md as you hit it: missing documentation,
assumptions you were forced to make, problems with existing code, and
instructions that could be improved.
