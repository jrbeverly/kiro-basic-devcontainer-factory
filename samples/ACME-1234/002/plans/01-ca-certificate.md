---
title: Generate the certificate authority and one client certificate
---

Generate a self-signed CA with the `tls` provider and one client certificate
signed by it. Expose the client certificate and the client private key as
outputs so the end-to-end check can reach them.

There is no AWS Private CA. The CA exists only in Terraform, and its certificate
is later the entire contents of the trust store bundle.

Files: `tls.tf`, `outputs.tf`.
