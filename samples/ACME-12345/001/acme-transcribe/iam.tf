# IAM role for SSM Automation execution
resource "aws_iam_role" "this" {
  name_prefix = "test-upload-automation-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ssm.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Policy for SSM Automation role to start transcription jobs
data "aws_iam_policy_document" "transcribe" {
  statement {
    effect    = "Allow"
    actions   = ["transcribe:StartTranscriptionJob"]
    resources = ["*"]
  }
}

# Policy for SSM Automation role to get transcription job status
data "aws_iam_policy_document" "transcribe_get" {
  statement {
    effect    = "Allow"
    actions   = ["transcribe:GetTranscriptionJob", "transcribe:GetCaptions"]
    resources = ["*"]
  }
}

# Policy for SSM Automation role to read objects from S3
data "aws_iam_policy_document" "s3_read" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]
  }
}

# Policy for SSM Automation role to write objects to S3
data "aws_iam_policy_document" "s3_write" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]
  }
}

resource "aws_iam_role_policy" "transcribe" {
  name = "test-upload-transcribe"
  role = aws_iam_role.this.id

  policy = data.aws_iam_policy_document.transcribe.json
}

resource "aws_iam_role_policy" "transcribe_get" {
  name = "test-upload-transcribe-get"
  role = aws_iam_role.this.id

  policy = data.aws_iam_policy_document.transcribe_get.json
}

resource "aws_iam_role_policy" "s3_read" {
  name = "test-upload-s3-read"
  role = aws_iam_role.this.id

  policy = data.aws_iam_policy_document.s3_read.json
}

resource "aws_iam_role_policy" "s3_write" {
  name = "test-upload-s3-write"
  role = aws_iam_role.this.id

  policy = data.aws_iam_policy_document.s3_write.json
}
