---
title: Publish the CA bundle and create the CloudFront trust store
---

Put the CA certificate from work item 01 into the bucket as the PEM bundle, and
create the CloudFront trust store from that object. The bundle holds exactly that
one certificate, and the trust store does not follow the bundle after it is
created.

Files: `s3.tf`, `cloudfront.tf`.
