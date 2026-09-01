# Notes

## Investigation findings

- Repository structure: root module in /workspace, examples/default/ calls it
- The root module defines:
  - `aws_s3_bucket` with notification to EventBridge
  - `aws_ssm_document` automation runbook for transcription
  - `aws_cloudwatch_event_rule` and `aws_cloudwatch_event_target` to trigger automation
  - IAM roles and policies for SSM and EventBridge

- The automation runbook (automation.tf) processes uploads:
  1. Reads object metadata and tags
  2. Checks content type (video/mp4 triggers transcription)
  3. Starts transcription job
  4. Waits for completion
  5. Copies JSON output and VTT captions to S3

- The EventBridge rule (events.tf) triggers on: PutObject, PostObject, CopyObject, CompleteMultipartUpload

- Existing helper: scripts/upload-execution.sh shows automation executions

## Missing documentation / assumptions

- No documentation on the expected check behavior
- Assumed: check should be in examples/default/ as a bash script
- Assumed: check reads bucket_name and object_key from terraform output
- Assumed: check uploads sample.mp4 and waits for outputs
- Assumed: outputs are {object_key}.json and {object_key}.vtt

## Problems with existing code

- None identified

## Instructions that could be improved

- The plan could be more specific about the check's behavior
- The convention about where checks live isn't explicitly stated

## Work completed

Created /workspace/examples/default/check.sh:
- Uploads sample.mp4 to S3 bucket
- Waits for SSM Automation execution to start
- Waits for automation execution to complete
- Verifies both .json and .vtt outputs exist beside the source object

The check is never executed in this environment (no AWS credentials).

Updated Makefile validate target to include `bash -n examples/default/check.sh` as a syntax check.
