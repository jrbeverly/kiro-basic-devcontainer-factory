---
title: Have the stack receive the CIDR list as a template parameter
---

Declare the template parameter that takes the allowlist out of SSM, and pass the
source parameter's name in from Terraform when the stack is deployed. Nothing
consumes the values yet; the outcome is that the list reaches the stack.

Confirm against the resource specification whether a template can declare an
`AWS::SSM::Parameter::Value<List<String>>` parameter and what it resolves to,
rather than assuming it. Record whether it resolves once when the stack is
deployed or follows the parameter afterwards; that answer decides whether one
central parameter can drive many accounts.

Files: `cloudformation.tf`, `templates/ipset.yaml`.
