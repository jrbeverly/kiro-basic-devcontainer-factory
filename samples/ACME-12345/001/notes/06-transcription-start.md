# Notes

## Changes Made

### automation.tf
- Added SSM Automation step to start a transcription job for MP4 files only
- Used `aws:branch` action to check if object key ends with `.mp4` or `.MP4`
- For MP4 files: calls `transcribe:StartTranscriptionJob` via `aws:executeAwsApi`
- For non-MP4 files: skips with a zero-duration sleep step
- Transcription job name is derived from the object key
- Language code set to `en-US`
- Media format set to `mp4`

### iam.tf
- Added `aws_iam_role_policy` for Transcribe permissions (`transcribe:StartTranscriptionJob`)
- Added `aws_iam_role_policy` for S3 read permissions (`s3:GetObject`)
- Both policies attached to the SSM Automation role

## Observations

1. **SSM Automation Input References**: In SSM documents, input parameters use `{{input:Name}}` syntax, not Terraform interpolation syntax `${var.name}`

2. **Conditional Execution**: SSM Automation doesn't have simple if/else constructs. Used `aws:branch` action with `StringEquals` pattern matching for file extension check

3. **Case Sensitivity**: Both lowercase `.mp4` and uppercase `.MP4` extensions are checked to handle different file naming conventions

4. **Transcribe API Requirements**: 
   - `StartTranscriptionJob` requires: `TranscriptionJobName`, `LanguageCode`, `Media` (with `MediaFileUri`), and `MediaFormat`
   - For MP4 files, `MediaFormat` is `mp4`
   - No custom vocabulary needed for basic transcription

5. **No Custom Vocabulary**: As requested, no custom vocabulary configuration was added. If Transcribe later requires one, a minimal vocabulary can be mocked.

6. **S3 Permission Scope**: S3 `GetObject` permission is scoped to the bucket's objects (`${aws_s3_bucket.this.arn}/*`) following least privilege principles

## Verification

- `make validate` passes successfully
- No Terraform apply or AWS API calls made
