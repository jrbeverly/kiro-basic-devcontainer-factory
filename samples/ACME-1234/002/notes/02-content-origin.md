## S3 bucket for site content

Created `s3.tf` with:
- `aws_s3_bucket.this` with `bucket_prefix = "site-"` (AWS convention: use prefix when available)
- `aws_s3_bucket_acl.this` with `acl = "private"` to ensure bucket ACL blocks public access
- `aws_s3_bucket_public_access_block.this` to block all public access at the block level

Public access is blocked via:
- Bucket ACL set to "private"
- `block_public_acls = true` - blocks new public ACLs and uploading public objects
- `block_public_policy = true` - blocks new public bucket policies
- `ignore_public_acls = true` - ignores existing public ACLs
- `restrict_public_buckets = true` - restricts access to buckets with public policies to only approved resources

Per conventions:
- Resource named `this` (only one bucket)
- Used `bucket_prefix` instead of manual name assembly
- No variables introduced (policy will be added with CloudFront distribution)
- No bucket policy here (per plan: "the policy that grants that access is added with the distribution")

No bucket policy was added because:
1. The plan states the policy is added with the distribution
2. Conventions state policies come from `data "aws_iam_policy_document"` but that's for when the policy needs to be defined in Terraform - here it will come from the distribution resource
3. We don't have the CloudFront ARN yet, so we can't reference it
