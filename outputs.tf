output "datadog_connection_arn" {
  description = "ARN of the EventBridge connection to Datadog."
  value       = aws_cloudwatch_event_connection.datadog.arn
}

output "datadog_api_destination_arn" {
  description = "ARN of the EventBridge API destination for Datadog."
  value       = aws_cloudwatch_event_api_destination.datadog.arn
}

output "guardduty_to_datadog_rule_arn" {
  description = "ARN of the EventBridge rule that routes GuardDuty findings to Datadog."
  value       = aws_cloudwatch_event_rule.guardduty_to_datadog.arn
}
