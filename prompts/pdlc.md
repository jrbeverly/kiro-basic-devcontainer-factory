You are working inside a repository. Every file you write must be inside this
workspace.

Here is the epic:

--- epic ---
$EPIC_BODY
--- end epic ---

Inspect this repository, then break the epic's stories into individual work items
and write one Markdown plan per work item into .factory/plans/. Name each file
NN-<slug>.md, numbered from 01 in the order they have to be carried out, so a work
item only ever depends on lower-numbered ones.

Start every plan with exactly this front matter:

---
title: <one imperative line>
---

Below the front matter write the brief for that one work item in a few sentences:
the outcome it has to reach, the files it touches, and the constraints from the
epic that bear on it.

Write the outcome, not the implementation. Do not name provider arguments, blocks,
or attributes, and do not hedge with alternatives; the session carrying out the
work item reads the provider schema itself and decides. Do not restate this
repository's conventions from .kiro/steering/, and do not repeat the validation
command; every work item is validated with "make validate".

Name every file relative to the root of this workspace.

A work item has to be small enough to finish and validate on its own, and a story
may need more than one. Write only the plan files.
