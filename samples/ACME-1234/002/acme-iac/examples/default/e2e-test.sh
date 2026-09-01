#!/usr/bin/env bash
set -euo pipefail

# Read values from terraform output
DOMAIN=$(terraform output -raw cloudfront_distribution_domain)
CERT=$(terraform output -raw client_certificate)
KEY=$(terraform output -raw client_private_key)

# Create temporary files for cert and key
CERT_FILE=$(mktemp)
KEY_FILE=$(mktemp)
trap 'rm -f "$CERT_FILE" "$KEY_FILE"' EXIT

echo "$CERT" > "$CERT_FILE"
echo "$KEY" > "$KEY_FILE"

# Request with client certificate (expect success)
curl --fail --silent --output /dev/null \
  --cert "$CERT_FILE" \
  --key "$KEY_FILE" \
  "https://$DOMAIN"

# Request without client certificate (expect TLS failure)
set +e
curl --fail --silent --output /dev/null "https://$DOMAIN" 2>/dev/null
RESULT=$?
set -e

# curl will exit with 35 (SSL/TLS handshake failure) if no client cert is provided
# and the server requires one
if [ "$RESULT" -eq 35 ]; then
  exit 0
else
  echo "Expected TLS failure (exit code 35), got $RESULT" >&2
  exit 1
fi
