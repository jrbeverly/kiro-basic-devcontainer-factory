#!/usr/bin/env bash
set -euo pipefail

# Helper that shows whether an upload started an SSM Automation execution
# and what that execution did.

cd /workspace/examples/default

document_name=$(terraform output -raw automation_document_name)

# List automation executions for this document
aws ssm list-automation-executions \
  --filter "DocumentName=${document_name}" \
  --query 'AutomationExecutionMetadataList[]' \
  --output table

# Show step execution details for the most recent execution if any exist
aws ssm list-automation-executions \
  --filter "DocumentName=${document_name}" \
  --query 'AutomationExecutionMetadataList[0].AutomationExecutionId' \
  --output text 2>/dev/null | while read -r execution_id; do
  if [ -n "$execution_id" ]; then
    echo ""
    echo "Step Executions:"
    aws ssm describe-automation-execution \
      --automation-execution-id "${execution_id}" \
      --query 'AutomationExecution.StepExecutions[]' \
      --output table
  fi
done
