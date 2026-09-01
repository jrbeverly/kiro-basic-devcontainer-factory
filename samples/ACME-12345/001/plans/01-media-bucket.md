---
title: Create the bucket and deliver its object-created events to EventBridge
---

Create the S3 bucket that receives uploads, and turn on EventBridge notification
delivery so an object-created event reaches the event bus. Nothing consumes the
event yet; the outcome is that the event arrives.

The bucket holds test uploads. Do not add versioning, encryption, lifecycle rules,
or access logging: none of them bear on the flow being investigated.

Files: `s3.tf`.
