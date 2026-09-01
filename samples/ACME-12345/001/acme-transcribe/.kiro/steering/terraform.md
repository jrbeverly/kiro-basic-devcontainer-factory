# Terraform conventions

These conventions hold for every change in this repository. Where a work item
conflicts with them, they win.

## Layout

`versions.tf` holds the `terraform` block. `variables.tf` holds every variable.
`outputs.tf` holds every output. Nothing declares a variable or an output
anywhere else.

Everything else is grouped by subject, one file per subject: `tls.tf`, `s3.tf`,
`cloudfront.tf`, `iam.tf`. `main.tf` is not a dumping ground; a resource that has
a subject belongs in that subject's file.

The root module configures no providers. `examples/default` is the deployable
configuration: it configures the providers, calls the root module as
`module "this"`, and re-exports whatever a check needs.

## Naming

One resource of a type is named `this`. Use a descriptive label only when the
same type appears more than once, and then name it for what tells the two apart.

Never name a resource, local, or AWS object after an issue, ticket, epic, or
branch.

When a resource takes a `*_prefix` argument, use it and let AWS finish the name:
`bucket_prefix` on `aws_s3_bucket`, `name_prefix` on `aws_iam_role`,
`aws_iam_policy`, and `aws_security_group`. Do not assemble a name out of a
local.

## Policies

IAM and bucket policies come from `data "aws_iam_policy_document"`. Do not build
a policy with `jsonencode`.

## Durations

A duration is a local named `t<n><unit>`, all lowercase, referenced wherever the
number would otherwise be written:

    locals {
      t10y = 10 * 365 * 24
      t90d = 90 * 24
    }

    validity_period_hours = local.t10y

The unit is `y` years, `d` days, `h` hours, `m` minutes, `s` seconds. Never write
a bare duration at the argument, and never explain one in a comment.

## Comments

Write a comment only for something the code cannot state on its own: a provider
behaviour that forces an unobvious argument, or a constraint found in the schema.

Do not comment to restate a resource, to name a story or work item, or to narrate
what was added.

## Checks

A check lives in `examples/default` and reads every value it needs from
`terraform output`. It takes no arguments and validates no inputs.

A helper that is not a check lives in `scripts/` and follows the same rules,
reading what it needs with `terraform -chdir=examples/default output`.

Let the tool report. `curl --fail` and its exit status are the assertion. Do not
wrap commands in step banners, pass and fail echoes, or a closing summary.
