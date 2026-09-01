---
title: Deploy a CloudFormation stack from Terraform
---

Add the CloudFormation template and the Terraform resource that deploys it. The
template declares one SSM parameter with a fixed value and nothing else; what is
being proved is that the stack deploys and stays managed.

The template declares its own resources. It is a file Terraform hands to
CloudFormation, not something Terraform generates or interpolates into.

Files: `cloudformation.tf`, `templates/ipset.yaml`.
