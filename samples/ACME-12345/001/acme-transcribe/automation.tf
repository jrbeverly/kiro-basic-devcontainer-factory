# SSM Automation runbook for handling uploads
resource "aws_ssm_document" "this" {
  name          = "test-upload-automation"
  document_type = "Automation"

  content = jsonencode({
    schemaVersion = "0.3"
    description   = "Automation runbook for test upload processing"
    assumedRole   = aws_iam_role.this.arn
    inputs = {
      bucketName = {
        type = "String"
      }
      objectKey = {
        type = "String"
      }
    }
    steps = [
      # Read object metadata and tags
      {
        name   = "getObjectMetadata"
        action = "aws:executeAwsApi"
        inputs = {
          Service = "s3"
          Api     = "HeadObject"
          Bucket  = "{{input:bucketName}}"
          Key     = "{{input:objectKey}}"
        }
        outputs = [
          {
            name = "Metadata"
            type = "StringMap"
          },
          {
            name = "ContentType"
            type = "String"
          },
          {
            name = "ContentLength"
            type = "String"
          }
        ]
      },
      {
        name   = "getObjectTags"
        action = "aws:executeAwsApi"
        inputs = {
          Service = "s3"
          Api     = "GetObjectTagging"
          Bucket  = "{{input:bucketName}}"
          Key     = "{{input:objectKey}}"
        }
        outputs = [
          {
            name = "TagSet"
            type = "StringMap"
          }
        ]
      },
      # Process based on metadata (example: check content type)
      {
        name   = "checkContentType"
        action = "aws:branch"
        inputs = {
          Choice = [{
            Variable     = "{{steps.getObjectMetadata.ContentType}}"
            StringEquals = "video/mp4"
            NextStep     = "startTranscription"
          }]
          Default = "skipTranscription"
        }
      },
      {
        name   = "startTranscription"
        action = "aws:executeAwsApi"
        inputs = {
          Service              = "transcribe"
          Api                  = "StartTranscriptionJob"
          TranscriptionJobName = replace("{{input:objectKey}}", ".", "-")
          LanguageCode         = "en-US"
          Media = {
            MediaFileUri = "s3://{{input:bucketName}}/{{input:objectKey}}"
          }
          MediaFormat      = "mp4"
          OutputBucketName = "{{input:bucketName}}"
          Settings = {
            Captions = {
              OutputFormat = "vtt"
            }
          }
        }
      },
      {
        name   = "waitForTranscription"
        action = "aws:waitForAwsResource"
        inputs = {
          Service            = "transcribe"
          Api                = "GetTranscriptionJob"
          ResourceName       = "TranscriptionJob"
          SearchExpression   = "$.TranscriptionJob.TranscriptionJobStatus"
          ComparisonOperator = "equals"
          TargetValue        = "COMPLETED"
        }
      },
      {
        name   = "getTranscriptionResults"
        action = "aws:executeAwsApi"
        inputs = {
          Service              = "transcribe"
          Api                  = "GetTranscriptionJob"
          TranscriptionJobName = replace("{{input:objectKey}}", ".", "-")
        }
      },
      {
        name   = "copyJsonOutput"
        action = "aws:executeAwsApi"
        inputs = {
          Service    = "s3"
          Api        = "CopyObject"
          Bucket     = "{{input:bucketName}}"
          CopySource = "{{steps.getTranscriptionResults.TranscriptionJob.Transcript.TranscriptFileUri}}"
          Key        = "{{input:objectKey}}.json"
        }
      },
      {
        name   = "copyVttOutput"
        action = "aws:executeAwsApi"
        inputs = {
          Service              = "transcribe"
          Api                  = "GetCaptions"
          TranscriptionJobName = replace("{{input:objectKey}}", ".", "-")
          LanguageCode         = "en-US"
        }
      },
      {
        name   = "saveVttToFile"
        action = "aws:executeAwsApi"
        inputs = {
          Service = "s3"
          Api     = "PutObject"
          Bucket  = "{{input:bucketName}}"
          Key     = "{{input:objectKey}}.vtt"
          Body    = "{{steps.copyVttOutput.CaptionsFile}}"
        }
      },
      {
        name   = "skipTranscription"
        action = "aws:sleep"
        inputs = {
          Duration = "PT0S"
        }
      }
    ]
  })

  # Note: Reading S3 object metadata from within an Automation runbook is supported
  # using aws:executeAwsApi with HeadObject and GetObjectTagging APIs.
  #
  # This implementation demonstrates:
  # - getObjectMetadata: Reads object metadata using HeadObject
  #   Output: Metadata (StringMap), ContentType (String), ContentLength (String)
  # - getObjectTags: Reads object tags using GetObjectTagging
  #   Output: TagSet (StringMap)
  # - checkContentType: Conditional logic based on ContentType
  #
  # Limitations of SSM Automation metadata handling:
  # - Cannot iterate over metadata map keys or tag array dynamically
  # - Cannot determine count of metadata entries or tags without external scripting
  # - Can only reference specific keys if known at design time
  # - No built-in string functions like length() or string manipulation
  # - Complex processing requires aws:executeScript (Lambda) or aws:runCommand
  #
  # To reference metadata values:
  # - Entire map: {{steps.getObjectMetadata.Metadata}}
  # - Specific key: {{steps.getObjectMetadata.Metadata.myCustomKey}}
  # - Tags: {{steps.getObjectTags.TagSet}} or {{steps.getObjectTags.TagSet[0]}}
}
