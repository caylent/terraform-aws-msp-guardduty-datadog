# GuardDuty Findings to Datadog

Routes Amazon GuardDuty findings to Datadog via an EventBridge rule, API
destination, and connection — no intermediate SNS topic or Lambda function
required.

## How it works

An EventBridge rule matches `aws.guardduty` / `GuardDuty Finding` events on
the account's default event bus and forwards them to Datadog's Logs intake
endpoint through an EventBridge API destination, authenticated with a
Datadog API key.

## Usage

```hcl
module "guardduty_to_datadog" {
  source  = "caylent/msp-guardduty-datadog/aws"
  version = "~> 1.0"

  aws_region      = "us-east-1"
  datadog_api_key = var.datadog_api_key
  datadog_site    = "US1"
}
```

Deploy this module in every region where GuardDuty is enabled — the
EventBridge rule only matches findings on its own region's default event
bus.

### Avoiding a duplicated region literal

If your root configuration already has a default AWS provider configured
for a region, you can pull that region into the module call instead of
repeating it as a separate literal:

```hcl
data "aws_region" "current" {}

module "guardduty_to_datadog" {
  source  = "caylent/msp-guardduty-datadog/aws"
  version = "~> 1.0"

  aws_region      = data.aws_region.current.region
  datadog_api_key = var.datadog_api_key
  datadog_site    = "US1"
}
```

This only makes sense for a single-region deployment matching your root
provider's region — see below for deploying across multiple regions.

## Multi-region deployment

GuardDuty findings and the default event bus are both regional, so this
module must be deployed once per region you want covered — there is no
single-deployment way to catch findings account-wide. This module declares
its own `provider "aws"` block scoped to `var.aws_region`, so you don't need
to pre-declare AWS provider aliases in your root configuration; calling the
module once per region is enough, and each call gets its own provider
instance:

```hcl
locals {
  guardduty_regions = [
    "us-east-1",
    "us-west-2",
    "eu-west-1",
  ]
}

module "guardduty_to_datadog" {
  source   = "caylent/msp-guardduty-datadog/aws"
  version  = "~> 1.0"
  for_each = toset(local.guardduty_regions)

  aws_region      = each.value
  datadog_api_key = var.datadog_api_key
  datadog_site    = "US1"
}
```

Only include regions where GuardDuty is actually enabled for the account —
deploying this module in a region without GuardDuty active will succeed but
never forward any findings.

## Providing the Datadog API key

`aws_cloudwatch_event_connection` has no write-only or ephemeral argument
for `auth_parameters`, so the API key is passed as a plaintext Terraform
variable and will be persisted in Terraform state. Supply it via an
environment variable rather than a literal in checked-in code or `.tfvars`
committed to version control:

```bash
export TF_VAR_datadog_api_key="<your-datadog-api-key>"
```

Protect the state file for this module (remote state with encryption and
restricted access) accordingly.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to deploy the EventBridge connection, API destination, and rule into. Must be a region where GuardDuty findings are generated, since the rule matches on the default event bus. | `string` | n/a | yes |
| <a name="input_datadog_api_key"></a> [datadog\_api\_key](#input\_datadog\_api\_key) | Datadog API key the EventBridge connection uses to authenticate to Datadog. The AWS provider requires this as a plaintext argument (aws\_cloudwatch\_event\_connection has no write-only or ephemeral variant), so it will be persisted in Terraform state; supply it via TF\_VAR\_datadog\_api\_key from a CI secret store or an untracked .tfvars file, never a literal in checked-in code, and protect state per this project's state-security controls. | `string` | n/a | yes |
| <a name="input_datadog_site"></a> [datadog\_site](#input\_datadog\_site) | Datadog site to send GuardDuty findings to. Determines the Logs intake endpoint via local.datadog\_site\_domains in datadog.tf. | `string` | `"US1"` | no |
| <a name="input_invocation_rate_limit_per_second"></a> [invocation\_rate\_limit\_per\_second](#input\_invocation\_rate\_limit\_per\_second) | Maximum number of invocations per second EventBridge sends to the Datadog API destination. | `number` | `300` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_datadog_api_destination_arn"></a> [datadog\_api\_destination\_arn](#output\_datadog\_api\_destination\_arn) | ARN of the EventBridge API destination for Datadog. |
| <a name="output_datadog_connection_arn"></a> [datadog\_connection\_arn](#output\_datadog\_connection\_arn) | ARN of the EventBridge connection to Datadog. |
| <a name="output_guardduty_to_datadog_rule_arn"></a> [guardduty\_to\_datadog\_rule\_arn](#output\_guardduty\_to\_datadog\_rule\_arn) | ARN of the EventBridge rule that routes GuardDuty findings to Datadog. |
<!-- END_TF_DOCS -->