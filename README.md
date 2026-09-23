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
instance. That self-contained provider is also why `count`/`for_each` can't
be used here — Terraform forbids both on any module that declares its own
provider block — so a dynamic loop over a region list isn't possible;
instead, declare one explicit, separately-named module call per region:

```hcl
module "guardduty_to_datadog_use1" {
  source  = "caylent/msp-guardduty-datadog/aws"
  version = "~> 1.0"

  aws_region      = "us-east-1"
  datadog_api_key = var.datadog_api_key
  datadog_site    = "US1"
}

module "guardduty_to_datadog_usw2" {
  source  = "caylent/msp-guardduty-datadog/aws"
  version = "~> 1.0"

  aws_region      = "us-west-2"
  datadog_api_key = var.datadog_api_key
  datadog_site    = "US1"
}
```

Each call above creates its own IAM role, scoped to only that call's own
region, so no cross-region wiring is needed to get started. See
["Sharing one IAM role across regions"](#sharing-one-iam-role-across-regions)
below if you'd rather have one shared role instead of one per region.

Only include regions where GuardDuty is actually enabled for the account —
deploying this module in a region without GuardDuty active will succeed but
never forward any findings.

### Sharing one IAM role across regions

Each call to this module creates its own IAM role for EventBridge to invoke
the Datadog API destination, scoped to that call's region, so calling it
for N regions creates N nearly-identical roles by default. To avoid that,
pass the first call's `eventbridge_role_arn` output into every subsequent
call's `eventbridge_role_arn` input; that call skips creating its own role
and reuses the one already created.

By default, a role's policy only authorizes invoking its own call's
destination (`limit_role_to_region = true`), so if you intend to share a
call's role into other regions, set `limit_role_to_region = false` on that
call (the one actually creating the role) *before* wiring it elsewhere.
That widens the policy to a wildcarded resource pattern covering any
`datadog-api-destination/*` ARN in the account, so the role keeps working
once shared into other regions' calls:

```hcl
module "guardduty_to_datadog_use1" {
  source  = "caylent/msp-guardduty-datadog/aws"
  version = "~> 1.0"

  aws_region           = "us-east-1"
  limit_role_to_region = false
  datadog_api_key      = var.datadog_api_key
  datadog_site         = "US1"
}

module "guardduty_to_datadog_usw2" {
  source  = "caylent/msp-guardduty-datadog/aws"
  version = "~> 1.0"

  aws_region           = "us-west-2"
  eventbridge_role_arn = module.guardduty_to_datadog_use1.eventbridge_role_arn
  datadog_api_key      = var.datadog_api_key
  datadog_site         = "US1"
}
```

## Dead-letter queue

If EventBridge can't deliver a finding to the Datadog API destination —
after retrying for up to `max_event_age_seconds` / `max_retry_attempts` —
the finding lands in this region's SQS dead-letter queue instead of being
silently discarded. Without watching this queue, a broken delivery pipeline
looks healthy while forwarding nothing to Datadog.

The queue only catches the failed finding; nothing in this module redrives
it back toward Datadog automatically. Once alerted, redelivering a message
(after fixing whatever caused delivery to fail, e.g. a rotated API key or a
Datadog outage) is a manual step — read the message off the queue and
re-send it, either by hand or with a script, since the DLQ's job here is
visibility into a stuck pipeline, not a second delivery path.

### CloudWatch alarm (on by default)

The module creates a CloudWatch alarm on the queue's
`ApproximateNumberOfMessagesVisible` metric automatically — no setup
required. Its ARN is exposed via the `dlq_cloudwatch_alarm_arn` output for
wiring your own notification (e.g. an SNS topic subscription). If you're
relying on the Datadog monitor below instead and don't want a second,
separate alarm sitting unwatched in CloudWatch, set
`create_dlq_cloudwatch_alarm = false`.

### Alerting in Datadog instead or in addition

Since GuardDuty findings routed through this module are meant to be
reviewed in Datadog, you can also (or instead) alert on a stuck queue from
inside Datadog itself, using the SQS metrics the
[Datadog AWS integration](https://docs.datadoghq.com/integrations/amazon_web_services/)
already collects. That integration must already be enabled on the account;
this module can't verify or enable it for you. Set `datadog_app_key` to
create the monitor:

`datadog_app_key` is a different credential than `datadog_api_key`:
`datadog_api_key` only authorizes the AWS-side EventBridge connection to
send logs into Datadog's intake, while `datadog_app_key` authenticates
Terraform's own calls to the Datadog management API to create the
monitor, and should be scoped to only monitor management, not full admin
access.

```hcl
module "guardduty_to_datadog" {
  source  = "caylent/msp-guardduty-datadog/aws"
  version = "~> 1.0"

  aws_region         = "us-east-1"
  datadog_api_key    = var.datadog_api_key
  datadog_app_key    = var.datadog_app_key
  dlq_monitor_notify = ["@slack-guardduty-alerts"]
  datadog_site       = "US1"

  # Skip the CloudWatch alarm if you only want the Datadog monitor above.
  create_dlq_cloudwatch_alarm = false
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
| <a name="requirement_datadog"></a> [datadog](#requirement\_datadog) | >= 3.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to deploy the EventBridge connection, API destination, and rule into. Must be a region where GuardDuty findings are generated, since the rule matches on the default event bus. | `string` | n/a | yes |
| <a name="input_create_dlq_cloudwatch_alarm"></a> [create\_dlq\_cloudwatch\_alarm](#input\_create\_dlq\_cloudwatch\_alarm) | Whether to create a CloudWatch alarm on the dead-letter queue's ApproximateNumberOfMessagesVisible metric. Defaults to true. Set to false if you're relying on the Datadog monitor (datadog\_app\_key) instead and don't want a second, separate alarm in CloudWatch that nothing is watching. | `bool` | `true` | no |
| <a name="input_datadog_api_key"></a> [datadog\_api\_key](#input\_datadog\_api\_key) | Datadog API key the EventBridge connection uses to authenticate to Datadog. The AWS provider requires this as a plaintext argument (aws\_cloudwatch\_event\_connection has no write-only or ephemeral variant), so it will be persisted in Terraform state; supply it via TF\_VAR\_datadog\_api\_key from a CI secret store or an untracked .tfvars file, never a literal in checked-in code, and protect state per this project's state-security controls. | `string` | n/a | yes |
| <a name="input_datadog_app_key"></a> [datadog\_app\_key](#input\_datadog\_app\_key) | Datadog application key used to create a monitor on the dead-letter queue's depth via the Datadog API. Distinct from datadog\_api\_key: that key only authorizes the AWS-side EventBridge connection to send logs into Datadog's intake, while this one authenticates Terraform's own calls to the Datadog management API and should be scoped to only monitor management. Setting this is what creates the monitor; requires the Datadog AWS integration to already be enabled on this account, which this module can't verify or enable. | `string` | `null` | no |
| <a name="input_datadog_site"></a> [datadog\_site](#input\_datadog\_site) | Datadog site to send GuardDuty findings to. Determines the Logs intake endpoint via local.datadog\_site\_domains in datadog.tf. | `string` | `"US1"` | no |
| <a name="input_dlq_monitor_notify"></a> [dlq\_monitor\_notify](#input\_dlq\_monitor\_notify) | Datadog notification targets (e.g. ["@slack-oncall", "@pagerduty-guardduty", "@user@example.com"]) appended to the dead-letter queue monitor's message. Only used when datadog\_app\_key is set. | `list(string)` | `[]` | no |
| <a name="input_eventbridge_role_arn"></a> [eventbridge\_role\_arn](#input\_eventbridge\_role\_arn) | ARN of an existing IAM role EventBridge should assume to invoke the Datadog API destination. When null (the default), this module creates its own role scoped to this region. Pass in the eventbridge\_role\_arn output from a prior call to this module (in another region) to share one role across multiple calls instead of creating a new one each time. | `string` | `null` | no |
| <a name="input_invocation_rate_limit_per_second"></a> [invocation\_rate\_limit\_per\_second](#input\_invocation\_rate\_limit\_per\_second) | Maximum number of invocations per second EventBridge sends to the Datadog API destination. | `number` | `300` | no |
| <a name="input_limit_role_to_region"></a> [limit\_role\_to\_region](#input\_limit\_role\_to\_region) | When true (the default), a role created by this call is scoped to only this call's own Datadog API destination. Set to false if you intend to share this call's eventbridge\_role\_arn output into other regions' calls, so the role's policy is broadened to cover any datadog-api-destination/* ARN in the account instead of just this one. Has no effect when eventbridge\_role\_arn is set, since this call isn't creating a role. | `bool` | `true` | no |
| <a name="input_max_event_age_seconds"></a> [max\_event\_age\_seconds](#input\_max\_event\_age\_seconds) | Maximum age, in seconds, EventBridge keeps retrying a failed delivery to the Datadog API destination before sending it to the dead-letter queue. | `number` | `3600` | no |
| <a name="input_max_retry_attempts"></a> [max\_retry\_attempts](#input\_max\_retry\_attempts) | Maximum number of retry attempts EventBridge makes on a failed delivery to the Datadog API destination before sending it to the dead-letter queue. | `number` | `10` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_datadog_api_destination_arn"></a> [datadog\_api\_destination\_arn](#output\_datadog\_api\_destination\_arn) | ARN of the EventBridge API destination for Datadog. |
| <a name="output_datadog_connection_arn"></a> [datadog\_connection\_arn](#output\_datadog\_connection\_arn) | ARN of the EventBridge connection to Datadog. |
| <a name="output_dlq_arn"></a> [dlq\_arn](#output\_dlq\_arn) | ARN of the SQS dead-letter queue that receives GuardDuty findings EventBridge could not deliver to Datadog after exhausting retries. Alarm on this queue's ApproximateNumberOfMessagesVisible metric to detect a broken delivery pipeline. |
| <a name="output_dlq_cloudwatch_alarm_arn"></a> [dlq\_cloudwatch\_alarm\_arn](#output\_dlq\_cloudwatch\_alarm\_arn) | ARN of the CloudWatch alarm on the dead-letter queue's depth. Null when create\_dlq\_cloudwatch\_alarm is false. |
| <a name="output_dlq_monitor_id"></a> [dlq\_monitor\_id](#output\_dlq\_monitor\_id) | ID of the Datadog monitor alerting on the dead-letter queue's depth. Null unless datadog\_app\_key is set. |
| <a name="output_eventbridge_role_arn"></a> [eventbridge\_role\_arn](#output\_eventbridge\_role\_arn) | ARN of the IAM role EventBridge assumes to invoke the Datadog API destination — either the role this call created, or the eventbridge\_role\_arn passed in. Pass this into another call's eventbridge\_role\_arn input to share one role across multiple regions instead of creating a new one per region. |
| <a name="output_guardduty_to_datadog_rule_arn"></a> [guardduty\_to\_datadog\_rule\_arn](#output\_guardduty\_to\_datadog\_rule\_arn) | ARN of the EventBridge rule that routes GuardDuty findings to Datadog. |
<!-- END_TF_DOCS -->