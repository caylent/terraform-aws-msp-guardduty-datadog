variable "aws_region" {
  description = "AWS region this instance of the submodule deploys the EventBridge connection, API destination, rule, and DLQ into. Must be a region where GuardDuty findings are generated, since the rule matches on the default event bus."
  type        = string
}

variable "eventbridge_role_arn" {
  description = "ARN of the IAM role EventBridge assumes to invoke the Datadog API destination. Created once by the calling root module and shared across all region instances, since IAM roles are account-global."
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
