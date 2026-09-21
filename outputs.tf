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

output "eventbridge_role_arn" {
  description = "ARN of the IAM role EventBridge assumes to invoke the Datadog API destination — either the role this call created, or the eventbridge_role_arn passed in. Pass this into another call's eventbridge_role_arn input to share one role across multiple regions instead of creating a new one per region."
  value       = local.eventbridge_role_arn
}

output "dlq_arn" {
  description = "ARN of the SQS dead-letter queue that receives GuardDuty findings EventBridge could not deliver to Datadog after exhausting retries. Alarm on this queue's ApproximateNumberOfMessagesVisible metric to detect a broken delivery pipeline."
  value       = aws_sqs_queue.guardduty_to_datadog_dlq.arn
}
