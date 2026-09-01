# EventBridge rule to trigger runbook on object-created events
resource "aws_cloudwatch_event_rule" "this" {
  name        = "test-upload-automation"
  description = "Trigger automation runbook on S3 object-created events"

  event_pattern = jsonencode({
    source = ["aws.s3"]
    detail = {
      event-name = [
        "PutObject",
        "PostObject",
        "CopyObject",
        "CompleteMultipartUpload"
      ]
    }
  })
}

# IAM role for EventBridge to invoke SSM Automation
resource "aws_iam_role" "event" {
  name_prefix = "test-upload-event-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Policy for EventBridge role to start SSM Automation execution
data "aws_iam_policy_document" "event" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:StartAutomationExecution"]
    resources = [aws_ssm_document.this.arn]
  }
}

resource "aws_iam_role_policy" "event" {
  name = "test-upload-event"
  role = aws_iam_role.event.id

  policy = data.aws_iam_policy_document.event.json
}

# EventBridge target pointing to SSM Automation runbook
resource "aws_cloudwatch_event_target" "this" {
  rule = aws_cloudwatch_event_rule.this.name
  arn  = aws_ssm_document.this.arn

  role_arn = aws_iam_role.event.arn

  input = jsonencode({
    bucketName = var.bucket_name
    objectKey  = var.object_key
  })
}
