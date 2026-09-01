output "ca_bundle_s3_key" {
  description = "The S3 key for the CA bundle"
  value       = aws_s3_object.ca_bundle.key
}

output "cloudfront_distribution_domain" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.domain_name
}

output "cloudfront_trust_store_id" {
  description = "The ID of the CloudFront trust store"
  value       = aws_cloudfront_trust_store.this.id
}

output "client_certificate" {
  description = "The client certificate"
  value       = tls_locally_signed_cert.client.cert_pem
}

output "client_private_key" {
  description = "The client private key"
  value       = tls_private_key.client.private_key_pem
}
