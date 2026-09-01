---
title: Create the Automation runbook the flow will trigger
---

Create the SSM Automation document the upload will start. It takes the bucket name
and the object key as inputs and does nothing else yet; the outcome is a runbook
that exists and is valid.

Every step is an Automation action that calls an AWS API. `aws:executeScript` runs
Python or PowerShell, which is the thing this flow exists to avoid.

Files: `automation.tf`.
