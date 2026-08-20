resource "aws_cloudwatch_event_rule" "guardduty_to_datadog" {
  name        = "guardduty-findings-to-datadog"
  description = "Routes GuardDuty findings to Datadog"

  event_pattern = jsonencode({
    "detail-type" = ["GuardDuty Finding"]
    "source"      = ["aws.guardduty"]
  })
}

resource "aws_iam_role" "eventbridge_invoke_datadog" {
  name = "eventbridge-invoke-datadog-api-destination"

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
  name = "invoke-datadog-api-destination"
  role = aws_iam_role.eventbridge_invoke_datadog.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "events:InvokeApiDestination"
      Resource = aws_cloudwatch_event_api_destination.datadog.arn
    }]
  })
}

resource "aws_cloudwatch_event_target" "datadog" {
  rule     = aws_cloudwatch_event_rule.guardduty_to_datadog.name
  arn      = aws_cloudwatch_event_api_destination.datadog.arn
  role_arn = aws_iam_role.eventbridge_invoke_datadog.arn

  input_transformer {
    input_paths = {
      detail = "$.detail"
    }
    input_template = "{\"message\": <detail>,\"source\":\"guardduty\"}"
  }
}
