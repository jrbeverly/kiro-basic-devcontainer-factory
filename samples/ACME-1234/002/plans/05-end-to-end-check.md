---
title: Deploy the example and add the end-to-end check
---

Make `examples/default` re-export the distribution domain and the client key pair
from the module. Beside it, add the check that requests the object with the client
certificate and again without it, expecting a success and a TLS failure. It reads
every value it uses from `terraform output` in its own directory.

The check is never executed here, so wire it into `make validate` as a syntax
check only.

Files: `examples/default/outputs.tf`, `examples/default/e2e-test.sh`, `Makefile`.
