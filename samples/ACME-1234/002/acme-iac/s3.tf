resource "aws_s3_bucket" "this" {
  bucket_prefix = "site-"

  tags = {
    Name = "Site content bucket"
  }
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "ca_bundle" {
  bucket  = aws_s3_bucket.this.id
  key     = "ca-bundle.pem"
  content = tls_self_signed_cert.ca.cert_pem

  content_type = "application/x-pem-file"
}

data "aws_iam_policy_document" "cloudfront_read" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.this.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.this.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id

  policy = data.aws_iam_policy_document.cloudfront_read.json
}
