# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

This is a standalone, publicly-distributed Terraform module (`caylent/msp-guardduty-datadog/aws` on the Terraform Registry) that routes Amazon GuardDuty findings to Datadog. It was migrated out of an internal Trek10/Caylent GitLab monorepo (`guard-duty`), where it originally lived alongside an unrelated legacy CloudFormation/SAM implementation of the same goal — that history is not relevant here; this repo is now the sole source of truth for the Terraform path.

## Publishing a new version

There is no build/publish step. The Terraform Registry re-indexes this repo's tags automatically. To release a new version: merge to `main`, then `git tag vX.Y.Z && git push origin vX.Y.Z`.

## CI (`.github/workflows/pr-checks.yml`)

Runs on every PR against `main`:
- `fmt` — `terraform fmt -check -recursive`
- `validate` — `terraform init -backend=false && terraform validate`
- `docs` — regenerates `README.md` via a pinned `terraform-docs` binary (version tracked in the job's `TERRAFORM_DOCS_VERSION` env var, currently `0.24.0`) and fails on `git diff` if it doesn't match. Config lives in `.terraform-docs.yml`. Deliberately installs the exact pinned binary rather than using the `terraform-docs/gh-actions` marketplace action, since that action's pinned bundled `terraform-docs` version can lag behind and cause spurious diffs against a README generated locally with a newer version.

## Not yet added (deliberately deferred, not forgotten)

- **`tflint`** — would catch things `terraform validate` doesn't (unused variables, deprecated syntax, provider-specific lint rules). Low cost to add; consider adding once this module has more surface area or after the first real external contribution.
- **`tfsec` or `checkov`** — static security scanning. Worth adding given this module handles a Datadog API key and IAM roles/policies, but expect initial false positives that need triage/suppression — budget setup time rather than treating it as a drop-in addition.

## Docs

`README.md`'s Requirements/Inputs/Outputs tables are auto-generated — don't hand-edit them between the `<!-- BEGIN_TF_DOCS -->`/`<!-- END_TF_DOCS -->` markers. Run `terraform-docs .` locally after changing `variables.tf`/`outputs.tf`.
