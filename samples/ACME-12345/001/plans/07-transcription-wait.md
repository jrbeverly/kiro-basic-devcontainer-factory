---
title: Wait for the job and leave the results beside the source object
---

Have the runbook wait for the transcription job to finish, then leave the results
under the source key with `.vtt` and `.json` appended, so `talk.mp4` produces
`talk.mp4.vtt` and `talk.mp4.json`.

Transcribe may dictate its own output location. If it does, moving the result into
place is another API call in the runbook rather than a script; record what it
actually does before adding that step.

Files: `automation.tf`, `iam.tf`.
