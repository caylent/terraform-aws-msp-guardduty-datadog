# Changelog

## v1.1.0 (unreleased)

- Added `eventbridge_role_arn` to let a caller share one IAM role across
  multiple regional calls instead of creating a new one per region, and
  `limit_role_to_region` to control whether a created role's policy is
  scoped to its own region or widened for sharing.
- Added a dead-letter queue, `retry_policy`, and `dead_letter_config` on the
  EventBridge target, so a delivery that keeps failing lands in SQS instead
  of being silently discarded after AWS's default 24h/185 retries.
- Added `ddtags` (`account_id`, `region`) to the event forwarded to Datadog.
- Added an optional Datadog-native monitor (`datadog_app_key`) and a
  CloudWatch alarm (`create_dlq_cloudwatch_alarm`, on by default) on the
  dead-letter queue's depth.
- **Upgrade note:** this release makes the EventBridge invoke role and its
  policy conditionally created (`count`) to support `eventbridge_role_arn`.
  Their Terraform state address gains an index (e.g.
  `aws_iam_role.eventbridge_invoke_datadog` becomes `...[0]`), so `apply`
  will show a destroy-then-create for that role and its policy on upgrade.
  No input or output that existed in v1.0.x changed shape.

## v1.0.1

- Initial public release.
