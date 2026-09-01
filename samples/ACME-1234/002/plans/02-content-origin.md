---
title: Create the bucket that holds the site content
---

Create the S3 bucket that holds the site's single object, with public access
blocked. The bucket is reachable only through CloudFront; the policy that grants
that access is added with the distribution, once its ARN exists, so do not
introduce a variable to stand in for it.

Files: `s3.tf`.
