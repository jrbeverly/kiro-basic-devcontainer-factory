---
title: Create the source parameter holding the generated CIDR list
---

Create the SSM StringList parameter that holds the allowlist. The CIDRs are
generated from a count rather than read from a file, so the size of the list is a
variable and nothing has to be re-mocked to change it.

Every entry is CIDR notation; a single address is `/32` or `/31`, never bare.
Start at two or three entries.

Files: `ssm.tf`, `variables.tf`, `outputs.tf`.
