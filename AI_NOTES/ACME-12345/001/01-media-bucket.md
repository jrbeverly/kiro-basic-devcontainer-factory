# Notes

## S3 Bucket and EventBridge Notification

### Learning

- AWS S3 bucket in Terraform AWS provider v6 uses `bucket_prefix` (not `prefix`) for auto-generated names
- EventBridge notification delivery is configured via `aws_s3_bucket_notification` resource with `eventbridge = true`
- No other notification targets (lambda_function, queue, topic) are needed for this task
- The plan mentioned "EventBridge notification delivery" - this maps to the `eventbridge` attribute on `aws_s3_bucket_notification`

### Assumptions

- The bucket is named with a prefix following conventions (`bucket_prefix = "test-upload-"`)
- Only object-created events need to be sent to EventBridge (the `eventbridge` attribute enables all events to be sent)
- No versioning, encryption, lifecycle rules, or access logging as specified in the plan

### Problems

- None encountered

### Conventions followed

- `s3.tf` file for S3-related resources
- `bucket_prefix` used for auto-naming
- Resource named `this` (only one bucket and one notification resource)
- No variables or outputs needed for this simple resource
