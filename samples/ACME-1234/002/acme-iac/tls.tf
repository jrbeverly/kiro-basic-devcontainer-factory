locals {
  T10Y = 10 * 365 * 24
  T1Y  = 1 * 365 * 24
}

resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem       = tls_private_key.ca.private_key_pem
  validity_period_hours = local.T10Y

  set_subject_key_id   = true
  set_authority_key_id = true

  is_ca_certificate = true

  allowed_uses = [
    "cert_signing",
    "crl_signing",
  ]

  subject {
    common_name = "Example CA"
  }
}

resource "tls_private_key" "client" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "client" {
  private_key_pem = tls_private_key.client.private_key_pem

  subject {
    common_name = "Example Client"
  }
}

resource "tls_locally_signed_cert" "client" {
  ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
  ca_private_key_pem    = tls_private_key.ca.private_key_pem
  cert_request_pem      = tls_cert_request.client.cert_request_pem
  validity_period_hours = local.T1Y

  allowed_uses = [
    "client_auth",
  ]
}
