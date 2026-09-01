---
title: Add the end-to-end check
---

Add the check that proves the flow: the CIDRs Terraform put into the source
parameter are the addresses the IP set ends up holding, and the published
parameter names that IP set at the path a consumer would construct.

The check is never executed here, so wire it into `make validate` as a syntax
check only.

Files: `examples/default/`, `Makefile`.
