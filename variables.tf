variable "aws_region" {
  description = "AWS region to deploy the EventBridge connection, API destination, and rule into. Must be a region where GuardDuty findings are generated, since the rule matches on the default event bus."
  type        = string
}

variable "datadog_api_key" {
  description = "Datadog API key the EventBridge connection uses to authenticate to Datadog. The AWS provider requires this as a plaintext argument (aws_cloudwatch_event_connection has no write-only or ephemeral variant), so it will be persisted in Terraform state; supply it via TF_VAR_datadog_api_key from a CI secret store or an untracked .tfvars file, never a literal in checked-in code, and protect state per this project's state-security controls."
  type        = string
  sensitive   = true
}

variable "datadog_site" {
  description = "Datadog site to send GuardDuty findings to. Determines the Logs intake endpoint via local.datadog_site_domains in datadog.tf."
  type        = string
  default     = "US1"

  validation {
    condition     = contains(["US1", "US3", "US5", "EU", "AP1", "AP2", "UK1", "US1-FED", "US2-FED"], var.datadog_site)
    error_message = "datadog_site must be one of: US1, US3, US5, EU, AP1, AP2, UK1, US1-FED, US2-FED."
  }
}

variable "invocation_rate_limit_per_second" {
  description = "Maximum number of invocations per second EventBridge sends to the Datadog API destination."
  type        = number
  default     = 300
}

variable "eventbridge_role_arn" {
  description = "ARN of an existing IAM role EventBridge should assume to invoke the Datadog API destination. When null (the default), this module creates its own role scoped to this region. Pass in the eventbridge_role_arn output from a prior call to this module (in another region) to share one role across multiple calls instead of creating a new one each time."
  type        = string
  default     = null
}

variable "limit_role_to_region" {
  description = "When true (the default), a role created by this call is scoped to only this call's own Datadog API destination. Set to false if you intend to share this call's eventbridge_role_arn output into other regions' calls, so the role's policy is broadened to cover any datadog-api-destination/* ARN in the account instead of just this one. Has no effect when eventbridge_role_arn is set, since this call isn't creating a role."
  type        = bool
  default     = true
}

variable "max_event_age_seconds" {
  description = "Maximum age, in seconds, EventBridge keeps retrying a failed delivery to the Datadog API destination before sending it to the dead-letter queue."
  type        = number
  default     = 3600
}

variable "max_retry_attempts" {
  description = "Maximum number of retry attempts EventBridge makes on a failed delivery to the Datadog API destination before sending it to the dead-letter queue."
  type        = number
  default     = 10
}

variable "datadog_app_key" {
  description = "Datadog application key used to create a monitor on the dead-letter queue's depth via the Datadog API. Distinct from datadog_api_key: that key only authorizes the AWS-side EventBridge connection to send logs into Datadog's intake, while this one authenticates Terraform's own calls to the Datadog management API and should be scoped to only monitor management. Setting this is what creates the monitor; requires the Datadog AWS integration to already be enabled on this account, which this module can't verify or enable."
  type        = string
  sensitive   = true
  default     = null
}

variable "dlq_monitor_notify" {
  description = "Datadog notification targets (e.g. [\"@slack-oncall\", \"@pagerduty-guardduty\", \"@user@example.com\"]) appended to the dead-letter queue monitor's message. Only used when datadog_app_key is set."
  type        = list(string)
  default     = []
}

variable "create_dlq_cloudwatch_alarm" {
  description = "Whether to create a CloudWatch alarm on the dead-letter queue's ApproximateNumberOfMessagesVisible metric. Defaults to true. Set to false if you're relying on the Datadog monitor (datadog_app_key) instead and don't want a second, separate alarm in CloudWatch that nothing is watching."
  type        = bool
  default     = true
}
