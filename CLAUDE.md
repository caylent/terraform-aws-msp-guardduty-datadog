# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

This is a standalone, publicly-distributed Terraform module (registry address `caylent/msp-guardduty-datadog/aws`) that routes Amazon GuardDuty findings to Datadog. It was migrated out of an internal Trek10/Caylent GitLab monorepo (`guard-duty`), where it originally lived alongside an unrelated legacy CloudFormation/SAM implementation of the same goal — that history isn't relevant here; this repo is now the sole source of truth for the Terraform path.

## Commands

- `terraform init -backend=false && terraform validate` — validate config without a backend (what CI runs)
- `terraform fmt -check -recursive` — check formatting; drop `-check` to auto-fix
- `terraform-docs .` — regenerate the Requirements/Inputs/Outputs tables in `README.md` from `variables.tf`/`outputs.tf` (config in `.terraform-docs.yml`); must match `TERRAFORM_DOCS_VERSION` in `.github/workflows/pr-checks.yml` (currently `0.24.0`) or the generated output may not match what CI expects
- There is no test suite — `fmt`/`validate`/`terraform-docs` drift are the only automated checks, all run per-PR, not per-commit

## Architecture

Three resources chain together to move a finding from GuardDuty to Datadog, with no SNS topic or Lambda in between (unlike the legacy CFT implementation this was migrated from):

1. `eventbridge.tf`: an `aws_cloudwatch_event_rule` matches `aws.guardduty` / `GuardDuty Finding` on the account's default event bus, targeting an `aws_cloudwatch_event_api_destination` (defined in `datadog.tf`). The target's `input_transformer` reshapes the event to `{"message": <detail>, "ddsource": "guardduty"}` before it reaches Datadog. A dedicated IAM role/policy lets EventBridge invoke that API destination.
2. `datadog.tf`: `aws_cloudwatch_event_connection` holds the Datadog API key (`API_KEY` auth type); `aws_cloudwatch_event_api_destination` points at Datadog's Logs intake endpoint. The endpoint domain is looked up from `local.datadog_site_domains` rather than derived by string interpolation, because EU and the FedRAMP sites use distinct TLDs that don't follow the `<site>.datadoghq.com` pattern.
3. `provider.tf`: the module declares its own `provider "aws"` scoped to `var.aws_region`, rather than expecting the caller to pass one in via provider aliasing. This is deliberate: GuardDuty findings and the default event bus are both regional, so a client covering multiple regions calls this module once per region (see the `for_each` pattern in `README.md`'s "Multi-region deployment" section) — the self-contained provider means they don't need to pre-declare AWS provider aliases in their own root config to do that.

The `datadog_api_key` variable is `sensitive = true`, but `aws_cloudwatch_event_connection` has no write-only/ephemeral argument for `auth_parameters` — the key is unavoidably persisted in Terraform state regardless. Callers must supply it via `TF_VAR_datadog_api_key`, never a literal or checked-in `.tfvars`.

## Releasing

No build/publish step — the Terraform Registry re-indexes this repo's tags automatically. To release: merge to `main`, then `git tag vX.Y.Z && git push origin vX.Y.Z`.

## CI (`.github/workflows/pr-checks.yml`)

Three jobs on every PR against `main`: `fmt`, `validate`, and a `terraform-docs` drift check. The docs job installs a pinned `terraform-docs` binary directly from GitHub releases rather than using the `terraform-docs/gh-actions` marketplace action, because that action's bundled `terraform-docs` version can lag behind and produce spurious diffs against a `README.md` generated locally with a newer version.

## Not yet added (deliberately deferred, not forgotten)

- `tflint` — catches things `terraform validate` doesn't (unused variables, deprecated syntax, provider-specific lint rules). Low cost to add; consider it once this module has more surface area or after the first real external contribution.
- `tfsec` or `checkov` — static security scanning. Worth adding given this module handles a Datadog API key and IAM roles/policies, but expect initial false positives that need triage/suppression — budget setup time rather than treating it as a drop-in addition.

## Docs

`README.md`'s Requirements/Inputs/Outputs tables are auto-generated — don't hand-edit them between the `<!-- BEGIN_TF_DOCS -->`/`<!-- END_TF_DOCS -->` markers; run `terraform-docs .` after changing `variables.tf`/`outputs.tf` instead.
