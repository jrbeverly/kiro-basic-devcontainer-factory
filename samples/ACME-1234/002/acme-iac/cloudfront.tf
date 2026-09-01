resource "aws_acm_certificate" "this" {
  domain_name               = "example.com"
  validation_method         = "EMAIL"
  subject_alternative_names = ["*.example.com"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudfront_distribution" "this" {
  origin {
    domain_name = aws_s3_bucket.this.bucket_regional_domain_name
    origin_id   = "s3-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    }
  }

  aliases = concat([aws_acm_certificate.this.domain_name], tolist(aws_acm_certificate.this.subject_alternative_names))

  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_100"

  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-origin"

    forwarded_values {
      query_string = false
      headers      = []

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.this.arn
    ssl_support_method       = "vip"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "Site distribution"
  }
}

resource "aws_cloudfront_origin_access_identity" "this" {
  comment = "OAI for CloudFront distribution"
}

resource "aws_cloudfront_trust_store" "this" {
  name = "ca-trust-store"

  ca_certificates_bundle_source {
    ca_certificates_bundle_s3_location {
      bucket = aws_s3_object.ca_bundle.bucket
      key    = aws_s3_object.ca_bundle.key
      region = "us-east-1"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
