# Notes

## Missing Documentation / Assumptions Made

### TLS Provider Resources
- **tls_private_key**: Generates private keys (RSA, ECDSA, ED25519). For CA, used RSA with 4096 bits. For client, RSA with 2048 bits.
- **tls_self_signed_cert**: Creates self-signed certificates. Key attributes:
  - `is_ca_certificate = true` - marks certificate as CA (required for trust store)
  - `allowed_uses` - must include "cert_signing" and "crl_signing" for CA
  - `set_subject_key_id = true` - adds subject key identifier
  - `set_authority_key_id = true` - adds authority key identifier (same as subject for self-signed)
- **tls_cert_request**: Generates Certificate Signing Request (CSR) with subject and DNS names/IPs/URIs
- **tls_locally_signed_cert**: Signs CSR with CA certificate and key

### Durations
- Following convention: named locals `T<n><unit>` (e.g., `T10Y` = 10 years, `T1Y` = 1 year)
- Never write bare numbers for durations

### File Layout
- `tls.tf` - all TLS provider resources (CA and client certificates)
- `outputs.tf` - exports client certificate and private key

### Security Considerations
- Client private key marked as sensitive (will be redacted in logs)
- CA private key not exposed as output (kept within Terraform state only)

## Problems with Existing Code
- None found - empty `tls.tf` and `outputs.tf` provided as starting point

## Implementation Notes
1. CA certificate uses 10-year validity (T10Y)
2. Client certificate uses 1-year validity (T1Y)
3. CA key: RSA 4096-bit (standard for certificate authorities)
4. Client key: RSA 2048-bit (sufficient for client authentication)
5. CA allowed_uses: cert_signing, crl_signing (typical for CA)
6. Client allowed_uses: client_auth (for TLS client authentication)
7. Both CA and client certificates include subject key identifier
8. CA certificate includes authority key identifier (self-signed = same as subject)
