variable "aws_region" {
  description = "AWS region to deploy the EventBridge connection, API destination, and rule into. Must be a region where GuardDuty findings are generated, since the rule matches on the default event bus."
  type        = string
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
