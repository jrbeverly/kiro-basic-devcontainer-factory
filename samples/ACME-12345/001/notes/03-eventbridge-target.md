# Notes

## MP4 filter decision

The EventBridge rule does not filter to MP4 files. The rule captures all object-created events (`PutObject`, `PostObject`, `CopyObject`, `CompleteMultipartUpload`) and the runbook will handle filtering based on the object key extension.

Rationale: The rule should be generic for "all uploads" and the runbook logic can inspect the object key to determine whether to process a given file. This keeps the EventBridge rule reusable and shifts content-based decisions to the runbook where they belong.

## Files created/modified

- **events.tf** (new): Contains the EventBridge rule, IAM role for the rule, policy document, and event target that invokes the SSM Automation runbook with bucket name and object key inputs.

## Conventions followed

- Events grouped in their own file (`events.tf`) per the convention that resources are grouped by subject
- IAM policy built from `data "aws_iam_policy_document"` not `jsonencode`
- Role named `event` as a descriptive label distinguishing it from the main `iam_role.this`
- EventBridge pattern matches specific S3 object-created events using the provider's supported `detail.event-name` field
- Input to target uses `var.bucket_name` and `var.object_key` from the module's variables

## Assumptions

- The SSM Automation runbook (`aws_ssm_document.this`) is available as a reference in the module
- EventBridge event patterns support filtering by `detail.event-name` for S3 events (confirmed via AWS provider v6.61.0)
- The runbook is designed to receive `bucketName` and `objectKey` as automation inputs (already defined in `automation.tf`)
