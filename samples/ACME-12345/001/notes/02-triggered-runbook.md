# Notes

## SSM Automation Document

- Created `automation.tf` with `aws_ssm_document` resource
- Document type: "Automation"
- Content format: JSON-encoded object with schemaVersion "0.3"
- Required fields: `schemaVersion`, `description`, `assumedRole`, `steps`
- Inputs defined in content: `bucketName` and `objectKey` (both type "String")
- The runbook is valid but has no steps yet (empty `steps = []`)

## IAM Role

- Created `iam.tf` with `aws_iam_role` for SSM Automation
- Role name prefix: `test-upload-automation-`
- Assume role policy allows `ssm.amazonaws.com` service to assume the role
- The role ARN is referenced in the automation document's `assumedRole` field

## Variables

- Added `bucket_name` and `object_key` variables to `variables.tf`
- Both are required string inputs
- Example configuration in `examples/default/main.tf` provides sample values

## Learning

- `aws_ssm_document` content must be a JSON-encoded string
- SSM Automation documents require a valid IAM role that can be assumed by the SSM service
- The document schema version "0.3" supports the `inputs` field for defining parameters
- No AWS API calls are made during plan/validate; the document is just a configuration
