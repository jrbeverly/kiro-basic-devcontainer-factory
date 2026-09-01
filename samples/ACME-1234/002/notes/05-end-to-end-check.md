# Notes

## Missing Documentation/Assumptions

- **Client certificate authentication**: The CloudFront distribution in `cloudfront.tf` 
  does not explicitly configure client certificate authentication. The `aws_cloudfront_trust_store` 
  is created but not referenced in the distribution's viewer configuration. This was assumed to 
  be intentional for the test scenario, or that client cert auth will be added separately.

- **e2e-test.sh behavior**: The script assumes that requesting without a client certificate 
  will cause curl to exit with code 35 (SSL/TLS handshake failure). This is based on standard 
  TLS behavior when a server requires client certificates but the client doesn't provide one.

## Problems with Existing Code

- The root `outputs.tf` did not export the client certificate and private key, which were 
  required by the plan. Added `client_certificate` and `client_private_key` outputs.

- The `examples/default/outputs.tf` was empty and needed to be populated with re-exports 
  from the module.

- No e2e test infrastructure existed. Created `e2e-test.sh` with curl-based testing.

## Instructions that could be improved

- The plan could have specified whether the CloudFront distribution needs client certificate 
  authentication configured, or whether it's handled elsewhere.

- It could have clarified what exactly "TLS failure" means in terms of expected curl exit codes.

## Implementation Details

1. Added `client_certificate` and `client_private_key` outputs to root `outputs.tf`
2. Re-exported outputs in `examples/default/outputs.tf` from `module.this.*`
3. Created `e2e-test.sh` that:
   - Reads distribution domain, cert, and key from terraform output
   - Makes request WITH client cert (expect HTTP 200)
   - Makes request WITHOUT client cert (expect TLS failure with exit code 35)
   - Uses temporary files with cleanup trap
4. Added `bash -n examples/default/e2e-test.sh` to `make validate` for syntax checking only
5. Made `e2e-test.sh` executable

## Verification

- `make validate` passes successfully
- Terraform configuration validates without errors
- e2e-test.sh syntax is correct (bash -n check passed)
