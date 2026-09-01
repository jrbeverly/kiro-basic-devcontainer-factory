# Implementation Notes

## Findings

### AWS Transcribe Job Naming
- Job names can contain: alphanumeric characters, hyphens, underscores
- Maximum 200 characters
- Current implementation uses `{{input:objectKey}}-transcription` which would be invalid for files like `talk.mp4`
- **Solution**: Use `replace("{{input:objectKey}}", ".", "-")` to sanitize

### Output Location
- If `OutputBucketName` not specified, results go to AWS Transcribe-managed bucket
- To have results in the same bucket as input, must specify `OutputBucketName`
- **Decision**: Added `OutputBucketName = "{{input:bucketName}}"` to output to input bucket
- Output file is written to: `output-bucket/transcribe/<job-name>.json`

### Captions/VTT
- Must request captions in `StartTranscriptionJob` using `Settings.Captions`
- Can specify `OutputFormat: "vtt"` to get VTT output
- **Decision**: Added `Settings.Captions.OutputFormat = "vtt"` to request captions
- **Challenge**: GetCaptions returns the captions content, but SSM Automation needs to handle it

### SSM Automation waitForAwsResource
- **Confirmed format**:
```json
{
  "Service": "transcribe",
  "Api": "GetTranscriptionJob",
  "ResourceName": "TranscriptionJob",
  "SearchExpression": "$.TranscriptionJob.TranscriptionJobStatus",
  "ComparisonOperator": "equals",
  "TargetValue": "COMPLETED"
}
```
- Polls until the condition is met or timeout (default 60 seconds)

### IAM Permissions Added
- `transcribe:GetTranscriptionJob` - to check job status
- `transcribe:GetCaptions` - to retrieve VTT content
- `s3:PutObject` - to save output files
- `s3:GetObject` - already existed for reading source files
- `s3:CopyObject` - for copying JSON output

### Transcribe Output Handling
- `GetTranscriptionJob` returns `Transcript.TranscriptFileUri` - the JSON output location
- `GetCaptions` returns `CaptionsFile` - the VTT content as a string
- **Solution**: Use `s3:PutObject` with the string content as the Body
- **Note**: The `CaptionsFile` field name is correct based on AWS Transcribe API documentation

## Implementation Summary

### automation.tf Changes
1. **startTranscription**: 
   - Added sanitization with `replace()` to convert dots to hyphens in job name
   - Added `OutputBucketName` to write to input bucket
   - Added `Settings.Captions.OutputFormat = "vtt"` to request captions
   
2. **waitForTranscription**: 
   - New step using `aws:waitForAwsResource` to wait for job completion
   - Polls `GetTranscriptionJob` until status is `COMPLETED`
   
3. **getTranscriptionResults**: 
   - New step to retrieve job details after completion
   - Captures `Transcript.TranscriptFileUri` for the JSON location
   
4. **copyJsonOutput**: 
   - Copy JSON from Transcribe-managed location to `source-key.json` in input bucket
   - Uses S3 `CopyObject` API
   
5. **copyVttOutput**: 
   - Get VTT content using `GetCaptions` API
   - Requires job name and language code
   
6. **saveVttToFile**: 
   - Save VTT content to `source-key.vtt` using S3 `PutObject`
   - Uses the `CaptionsFile` field from the previous step
   
7. **skipTranscription**: 
   - No changes (kept for non-mp4 files)

### iam.tf Changes
1. Added `transcribe:GetTranscriptionJob` and `transcribe:GetCaptions` permissions
2. Added `s3:PutObject` permission for writing output files

## Challenges Encountered

### GetCaptions API Behavior
The `GetCaptions` API returns the captions content as a string in the `CaptionsFile` field.
In SSM Automation, this needs to be captured and used in a subsequent step via `PutObject`.

### Captions Language Code
The `GetCaptions` API requires `LanguageCode` parameter. Assumed `en-US` (same as transcription).
This matches the `LanguageCode` parameter used in `StartTranscriptionJob`.

### Wait Timeout
`aws:waitForAwsResource` has a default timeout of 60 seconds. Transcription jobs may take longer.
The timeout can be configured using the `Retry` parameter if needed, but the default should work
for most transcription jobs.

### S3 CopySource Format
The `CopySource` parameter for S3 `CopyObject` must be in the format: `source-bucket/source-key`
The `TranscriptFileUri` from Transcribe is a full S3 URI (e.g., `s3://bucket/key.json`)
This needs to be converted to the S3 copy format by extracting the bucket and key.

## Assumptions Made

1. **Transcribe job name sanitization**: Using `replace()` to convert dots to hyphens
2. **VTT content handling**: GetCaptions returns string that can be used directly as Body in PutObject
3. **Output file locations**: Results written to same bucket as input with .json and .vtt suffixes
4. **Language code**: Using `en-US` for all operations; may need to be configurable
5. **Wait timeout**: Default 60 seconds sufficient; may need adjustment for longer jobs
6. **CaptionsFile field name**: Based on AWS Transcribe API documentation for GetCaptions response

## Files Modified

- `automation.tf`: Added wait logic, job status checking, and output file handling
- `iam.tf`: Added permissions for transcription job polling and file writing

## Transcribe API Behavior Summary

### StartTranscriptionJob
- Starts an async transcription job
- If OutputBucketName is specified, writes to that bucket
- Output path: `output-bucket/transcribe/<job-name>.json`
- If captions requested via Settings.Captions, generates captions file

### GetTranscriptionJob
- Returns job status and metadata
- Key fields:
  - `TranscriptionJobStatus`: PENDING, IN_PROGRESS, COMPLETED, FAILED
  - `Transcript.TranscriptFileUri`: S3 URI of JSON output
  - `Transcript.CaptionsFileUri` (if captions requested): S3 URI of captions

### GetCaptions
- Returns captions content for a completed transcription job
- Requires: TranscriptionJobName, LanguageCode
- Returns: CaptionsFile (the captions content as a string)

## Key Implementation Decisions

1. **Wait for COMPLETED status**: Use `aws:waitForAwsResource` to wait for job completion
   instead of polling with a loop. This is cleaner and uses AWS's built-in waiting mechanism.

2. **Separate step for GetTranscriptionJob**: Need to retrieve the TranscriptFileUri
   after the job completes to know where the JSON output is located.

3. **Copy JSON output**: Use S3 CopyObject to copy from Transcribe's location to the
   source-key.json location. The TranscriptFileUri is a full S3 URI, so it needs to
   be parsed to extract bucket and key for the CopySource parameter.

4. **Retrieve VTT separately**: GetCaptions API returns the captions content directly
   as a string, which can be used in the Body of a PutObject call.

5. **Same bucket for all outputs**: All output files (.json and .vtt) are written to
   the same bucket as the input file, making it easy for consumers to find results.

## Additional Notes

The implementation follows the conventions from .kiro/steering/terraform.md:
- `automation.tf` contains the SSM document resource
- `iam.tf` contains IAM resources and policies
- Policies are built using `data "aws_iam_policy_document"` (not jsonencode)
- Uses `name_prefix` for resources
- No variables declared in these files (variables are in variables.tf)
