output "cloudfront_distribution_domain" {
  description = "The domain name of the CloudFront distribution"
  value       = module.this.cloudfront_distribution_domain
}

output "client_certificate" {
  description = "The client certificate"
  value       = module.this.client_certificate
}

output "client_private_key" {
  description = "The client private key"
  value       = module.this.client_private_key
}
