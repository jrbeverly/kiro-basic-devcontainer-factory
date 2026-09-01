---
title: Route object-created events to the runbook
---

Add the EventBridge rule that matches the bucket's object-created events and
targets the runbook, passing the bucket name and object key through as its inputs,
along with the role the rule needs to start an execution. An upload now starts a
runbook execution.

The flow will later write its own output back into the bucket it watches. Decide
here whether the rule filters to MP4 or the runbook does, and say which in your
notes.

Files: `events.tf`, `iam.tf`.
