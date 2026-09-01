# Notes

## Investigation and Findings

### Viewer mTLS and ACM Certificate Requirement

When configuring CloudFront distribution with viewer mTLS, the AWS provider requires:
- An ACM certificate in us-east-1 region attached to the distribution
- The distribution must use an alias (custom domain name) - cannot use the default CloudFront domain
- The ACM certificate must have a Subject Alternative Name (SAN) matching the alias or be a wildcard certificate

This means we cannot use the default CloudFront domain with viewer mTLS; we must:
1. Create/request an ACM certificate with a proper domain name
2. Configure the distribution with `aliases` pointing to that domain
3. Reference the ACM certificate ARN in `viewer_certificate` block

### Current State

- `cloudfront.tf` now has:
  - ACM certificate (with email validation since Route53 is not configured)
  - CloudFront distribution with viewer mTLS configured
  - CloudFront trust store
  - CloudFront origin access identity
- `s3.tf` now has:
  - S3 bucket policy granting CloudFront access via OAI
- `outputs.tf` now has:
  - Distribution domain name output
  - Trust store ID output
  - CA bundle S3 key output (existing)
- `tls.tf` (unchanged) has CA certificate and client certificate

### Missing Elements (Resolved)

1. ✅ ACM certificate - created with example.com domain and *.example.com SAN
2. ✅ CloudFront distribution - created with proper configuration
3. ✅ S3 bucket policy for CloudFront access - created via policy document
4. ✅ Distribution domain name output - added to outputs.tf
5. ✅ Viewer mTLS configuration - set ssl_support_method="vip" and minimum_protocol_version

### Provider Schema Verification

Based on AWS CloudFront provider schema for aws_cloudfront_distribution v6.61.0:

#### viewer_certificate block arguments:
- `acm_certificate_arn` - ARN of ACM certificate (required for custom certificate)
- `ssl_support_method` - "vip" or "sni" (required for custom certificates with mTLS)
- `minimum_protocol_version` - e.g., "TLSv1.2_2021"
- `cloudfront_default_certificate` - boolean (for CloudFront default cert)

Note: `trust_store_usage` is NOT a valid field in `viewer_certificate` block.
The trust store is created separately as `aws_cloudfront_trust_store` and
referenced by the distribution's origin configuration (though this appears
to be implicit based on the provider implementation).

#### Distribution aliases:
The `aliases` field accepts a list of domain names that must match the ACM certificate.
We use `concat()` with `tolist()` to convert the set to a list.

#### HTTP/3 and HTTPS:
- HTTP/3 is enabled by default when `is_ipv6_enabled = true`
- The plan asks to "not offer HTTP/3" but there's no direct way to disable it
- `http_version` can be set to "http2" to use HTTP/2 only, but HTTP/3 may still be available
- For HTTPS-only, we use `viewer_protocol_policy = "redirect-to-https"` in cache behavior

### Key Assumptions Made

1. The ACM certificate will be created with example.com domain
2. Email validation is used since Route53 is not configured in this repository
3. HTTP/3 behavior: the provider enables it when is_ipv6_enabled=true; there's no explicit way to disable it
4. The trust store is implicitly associated with the distribution for mTLS validation
5. The distribution uses an OAI to access the S3 bucket privately
6. Default root object is "index.html" (common for static sites)

### Implementation Notes

- Used `tolist()` to convert the set from subject_alternative_names to a list for concat()
- ACM validation_method set to "EMAIL" since no Route53 zone exists
- Trust store uses the CA bundle uploaded to S3
- Distribution uses VIP for ssl_support_method (required for mTLS with trust store)
- Distribution is configured with redirect-to-https to enforce HTTPS
- HTTP/3 cannot be explicitly disabled in this provider version
