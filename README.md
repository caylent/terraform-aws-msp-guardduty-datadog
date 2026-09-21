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
  version = "~> 2.0"

  regions         = ["us-east-1"]
  datadog_api_key = var.datadog_api_key
  datadog_site    = "US1"
}
```

Only include regions where GuardDuty is actually enabled for the account —
deploying into a region without GuardDuty active will succeed but never
forward any findings.

## Multi-region deployment

GuardDuty findings and the default event bus are both regional, so this
module deploys once per region listed in `regions` — there is no
single-deployment way to catch findings account-wide. The module handles
the fan-out internally (one AWS provider per real AWS region, toggled on or
off per your `regions` list), so you don't need to declare provider aliases
or a `for_each` loop yourself:

```hcl
module "guardduty_to_datadog" {
  source  = "caylent/msp-guardduty-datadog/aws"
  version = "~> 2.0"

  regions = [
    "us-east-1",
    "us-west-2",
    "eu-west-1",
  ]

  datadog_api_key = var.datadog_api_key
  datadog_site    = "US1"
}
```

A single IAM role (EventBridge's permission to invoke the Datadog API
destination) is shared across every enabled region, since IAM roles are
account-global rather than regional. Each region still gets its own
EventBridge rule, connection, API destination, and dead-letter queue.

## Dead-letter queue

Each enabled region gets its own SQS dead-letter queue. If EventBridge
can't deliver a finding to the Datadog API destination — after retrying for
up to `max_event_age_seconds` / `max_retry_attempts` — the finding lands in
that region's queue instead of being silently discarded. Without this, a
broken delivery pipeline looks healthy while forwarding nothing.

The module exposes each region's queue ARN via the `dlq_arns` output
(a map of region to ARN). Alarm on each queue's
`ApproximateNumberOfMessagesVisible` metric to detect a stuck pipeline:

```hcl
resource "aws_cloudwatch_metric_alarm" "guardduty_datadog_dlq" {
  for_each = module.guardduty_to_datadog.dlq_arns

  alarm_name          = "guardduty-datadog-dlq-${each.key}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  dimensions = {
    QueueName = split(":", each.value)[5]
  }
}
```

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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.43.0 |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_datadog_api_key"></a> [datadog\_api\_key](#input\_datadog\_api\_key) | Datadog API key the EventBridge connection uses to authenticate to Datadog. The AWS provider requires this as a plaintext argument (aws\_cloudwatch\_event\_connection has no write-only or ephemeral variant), so it will be persisted in Terraform state; supply it via TF\_VAR\_datadog\_api\_key from a CI secret store or an untracked .tfvars file, never a literal in checked-in code, and protect state per this project's state-security controls. | `string` | n/a | yes |
| <a name="input_datadog_site"></a> [datadog\_site](#input\_datadog\_site) | Datadog site to send GuardDuty findings to. Determines the Logs intake endpoint via local.datadog\_site\_domains in modules/msp-guardduty-datadog-single-region/datadog.tf. | `string` | `"US1"` | no |
| <a name="input_invocation_rate_limit_per_second"></a> [invocation\_rate\_limit\_per\_second](#input\_invocation\_rate\_limit\_per\_second) | Maximum number of invocations per second EventBridge sends to the Datadog API destination, per region. | `number` | `300` | no |
| <a name="input_max_event_age_seconds"></a> [max\_event\_age\_seconds](#input\_max\_event\_age\_seconds) | Maximum age, in seconds, EventBridge keeps retrying a failed delivery to the Datadog API destination before sending it to the dead-letter queue. | `number` | `3600` | no |
| <a name="input_max_retry_attempts"></a> [max\_retry\_attempts](#input\_max\_retry\_attempts) | Maximum number of retry attempts EventBridge makes on a failed delivery to the Datadog API destination before sending it to the dead-letter queue. | `number` | `10` | no |
| <a name="input_regions"></a> [regions](#input\_regions) | AWS regions to deploy GuardDuty-to-Datadog forwarding into. GuardDuty findings and the default event bus are both regional, so at least one region must be listed; only include regions where GuardDuty is actually enabled for the account. | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_datadog_api_destination_arns"></a> [datadog\_api\_destination\_arns](#output\_datadog\_api\_destination\_arns) | Map of AWS region to the ARN of the EventBridge API destination for Datadog in that region. |
| <a name="output_datadog_connection_arns"></a> [datadog\_connection\_arns](#output\_datadog\_connection\_arns) | Map of AWS region to the ARN of the EventBridge connection to Datadog in that region. |
| <a name="output_dlq_arns"></a> [dlq\_arns](#output\_dlq\_arns) | Map of AWS region to the ARN of that region's SQS dead-letter queue. Alarm on each queue's ApproximateNumberOfMessagesVisible metric to detect a broken delivery pipeline in that region. |
| <a name="output_eventbridge_role_arn"></a> [eventbridge\_role\_arn](#output\_eventbridge\_role\_arn) | ARN of the shared IAM role EventBridge assumes to invoke the Datadog API destination, used across every enabled region. |
| <a name="output_guardduty_to_datadog_rule_arns"></a> [guardduty\_to\_datadog\_rule\_arns](#output\_guardduty\_to\_datadog\_rule\_arns) | Map of AWS region to the ARN of the EventBridge rule that routes GuardDuty findings to Datadog in that region. |
<!-- END_TF_DOCS -->