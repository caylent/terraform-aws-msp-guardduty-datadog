output "eventbridge_role_arn" {
  description = "ARN of the shared IAM role EventBridge assumes to invoke the Datadog API destination, used across every enabled region."
  value       = aws_iam_role.eventbridge_invoke_datadog.arn
}

output "datadog_connection_arns" {
  description = "Map of AWS region to the ARN of the EventBridge connection to Datadog in that region."
  value = merge(
    (length(module.us_east_1) > 0 ? { "us-east-1" = module.us_east_1[0].datadog_connection_arn } : {}),
    (length(module.us_east_2) > 0 ? { "us-east-2" = module.us_east_2[0].datadog_connection_arn } : {}),
    (length(module.us_west_1) > 0 ? { "us-west-1" = module.us_west_1[0].datadog_connection_arn } : {}),
    (length(module.us_west_2) > 0 ? { "us-west-2" = module.us_west_2[0].datadog_connection_arn } : {}),
    (length(module.af_south_1) > 0 ? { "af-south-1" = module.af_south_1[0].datadog_connection_arn } : {}),
    (length(module.ap_east_1) > 0 ? { "ap-east-1" = module.ap_east_1[0].datadog_connection_arn } : {}),
    (length(module.ap_south_1) > 0 ? { "ap-south-1" = module.ap_south_1[0].datadog_connection_arn } : {}),
    (length(module.ap_south_2) > 0 ? { "ap-south-2" = module.ap_south_2[0].datadog_connection_arn } : {}),
    (length(module.ap_southeast_1) > 0 ? { "ap-southeast-1" = module.ap_southeast_1[0].datadog_connection_arn } : {}),
    (length(module.ap_southeast_2) > 0 ? { "ap-southeast-2" = module.ap_southeast_2[0].datadog_connection_arn } : {}),
    (length(module.ap_southeast_3) > 0 ? { "ap-southeast-3" = module.ap_southeast_3[0].datadog_connection_arn } : {}),
    (length(module.ap_southeast_4) > 0 ? { "ap-southeast-4" = module.ap_southeast_4[0].datadog_connection_arn } : {}),
    (length(module.ap_southeast_5) > 0 ? { "ap-southeast-5" = module.ap_southeast_5[0].datadog_connection_arn } : {}),
    (length(module.ap_southeast_7) > 0 ? { "ap-southeast-7" = module.ap_southeast_7[0].datadog_connection_arn } : {}),
    (length(module.ap_northeast_1) > 0 ? { "ap-northeast-1" = module.ap_northeast_1[0].datadog_connection_arn } : {}),
    (length(module.ap_northeast_2) > 0 ? { "ap-northeast-2" = module.ap_northeast_2[0].datadog_connection_arn } : {}),
    (length(module.ap_northeast_3) > 0 ? { "ap-northeast-3" = module.ap_northeast_3[0].datadog_connection_arn } : {}),
    (length(module.ca_central_1) > 0 ? { "ca-central-1" = module.ca_central_1[0].datadog_connection_arn } : {}),
    (length(module.ca_west_1) > 0 ? { "ca-west-1" = module.ca_west_1[0].datadog_connection_arn } : {}),
    (length(module.eu_central_1) > 0 ? { "eu-central-1" = module.eu_central_1[0].datadog_connection_arn } : {}),
    (length(module.eu_central_2) > 0 ? { "eu-central-2" = module.eu_central_2[0].datadog_connection_arn } : {}),
    (length(module.eu_west_1) > 0 ? { "eu-west-1" = module.eu_west_1[0].datadog_connection_arn } : {}),
    (length(module.eu_west_2) > 0 ? { "eu-west-2" = module.eu_west_2[0].datadog_connection_arn } : {}),
    (length(module.eu_west_3) > 0 ? { "eu-west-3" = module.eu_west_3[0].datadog_connection_arn } : {}),
    (length(module.eu_north_1) > 0 ? { "eu-north-1" = module.eu_north_1[0].datadog_connection_arn } : {}),
    (length(module.eu_south_1) > 0 ? { "eu-south-1" = module.eu_south_1[0].datadog_connection_arn } : {}),
    (length(module.eu_south_2) > 0 ? { "eu-south-2" = module.eu_south_2[0].datadog_connection_arn } : {}),
    (length(module.il_central_1) > 0 ? { "il-central-1" = module.il_central_1[0].datadog_connection_arn } : {}),
    (length(module.me_central_1) > 0 ? { "me-central-1" = module.me_central_1[0].datadog_connection_arn } : {}),
    (length(module.me_south_1) > 0 ? { "me-south-1" = module.me_south_1[0].datadog_connection_arn } : {}),
    (length(module.mx_central_1) > 0 ? { "mx-central-1" = module.mx_central_1[0].datadog_connection_arn } : {}),
    (length(module.sa_east_1) > 0 ? { "sa-east-1" = module.sa_east_1[0].datadog_connection_arn } : {})
  )
}

output "datadog_api_destination_arns" {
  description = "Map of AWS region to the ARN of the EventBridge API destination for Datadog in that region."
  value = merge(
    (length(module.us_east_1) > 0 ? { "us-east-1" = module.us_east_1[0].datadog_api_destination_arn } : {}),
    (length(module.us_east_2) > 0 ? { "us-east-2" = module.us_east_2[0].datadog_api_destination_arn } : {}),
    (length(module.us_west_1) > 0 ? { "us-west-1" = module.us_west_1[0].datadog_api_destination_arn } : {}),
    (length(module.us_west_2) > 0 ? { "us-west-2" = module.us_west_2[0].datadog_api_destination_arn } : {}),
    (length(module.af_south_1) > 0 ? { "af-south-1" = module.af_south_1[0].datadog_api_destination_arn } : {}),
    (length(module.ap_east_1) > 0 ? { "ap-east-1" = module.ap_east_1[0].datadog_api_destination_arn } : {}),
    (length(module.ap_south_1) > 0 ? { "ap-south-1" = module.ap_south_1[0].datadog_api_destination_arn } : {}),
    (length(module.ap_south_2) > 0 ? { "ap-south-2" = module.ap_south_2[0].datadog_api_destination_arn } : {}),
    (length(module.ap_southeast_1) > 0 ? { "ap-southeast-1" = module.ap_southeast_1[0].datadog_api_destination_arn } : {}),
    (length(module.ap_southeast_2) > 0 ? { "ap-southeast-2" = module.ap_southeast_2[0].datadog_api_destination_arn } : {}),
    (length(module.ap_southeast_3) > 0 ? { "ap-southeast-3" = module.ap_southeast_3[0].datadog_api_destination_arn } : {}),
    (length(module.ap_southeast_4) > 0 ? { "ap-southeast-4" = module.ap_southeast_4[0].datadog_api_destination_arn } : {}),
    (length(module.ap_southeast_5) > 0 ? { "ap-southeast-5" = module.ap_southeast_5[0].datadog_api_destination_arn } : {}),
    (length(module.ap_southeast_7) > 0 ? { "ap-southeast-7" = module.ap_southeast_7[0].datadog_api_destination_arn } : {}),
    (length(module.ap_northeast_1) > 0 ? { "ap-northeast-1" = module.ap_northeast_1[0].datadog_api_destination_arn } : {}),
    (length(module.ap_northeast_2) > 0 ? { "ap-northeast-2" = module.ap_northeast_2[0].datadog_api_destination_arn } : {}),
    (length(module.ap_northeast_3) > 0 ? { "ap-northeast-3" = module.ap_northeast_3[0].datadog_api_destination_arn } : {}),
    (length(module.ca_central_1) > 0 ? { "ca-central-1" = module.ca_central_1[0].datadog_api_destination_arn } : {}),
    (length(module.ca_west_1) > 0 ? { "ca-west-1" = module.ca_west_1[0].datadog_api_destination_arn } : {}),
    (length(module.eu_central_1) > 0 ? { "eu-central-1" = module.eu_central_1[0].datadog_api_destination_arn } : {}),
    (length(module.eu_central_2) > 0 ? { "eu-central-2" = module.eu_central_2[0].datadog_api_destination_arn } : {}),
    (length(module.eu_west_1) > 0 ? { "eu-west-1" = module.eu_west_1[0].datadog_api_destination_arn } : {}),
    (length(module.eu_west_2) > 0 ? { "eu-west-2" = module.eu_west_2[0].datadog_api_destination_arn } : {}),
    (length(module.eu_west_3) > 0 ? { "eu-west-3" = module.eu_west_3[0].datadog_api_destination_arn } : {}),
    (length(module.eu_north_1) > 0 ? { "eu-north-1" = module.eu_north_1[0].datadog_api_destination_arn } : {}),
    (length(module.eu_south_1) > 0 ? { "eu-south-1" = module.eu_south_1[0].datadog_api_destination_arn } : {}),
    (length(module.eu_south_2) > 0 ? { "eu-south-2" = module.eu_south_2[0].datadog_api_destination_arn } : {}),
    (length(module.il_central_1) > 0 ? { "il-central-1" = module.il_central_1[0].datadog_api_destination_arn } : {}),
    (length(module.me_central_1) > 0 ? { "me-central-1" = module.me_central_1[0].datadog_api_destination_arn } : {}),
    (length(module.me_south_1) > 0 ? { "me-south-1" = module.me_south_1[0].datadog_api_destination_arn } : {}),
    (length(module.mx_central_1) > 0 ? { "mx-central-1" = module.mx_central_1[0].datadog_api_destination_arn } : {}),
    (length(module.sa_east_1) > 0 ? { "sa-east-1" = module.sa_east_1[0].datadog_api_destination_arn } : {})
  )
}

output "guardduty_to_datadog_rule_arns" {
  description = "Map of AWS region to the ARN of the EventBridge rule that routes GuardDuty findings to Datadog in that region."
  value = merge(
    (length(module.us_east_1) > 0 ? { "us-east-1" = module.us_east_1[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.us_east_2) > 0 ? { "us-east-2" = module.us_east_2[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.us_west_1) > 0 ? { "us-west-1" = module.us_west_1[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.us_west_2) > 0 ? { "us-west-2" = module.us_west_2[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.af_south_1) > 0 ? { "af-south-1" = module.af_south_1[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.ap_east_1) > 0 ? { "ap-east-1" = module.ap_east_1[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.ap_south_1) > 0 ? { "ap-south-1" = module.ap_south_1[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.ap_south_2) > 0 ? { "ap-south-2" = module.ap_south_2[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.ap_southeast_1) > 0 ? { "ap-southeast-1" = module.ap_southeast_1[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.ap_southeast_2) > 0 ? { "ap-southeast-2" = module.ap_southeast_2[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.ap_southeast_3) > 0 ? { "ap-southeast-3" = module.ap_southeast_3[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.ap_southeast_4) > 0 ? { "ap-southeast-4" = module.ap_southeast_4[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.ap_southeast_5) > 0 ? { "ap-southeast-5" = module.ap_southeast_5[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.ap_southeast_7) > 0 ? { "ap-southeast-7" = module.ap_southeast_7[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.ap_northeast_1) > 0 ? { "ap-northeast-1" = module.ap_northeast_1[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.ap_northeast_2) > 0 ? { "ap-northeast-2" = module.ap_northeast_2[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.ap_northeast_3) > 0 ? { "ap-northeast-3" = module.ap_northeast_3[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.ca_central_1) > 0 ? { "ca-central-1" = module.ca_central_1[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.ca_west_1) > 0 ? { "ca-west-1" = module.ca_west_1[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.eu_central_1) > 0 ? { "eu-central-1" = module.eu_central_1[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.eu_central_2) > 0 ? { "eu-central-2" = module.eu_central_2[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.eu_west_1) > 0 ? { "eu-west-1" = module.eu_west_1[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.eu_west_2) > 0 ? { "eu-west-2" = module.eu_west_2[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.eu_west_3) > 0 ? { "eu-west-3" = module.eu_west_3[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.eu_north_1) > 0 ? { "eu-north-1" = module.eu_north_1[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.eu_south_1) > 0 ? { "eu-south-1" = module.eu_south_1[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.eu_south_2) > 0 ? { "eu-south-2" = module.eu_south_2[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.il_central_1) > 0 ? { "il-central-1" = module.il_central_1[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.me_central_1) > 0 ? { "me-central-1" = module.me_central_1[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.me_south_1) > 0 ? { "me-south-1" = module.me_south_1[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.mx_central_1) > 0 ? { "mx-central-1" = module.mx_central_1[0].guardduty_to_datadog_rule_arn } : {}),
    (length(module.sa_east_1) > 0 ? { "sa-east-1" = module.sa_east_1[0].guardduty_to_datadog_rule_arn } : {})
  )
}

output "dlq_arns" {
  description = "Map of AWS region to the ARN of that region's SQS dead-letter queue. Alarm on each queue's ApproximateNumberOfMessagesVisible metric to detect a broken delivery pipeline in that region."
  value = merge(
    (length(module.us_east_1) > 0 ? { "us-east-1" = module.us_east_1[0].dlq_arn } : {}),
    (length(module.us_east_2) > 0 ? { "us-east-2" = module.us_east_2[0].dlq_arn } : {}),
    (length(module.us_west_1) > 0 ? { "us-west-1" = module.us_west_1[0].dlq_arn } : {}),
    (length(module.us_west_2) > 0 ? { "us-west-2" = module.us_west_2[0].dlq_arn } : {}),
    (length(module.af_south_1) > 0 ? { "af-south-1" = module.af_south_1[0].dlq_arn } : {}),
    (length(module.ap_east_1) > 0 ? { "ap-east-1" = module.ap_east_1[0].dlq_arn } : {}),
    (length(module.ap_south_1) > 0 ? { "ap-south-1" = module.ap_south_1[0].dlq_arn } : {}),
    (length(module.ap_south_2) > 0 ? { "ap-south-2" = module.ap_south_2[0].dlq_arn } : {}),
    (length(module.ap_southeast_1) > 0 ? { "ap-southeast-1" = module.ap_southeast_1[0].dlq_arn } : {}),
    (length(module.ap_southeast_2) > 0 ? { "ap-southeast-2" = module.ap_southeast_2[0].dlq_arn } : {}),
    (length(module.ap_southeast_3) > 0 ? { "ap-southeast-3" = module.ap_southeast_3[0].dlq_arn } : {}),
    (length(module.ap_southeast_4) > 0 ? { "ap-southeast-4" = module.ap_southeast_4[0].dlq_arn } : {}),
    (length(module.ap_southeast_5) > 0 ? { "ap-southeast-5" = module.ap_southeast_5[0].dlq_arn } : {}),
    (length(module.ap_southeast_7) > 0 ? { "ap-southeast-7" = module.ap_southeast_7[0].dlq_arn } : {}),
    (length(module.ap_northeast_1) > 0 ? { "ap-northeast-1" = module.ap_northeast_1[0].dlq_arn } : {}),
    (length(module.ap_northeast_2) > 0 ? { "ap-northeast-2" = module.ap_northeast_2[0].dlq_arn } : {}),
    (length(module.ap_northeast_3) > 0 ? { "ap-northeast-3" = module.ap_northeast_3[0].dlq_arn } : {}),
    (length(module.ca_central_1) > 0 ? { "ca-central-1" = module.ca_central_1[0].dlq_arn } : {}),
    (length(module.ca_west_1) > 0 ? { "ca-west-1" = module.ca_west_1[0].dlq_arn } : {}),
    (length(module.eu_central_1) > 0 ? { "eu-central-1" = module.eu_central_1[0].dlq_arn } : {}),
    (length(module.eu_central_2) > 0 ? { "eu-central-2" = module.eu_central_2[0].dlq_arn } : {}),
    (length(module.eu_west_1) > 0 ? { "eu-west-1" = module.eu_west_1[0].dlq_arn } : {}),
    (length(module.eu_west_2) > 0 ? { "eu-west-2" = module.eu_west_2[0].dlq_arn } : {}),
    (length(module.eu_west_3) > 0 ? { "eu-west-3" = module.eu_west_3[0].dlq_arn } : {}),
    (length(module.eu_north_1) > 0 ? { "eu-north-1" = module.eu_north_1[0].dlq_arn } : {}),
    (length(module.eu_south_1) > 0 ? { "eu-south-1" = module.eu_south_1[0].dlq_arn } : {}),
    (length(module.eu_south_2) > 0 ? { "eu-south-2" = module.eu_south_2[0].dlq_arn } : {}),
    (length(module.il_central_1) > 0 ? { "il-central-1" = module.il_central_1[0].dlq_arn } : {}),
    (length(module.me_central_1) > 0 ? { "me-central-1" = module.me_central_1[0].dlq_arn } : {}),
    (length(module.me_south_1) > 0 ? { "me-south-1" = module.me_south_1[0].dlq_arn } : {}),
    (length(module.mx_central_1) > 0 ? { "mx-central-1" = module.mx_central_1[0].dlq_arn } : {}),
    (length(module.sa_east_1) > 0 ? { "sa-east-1" = module.sa_east_1[0].dlq_arn } : {})
  )
}

