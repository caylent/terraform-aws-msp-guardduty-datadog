resource "aws_cloudwatch_event_rule" "guardduty_to_datadog" {
  name        = "guardduty-findings-to-datadog-${var.aws_region}"
  description = "Routes GuardDuty findings to Datadog"

  event_pattern = jsonencode({
    "detail-type" = ["GuardDuty Finding"]
    "source"      = ["aws.guardduty"]
  })
}

# A rejected delivery to the Datadog API destination retries for
# max_event_age_seconds / max_retry_attempts and is then sent here instead of
# being silently discarded, so a broken delivery is visible as messages
# landing in this queue rather than a healthy-looking pipeline that has
# stopped forwarding findings.
resource "aws_sqs_queue" "guardduty_to_datadog_dlq" {
  name = "guardduty-to-datadog-dlq-${var.aws_region}"
}

resource "aws_sqs_queue_policy" "guardduty_to_datadog_dlq" {
  queue_url = aws_sqs_queue.guardduty_to_datadog_dlq.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "events.amazonaws.com" }
      Action    = "sqs:SendMessage"
      Resource  = aws_sqs_queue.guardduty_to_datadog_dlq.arn
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = aws_cloudwatch_event_rule.guardduty_to_datadog.arn
        }
      }
    }]
  })
}

resource "aws_cloudwatch_event_target" "datadog" {
  rule     = aws_cloudwatch_event_rule.guardduty_to_datadog.name
  arn      = aws_cloudwatch_event_api_destination.datadog.arn
  role_arn = var.eventbridge_role_arn

  input_transformer {
    input_paths = {
      detail  = "$.detail"
      account = "$.account"
    }
    input_template = "{\"message\": <detail>,\"ddsource\":\"guardduty\",\"ddtags\":\"account_id:<account>,region:${var.aws_region}\"}"
  }

  retry_policy {
    maximum_event_age_in_seconds = var.max_event_age_seconds
    maximum_retry_attempts       = var.max_retry_attempts
  }

  dead_letter_config {
    arn = aws_sqs_queue.guardduty_to_datadog_dlq.arn
  }
}
