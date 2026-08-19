output "datadog_api_key_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the Datadog API key. Update its value with the real key after creation, then re-run terraform apply to push it into the EventBridge connection."
  value       = aws_secretsmanager_secret.datadog_api_key.arn
}

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
