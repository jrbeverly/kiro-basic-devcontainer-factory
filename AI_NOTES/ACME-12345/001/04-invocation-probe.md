# Notes

## Helper implementation

Created `scripts/upload-execution.sh` to check whether an S3 upload started an SSM Automation execution.

### Implementation decisions:

1. **Helper location**: Created in `scripts/` directory per conventions (helpers are not checks, they live in `scripts/`)

2. **Outputs added to `outputs.tf`**:
   - `automation_document_name`: Required for the helper to know which SSM document to query
   - `bucket_name`: Included for completeness (may be useful for other checks/helpers)

3. **Helper implementation**:
   - Reads `automation_document_name` from terraform output
   - Calls `aws ssm list-automation-executions` with filter for the document name
   - Uses the query `AutomationExecutionMetadataList[]` to return execution metadata
   - Follows convention: "Let the tool report" - the AWS CLI command and its exit status are the assertion

4. **Missing documentation**: The root module had no outputs defined initially. According to conventions, `outputs.tf` should hold every output. Added the necessary outputs to support the helper.

5. **Assumptions**:
   - The helper assumes AWS CLI is installed and configured with appropriate credentials
   - The helper assumes SSM Automation executions are stored in the same region as configured for the example
   - The helper returns execution metadata, which includes status, start time, and execution ID

6. **Validation**: The `make validate` command passes successfully after adding outputs and the helper script.
