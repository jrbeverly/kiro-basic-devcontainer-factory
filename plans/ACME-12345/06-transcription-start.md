---
title: Start a transcription job for the uploaded object
---

Replace the runbook's empty body with the step that starts a transcription job for
the object that triggered it, and give the runbook's role what that call needs.
Only MP4 objects start a job.

No custom vocabulary. If Transcribe turns out to require one, mock the smallest one
that satisfies it and record why it was needed.

Files: `automation.tf`, `iam.tf`.
