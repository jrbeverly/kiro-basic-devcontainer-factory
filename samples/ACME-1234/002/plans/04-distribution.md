---
title: Create the distribution with viewer mTLS bound to the trust store
---

Create one distribution in front of the bucket, with viewer mTLS in required mode
bound to the trust store. Serve HTTPS only and do not offer HTTP/3; confirm both
against the provider schema rather than assuming the defaults. Grant the bucket
policy to CloudFront from the distribution's own ARN. Expose the distribution
domain name as an output.

If viewer mTLS turns out to need an alias with an ACM certificate instead of the
default CloudFront domain, record that in your notes before adding either.

Files: `cloudfront.tf`, `s3.tf`, `outputs.tf`.
