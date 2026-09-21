resource "aws_cloudwatch_event_rule" "guardduty_to_datadog" {
  name        = "guardduty-findings-to-datadog"
  description = "Routes GuardDuty findings to Datadog"

  event_pattern = jsonencode({
    "detail-type" = ["GuardDuty Finding"]
    "source"      = ["aws.guardduty"]
  })
}

data "aws_caller_identity" "current" {
  count = var.eventbridge_role_arn == null && !var.limit_role_to_region ? 1 : 0
}

# Only created when the caller doesn't pass eventbridge_role_arn in, since a
# role can instead be shared in from another region's call.
resource "aws_iam_role" "eventbridge_invoke_datadog" {
  count = var.eventbridge_role_arn == null ? 1 : 0
  name  = "eventbridge-invoke-datadog-api-destination-${var.aws_region}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "events.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "invoke_api_destination" {
  count = var.eventbridge_role_arn == null ? 1 : 0
  name  = "invoke-datadog-api-destination"
  role  = aws_iam_role.eventbridge_invoke_datadog[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "events:InvokeApiDestination"
      Resource = var.limit_role_to_region ? (
        aws_cloudwatch_event_api_destination.datadog.arn
        ) : (
        "arn:aws:events:*:${data.aws_caller_identity.current[0].account_id}:api-destination/datadog-api-destination-*"
      )
    }]
  })
}

locals {
  eventbridge_role_arn = coalesce(var.eventbridge_role_arn, try(aws_iam_role.eventbridge_invoke_datadog[0].arn, null))
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
  role_arn = local.eventbridge_role_arn

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
