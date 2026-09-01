output "automation_document_name" {
  description = "The name of the SSM Automation document"
  value       = aws_ssm_document.this.name
}

output "bucket_name" {
  description = "The name of the S3 bucket for uploads"
  value       = aws_s3_bucket.this.id
}