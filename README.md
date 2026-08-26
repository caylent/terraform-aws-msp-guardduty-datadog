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
  source  = "caylent/guardduty-datadog/aws"
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
  source  = "caylent/guardduty-datadog/aws"
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
  source   = "caylent/guardduty-datadog/aws"
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

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9.0 |
| aws | ~> 6.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| aws_region | AWS region to deploy the EventBridge connection, API destination, and rule into. Must be a region where GuardDuty findings are generated. | `string` | n/a | yes |
| datadog_api_key | Datadog API key the EventBridge connection uses to authenticate to Datadog. | `string` | n/a | yes |
| datadog_site | Datadog site to send GuardDuty findings to. One of `US1`, `US3`, `US5`, `EU`, `AP1`, `AP2`, `UK1`, `US1-FED`, `US2-FED`. | `string` | `"US1"` | no |
| invocation_rate_limit_per_second | Maximum number of invocations per second EventBridge sends to the Datadog API destination. | `number` | `300` | no |

## Outputs

| Name | Description |
|------|-------------|
| datadog_connection_arn | ARN of the EventBridge connection to Datadog. |
| datadog_api_destination_arn | ARN of the EventBridge API destination for Datadog. |
| guardduty_to_datadog_rule_arn | ARN of the EventBridge rule that routes GuardDuty findings to Datadog. |
