data "aws_caller_identity" "current" {
  provider = aws.us_east_1
}

# IAM is account-global, so one role is shared across every enabled region
# instead of each region's EventBridge rule getting its own — created via a
# single fixed provider alias since the creating region has no bearing on a
# global resource.
resource "aws_iam_role" "eventbridge_invoke_datadog" {
  provider = aws.us_east_1
  name     = "eventbridge-invoke-datadog-api-destination"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "events.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Scoped to a wildcarded ARN pattern rather than each enabled region's exact
# API destination ARN, since those ARNs only exist for count-toggled module
# instances that may or may not be created, and the pattern needs no changes
# as regions are added to or removed from var.regions.
resource "aws_iam_role_policy" "invoke_api_destination" {
  provider = aws.us_east_1
  name     = "invoke-datadog-api-destination"
  role     = aws_iam_role.eventbridge_invoke_datadog.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "events:InvokeApiDestination"
      Resource = "arn:aws:events:*:${data.aws_caller_identity.current.account_id}:api-destination/datadog-api-destination-*"
    }]
  })
}
