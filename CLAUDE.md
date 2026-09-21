# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

This is a standalone, publicly-distributed Terraform module (registry address `caylent/msp-guardduty-datadog/aws`) that routes Amazon GuardDuty findings to Datadog. It was migrated out of an internal Trek10/Caylent GitLab monorepo (`guard-duty`), where it originally lived alongside an unrelated legacy CloudFormation/SAM implementation of the same goal — that history isn't relevant here; this repo is now the sole source of truth for the Terraform path.

## Commands

- `terraform init -backend=false && terraform validate` — validate config without a backend (what CI runs); CI runs this against both the repo root and `modules/msp-guardduty-datadog-single-region/` (matrix job)
- `terraform fmt -check -recursive` — check formatting across root + submodule; drop `-check` to auto-fix
- `terraform-docs .` — regenerate the Requirements/Inputs/Outputs tables in `README.md` from the repo root's `variables.tf`/`outputs.tf` only (config in `.terraform-docs.yml`, not recursive — the submodule's variables are internal and intentionally excluded from the public-facing tables); must match `TERRAFORM_DOCS_VERSION` in `.github/workflows/pr-checks.yml` (currently `0.24.0`) or the generated output may not match what CI expects
- There is no test suite — `fmt`/`validate`/`terraform-docs` drift are the only automated checks, all run per-PR, not per-commit

## Architecture

As of `v2.0.0`, the repo root is a **multi-region wrapper**; the actual GuardDuty-to-Datadog wiring for one region lives in an internal-only submodule at `modules/msp-guardduty-datadog-single-region/`, called by the root, never published or addressed independently. Both live under the one registry address (`caylent/msp-guardduty-datadog/aws`) and release together on the same tag.

This split exists because of two Terraform constraints that can't be worked around:
- A module that declares its own `provider` block can never be targeted by `count`/`for_each`/`depends_on` from its caller — so a module wanting to support multiple regions per account can't just let the caller `for_each` over it while also owning its own provider.
- The `providers = {}` argument on a `module` block is static per block — it can't vary by `for_each` key, so there's no way to give N regions N different provider aliases through a single dynamic loop, from any wrapper, at any nesting depth.

The only way to give each region its own provider alias is N individually-written (but `count`-toggleable) module blocks — one hardcoded per real AWS region. That's what `providers.tf` (provider aliases) and `regions.tf` (module calls) at the repo root do; `locals.tf` maps each region string to the underscore-safe alias/block-label used by both, since HCL identifiers can't contain hyphens. `outputs.tf` re-exposes each submodule's outputs as a `merge()` over all ~34 possible region instances (`module` cannot be indexed dynamically by a computed key, so this can't be collapsed into a `for` expression).

`iam.tf` at the root creates a single shared IAM role (EventBridge's permission to invoke the Datadog API destination) using one fixed provider alias, since IAM is account-global rather than regional — sharing one role avoids the account-wide name collision that a same-named role per region would hit. Its policy scopes access via a wildcarded ARN pattern rather than an exact list of each enabled region's destination ARN, since that list would otherwise need to filter over `count`-toggled module instances that may or may not exist.

Inside the submodule (per-region resources):
1. `eventbridge.tf`: an `aws_cloudwatch_event_rule` matches `aws.guardduty` / `GuardDuty Finding` on that region's default event bus, targeting an `aws_cloudwatch_event_api_destination` (defined in `datadog.tf`). The target's `input_transformer` reshapes the event to `{"message": <detail>, "ddsource": "guardduty", "ddtags": "account_id:<account>,region:<region>"}` before it reaches Datadog — the `ddtags` field lets per-account/per-region Datadog monitors filter without parsing the message body. A `retry_policy` and `dead_letter_config` on the event target send a delivery that fails for `max_event_age_seconds`/`max_retry_attempts` to a per-region SQS dead-letter queue instead of AWS's default silent-discard-after-24h behavior — see `README.md`'s "Dead-letter queue" section for alarming on it. The submodule takes `eventbridge_role_arn` as an input rather than creating its own role, since the root owns the one shared role.
2. `datadog.tf`: `aws_cloudwatch_event_connection` holds the Datadog API key (`API_KEY` auth type); `aws_cloudwatch_event_api_destination` points at Datadog's Logs intake endpoint. The endpoint domain is looked up from `local.datadog_site_domains` rather than derived by string interpolation, because EU and the FedRAMP sites use distinct TLDs that don't follow the `<site>.datadoghq.com` pattern.
3. The submodule declares no `provider` block of its own — the root passes its per-region alias down explicitly via `providers = { aws = aws.<alias> }` on each call, making the submodule a pure provider consumer.

`required_providers` for `aws` is `>= 3.43.0` (not a narrower `~> 6.0`) in both the root and the submodule — that's the actual minimum needed by `aws_cloudwatch_event_connection`/`aws_cloudwatch_event_api_destination` (added in provider `v3.43.0`) and `retry_policy`/`dead_letter_config` (added in `v3.29.0`). Keeping this wide avoids forcing an unsatisfiable `required_providers` version conflict for callers whose broader Terraform config also uses the `aws` provider on an older line — that conflict is a whole-configuration constraint-intersection problem, not something scoped to just this module, so widening it here matters regardless of anything else in the config.

The `datadog_api_key` variable is `sensitive = true`, but `aws_cloudwatch_event_connection` has no write-only/ephemeral argument for `auth_parameters` — the key is unavoidably persisted in Terraform state regardless. Callers must supply it via `TF_VAR_datadog_api_key`, never a literal or checked-in `.tfvars`.

## Releasing

To release: merge to `main`, then `git tag vX.Y.Z && git push origin vX.Y.Z`. No build step — tags are the release artifact.

The registry requires a one-time manual publish (sign in to registry.terraform.io with GitHub, "Publish" this repo — needs at least one tag pushed first) before it starts tracking this repo at all. After that initial link exists, every subsequent tag push is picked up automatically via a webhook the publish step installs, usually within a minute. If a new tag doesn't show up on the registry after a few minutes, check Settings → Webhooks for the registry's webhook — it's known to occasionally stop firing and needs to be configured to trigger on tag/branch create events, not just plain pushes.

Only push real semver tags (`v1.2.3`). Don't introduce moving/floating tags like `latest`, `stable`, or a bare major version (`v1`) to mimic Docker/npm/GitHub-Actions conventions — the registry's versioning model is built entirely on immutable per-release tags, and consumers never reference a tag name directly. A caller pinning `version = "~> 1.0"` against the registry source has Terraform's own client resolve that constraint against the real tag list; the registry also computes its own "latest" for the docs site automatically. A moving tag would be invisible to consumers and would undermine the reproducibility the registry format exists to provide.

## CI (`.github/workflows/pr-checks.yml`)

Three jobs on every PR against `main`: `fmt`, `validate`, and a `terraform-docs` drift check. The docs job installs a pinned `terraform-docs` binary directly from GitHub releases rather than using the `terraform-docs/gh-actions` marketplace action, because that action's bundled `terraform-docs` version can lag behind and produce spurious diffs against a `README.md` generated locally with a newer version.

## Not yet added (deliberately deferred, not forgotten)

- `tflint` — catches things `terraform validate` doesn't (unused variables, deprecated syntax, provider-specific lint rules). Low cost to add; consider it once this module has more surface area or after the first real external contribution.
- `tfsec` or `checkov` — static security scanning. Worth adding given this module handles a Datadog API key and IAM roles/policies, but expect initial false positives that need triage/suppression — budget setup time rather than treating it as a drop-in addition.
- A `workflow_dispatch` release job (take a version input, create and push the tag from the Actions UI) — mainly useful once someone without local git access needs to cut a release, or release cadence picks up enough that manual `git tag && git push` becomes friction. Not needed for a single low-cadence module.

## Docs

`README.md`'s Requirements/Inputs/Outputs tables are auto-generated — don't hand-edit them between the `<!-- BEGIN_TF_DOCS -->`/`<!-- END_TF_DOCS -->` markers; run `terraform-docs .` after changing `variables.tf`/`outputs.tf` instead.
