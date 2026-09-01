# S3 bucket for test uploads with EventBridge notification delivery
resource "aws_s3_bucket" "this" {
  bucket_prefix = "test-upload-"
}

resource "aws_s3_bucket_notification" "this" {
  bucket = aws_s3_bucket.this.id

  eventbridge = true
}
