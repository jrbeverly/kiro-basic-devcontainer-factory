---
title: Add the end-to-end check
---

Add the check that uploads the sample, waits for the flow, and asserts both
outputs appear beside the source object.

The check is never executed here, so wire it into `make validate` as a syntax
check only.

Files: `examples/default/`, `Makefile`.
