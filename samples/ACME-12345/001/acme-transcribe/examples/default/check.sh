#!/usr/bin/env bash
set -euo pipefail

# End-to-end check: uploads sample, waits for the flow, and asserts outputs

cd /workspace/examples/default

# Read values from terraform
bucket_name=$(terraform output -raw bucket_name)
object_key="sample.mp4"
source_file="sample.mp4"

# Upload the sample file
echo "Uploading ${source_file} to s3://${bucket_name}/${object_key}..."
aws s3 cp "${source_file}" "s3://${bucket_name}/${object_key}"

# Wait for automation execution to start
echo "Waiting for automation execution to start..."
timeout=300
elapsed=0
while [ $elapsed -lt $timeout ]; do
  # Get the most recent automation execution
  execution_id=$(aws ssm list-automation-executions \
    --filter "DocumentName=${bucket_name}" \
    --query 'AutomationExecutionMetadataList[0].AutomationExecutionId' \
    --output text 2>/dev/null || echo "")
  
  if [ -n "$execution_id" ]; then
    echo "Found execution: ${execution_id}"
    break
  fi
  
  echo "  Waiting... (${elapsed}s)"
  sleep 10
  elapsed=$((elapsed + 10))
done

if [ -z "$execution_id" ]; then
  echo "ERROR: No automation execution found after ${timeout}s"
  exit 1
fi

# Wait for automation execution to complete
echo "Waiting for automation execution to complete..."
while true; do
  status=$(aws ssm describe-automation-execution \
    --automation-execution-id "${execution_id}" \
    --query 'AutomationExecution.AutomationExecutionStatus' \
    --output text)
  
  case "$status" in
    SUCCESS)
      echo "Automation execution completed successfully"
      break
      ;;
    FAILED|CANCELLED|TIMEOUT)
      echo "ERROR: Automation execution failed with status: ${status}"
      exit 1
      ;;
    *)
      echo "  Current status: ${status}"
      sleep 10
      ;;
  esac
done

# Assert both outputs exist beside the source object
echo "Checking for outputs..."
json_output="${object_key}.json"
vtt_output="${object_key}.vtt"

# Check JSON output
if aws s3 ls "s3://${bucket_name}/${json_output}" >/dev/null 2>&1; then
  echo "✓ Found ${json_output}"
else
  echo "ERROR: Missing ${json_output}"
  exit 1
fi

# Check VTT output
if aws s3 ls "s3://${bucket_name}/${vtt_output}" >/dev/null 2>&1; then
  echo "✓ Found ${vtt_output}"
else
  echo "ERROR: Missing ${vtt_output}"
  exit 1
fi

echo "✓ All outputs verified"
