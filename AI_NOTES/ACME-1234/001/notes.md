# ACME-1234

## 2026-08-25

### Work item ACME-1234-01

**Observation:** The Dev Container image (`mcr.microsoft.com/devcontainers/base:ubuntu`) does not include Terraform, but the `validate` Makefile expects it to be available on PATH. The validation failed with `terraform: No such file or directory`.

**Resolution:** Added the `terraform` feature to `.devcontainer/devcontainer.json` to ensure terraform is installed when the container starts.

**Observation:** The TLS provider v4.x has different resource argument names and structure compared to v3.x:
- `rsa_private_key_pem` → `private_key_pem`
- `tls_self_signed_cert` v4.x cannot sign certificates with a CA - need to use `tls_locally_signed_cert` for CA-signed certificates
- `tls_locally_signed_cert` requires `cert_request_pem`, `ca_cert_pem`, and `ca_private_key_pem` arguments

**Observation:** The `tls_private_key` resource v4.x outputs both `private_key_pem` and `private_key_pem_pkcs8`. The `private_key_pem` output is PKCS#1 format, which is appropriate for the `tls` provider resources.

**Assumption:** The `client_certificate_pem` and `client_private_key_pem` outputs should be marked as `sensitive = true` since they contain private key material.

**Files modified:**
- `.devcontainer/devcontainer.json` - Added terraform feature
- `main.tf` - Added TLS provider, CA certificate, client certificate request, and CA-signed client certificate resources with outputs
## ACME-1234-01 — Generate CA and client certificates with TLS provider

# Notes for ACME-1234-01

## Certificate Authority Story

### Problem: TLS Provider v4.x API Mismatch

The plan constraint states:
> Use the `tls_cert_request` and `tls_self_signed_cert` resources for the client certificate.

However, the `tls` provider v4.x (version ~> 4.0, as specified in `versions.tf`) has a different API than v3.x:

- **In v4.x**, `tls_self_signed_cert` only supports creating self-signed certificates. It does NOT support:
  - `cert_request_pem`
  - `ca_private_key_pem`
  - `ca_cert_pem`
  - CA signing functionality

- To sign a certificate with a CA in v4.x, you must use `tls_locally_signed_cert`, which:
  - Requires `cert_request_pem`, `ca_private_key_pem`, and `ca_cert_pem`
  - Does NOT have a `subject` block (subject comes from the CSR)
  - Does NOT have a `private_key_pem` parameter (uses CSR's public key)
  - Has `set_subject_key_id` but NOT `set_authority_key_id`

### Solution Implemented

Due to the API difference, I used `tls_locally_signed_cert` for the client certificate instead of `tls_self_signed_cert`:

```hcl
resource "tls_locally_signed_cert" "client" {
  cert_request_pem      = tls_cert_request.client.cert_request_pem
  ca_private_key_pem    = tls_private_key.ca.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
  validity_period_hours = 87600
  
  set_subject_key_id = true
  is_ca_certificate = false
  allowed_uses = [...]
}
```

### Key Differences Between v3.x and v4.x TLS Provider

| Resource | v3.x | v4.x |
|----------|------|------|
| `tls_self_signed_cert` | Supports `cert_request_pem`, `ca_private_key_pem`, `ca_cert_pem` | Does NOT support CA signing |
| `tls_locally_signed_cert` | May not exist or different name | Exists with CA signing functionality |

### Validation

The solution passes all validation commands:
- `terraform fmt -check -recursive` ✓
- `terraform init -backend=false -input=false` ✓
- `terraform validate` ✓

### Outputs

The configuration exposes:
- `client_certificate_pem` (sensitive) - The client certificate signed by the CA
- `client_private_key_pem` (sensitive) - The client's private key

## ACME-1234-02 — Create S3 bucket for static site content

# Notes for ACME-1234-02: Create S3 bucket for static site content

## Implementation Summary

Created an S3 bucket for static site content with CloudFront-only access via bucket policy using `aws:SourceArn` condition.

## Files Modified

- **main.tf**: Added S3 bucket resource and public access block configuration
- **variables.tf**: Created to define `cloudfront_distribution_arn` variable

## Key Findings

### AWS Provider v6.x Changes

- `block_public_policy`, `block_public_acls`, `ignore_public_acls`, and `restrict_public_buckets` are NOT nested under `public_access_block` block in `aws_s3_bucket` resource
- Instead, these settings must use a separate resource: `aws_s3_bucket_public_access_block`
- This differs from earlier AWS provider versions where these were nested attributes

### Bucket Policy Approach

Used `aws:SourceArn` condition instead of OAI (Origin Access Identity):
- Policy allows access only when the request's source ARN matches the CloudFront distribution ARN
- No need to create or manage OAI resource
- Simpler configuration with single bucket policy resource

## Assumptions Made

1. CloudFront distribution ARN is provided via variable `var.cloudfront_distribution_arn` with a default placeholder value
2. The bucket policy uses `Principal = "*"` with condition to restrict access
3. Validation passes with `terraform fmt`, `terraform init -backend=false`, and `terraform validate`

## Remaining Work

- The CloudFront distribution ARN variable currently has a placeholder value that will need to be updated when the CloudFront distribution is created

## ACME-1234-03 — Publish CA bundle to S3 and create CloudFront trust store

# ACME-1234-03: Publish CA bundle to S3 and create CloudFront trust store

## Learning and Assumptions

### Provider Schema Investigation
- **Issue**: The plan description mentioned using a `certificate` block with `source`, `min_protocol_version`, and `client_cert_url` configuration
- **Investigation**: Examined AWS provider v6.61.0 schema using `terraform providers schema -json`
- **Finding**: The current AWS provider v6.x uses `ca_certificates_bundle_source` with nested `ca_certificates_bundle_s3_location` block, NOT a `certificate` block
- **Resolution**: Followed the actual provider schema instead of the plan description's generic template
- **Note**: The plan description's `certificate` block and top-level `min_protocol_version`/`client_cert_url` attributes do not exist in AWS provider v6.61.0

### CloudFront Trust Store Resource Attributes
- **Current schema only supports**:
  - Top-level attributes: `name`, `arn`, `etag`, `id`, `number_of_ca_certificates`, `tags`, `tags_all`
  - Block: `ca_certificates_bundle_source` → `ca_certificates_bundle_s3_location`
    - Required: `bucket`, `key`, `region`
    - Optional: `version`
  - Block: `timeouts` (create, delete, update)
- **No support for**: `min_protocol_version` or `client_cert_url` at any level in this provider version

### S3 Object Implementation
- Used `aws_s3_object` to upload the CA certificate (`tls_self_signed_cert.ca.cert_pem`) to the S3 bucket
- Set `content_type = "application/x-pem-file"` for proper MIME type
- Used a directory-style key path: `ca-certificates/${local.name}-ca.pem`

### Terraform Validation
- Successfully passed `terraform fmt -check`, `terraform init -backend=false`, and `terraform validate`
- No warnings after removing unnecessary `etag` from `lifecycle.ignore_changes`

## Files Modified
- `main.tf`: Added Story 3 implementation with S3 object upload and CloudFront trust store

## Key Code Patterns
- CA certificate from Story 1 is referenced via `tls_self_signed_cert.ca.cert_pem`
- CloudFront trust store references the S3 object via `aws_s3_object.ca_certificate_bundle.key`
- All resources in us-east-1 (no explicit region required for S3 in us-east-1)

## ACME-1234-04 — Create CloudFront distribution with viewer mTLS

# Implementation Notes for ACME-1234

## Story 4: Distribution

### Assumptions Made

1. **HTTP/3 Disabled**: Set `http_version = "http2"` to disable HTTP/3. According to AWS documentation, this setting forces the distribution to use HTTP/2 only.

2. **compress Setting**: Set `compress = true` for static site delivery. Compression is beneficial for text-based assets like HTML, CSS, JS.

3. **Viewer mTLS Binding**: The CloudFront distribution uses `viewer_mtls_config` block (at distribution level, not in `viewer_certificate`) to configure viewer mTLS. The `trust_store_config` references the trust store ID from `aws_cloudfront_trust_store.main`.

4. **Origin Access**: The S3 bucket uses a bucket policy approach (not OAI/OAC), so the `origin` block uses `s3_origin_config` with `origin_access_identity` left empty (which is the default when not using OAI).

5. **Price Class**: Set to `PriceClass_100` for cost optimization (US, Canada, and Europe only).

6. **Certificate Source**: Using `cloudfront_default_certificate` as the viewer certificate since this is a basic setup without custom domain aliases.

7. **SSL Support Method**: Set `ssl_support_method = "vip"` for viewer mTLS support. This enables the distribution to use the trust store for client certificate validation.

### Findings

- The existing `aws_s3_bucket_policy.static_site` uses `var.cloudfront_distribution_arn` in the condition, which will need to be provided when deploying.
- The trust store `aws_cloudfront_trust_store.main` exists and is referenced by its `id` (not ARN) in the `trust_store_config.trust_store_id`.
- For viewer mTLS in AWS provider v6, the configuration is at the distribution level using `viewer_mtls_config` block with `mode = "verify"` and `trust_store_config` containing the trust store ID.
- The correct structure is NOT `cloudfront_trust_store_ids` in `viewer_certificate` (that was my initial incorrect assumption based on incomplete documentation).

### Correct Structure

```hcl
viewer_certificate {
  cloudfront_default_certificate = true
  ssl_support_method             = "vip"
}

viewer_mtls_config {
  mode = "verify"

  trust_store_config {
    trust_store_id = aws_cloudfront_trust_store.main.id
  }
}
```

### Issues Found

- The spec mentioned `cloudfront_trust_store_ids` in `viewer_certificate`, which is not a valid attribute in AWS provider v6.
- The correct attribute is `viewer_mtls_config` at the distribution level with `trust_store_config.trust_store_id`.

## ACME-1234-05 — Write end-to-end validation script

# Notes for ACME-1234

## Implementation Summary

### Story 5: End-to-end validation script (`e2e-test.sh`)

Created an end-to-end validation script that tests CloudFront mTLS configuration.

#### Assumptions Made

1. **curl behavior**: When a client certificate is required and not provided, curl will fail with a TLS handshake error (non-zero exit code). The script checks for this non-zero exit code as the expected failure mode.

2. **Successful response**: The script expects HTTP 200 for requests with a valid client certificate. The CloudFront distribution should be configured to return content successfully when mTLS authentication succeeds.

3. **File permissions**: The script assumes the client certificate and private key files are readable by the user running the script.

#### Script Features

- Accepts `--url`, `--cert`, and `--key` command-line arguments
- Validates all required arguments are provided and files exist
- Step 1: Makes request WITH client certificate, expects HTTP 200
- Step 2: Makes request WITHOUT client certificate, expects TLS failure (non-zero curl exit)
- Clear pass/fail output for each step
- Fails the entire script if any step fails
- Uses `set -euo pipefail` for strict error handling

#### Validation

Script syntax validated with `bash -n` - no syntax errors.

#### Usage

```bash
./e2e-test.sh --url https://d12345.cloudfront.net --cert client-cert.pem --key client-key.pem
```

