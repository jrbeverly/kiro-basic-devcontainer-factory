---
title: Add a second example at the two-to-three-hundred CIDR scale
---

Add a second example that deploys the same module with two to three hundred
entries, so the size can be exercised without disturbing the small one, and
validate it alongside the first.

A standard-tier SSM parameter holds four thousand characters and three hundred
CIDRs sit near that line. Record the size at which something breaks and what
breaks first.

Files: `examples/`, `Makefile`.
