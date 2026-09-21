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

output "dlq_monitor_id" {
  description = "ID of the Datadog monitor alerting on the dead-letter queue's depth. Null unless datadog_app_key is set."
  value       = try(datadog_monitor.dlq_depth[0].id, null)
}

output "dlq_cloudwatch_alarm_arn" {
  description = "ARN of the CloudWatch alarm on the dead-letter queue's depth. Null when create_dlq_cloudwatch_alarm is false."
  value       = try(aws_cloudwatch_metric_alarm.guardduty_to_datadog_dlq[0].arn, null)
}
