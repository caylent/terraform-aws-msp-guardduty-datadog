module "us_east_1" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.us_east_1
  }

  count = contains(var.regions, "us-east-1") ? 1 : 0

  aws_region                       = "us-east-1"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "us_east_2" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.us_east_2
  }

  count = contains(var.regions, "us-east-2") ? 1 : 0

  aws_region                       = "us-east-2"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "us_west_1" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.us_west_1
  }

  count = contains(var.regions, "us-west-1") ? 1 : 0

  aws_region                       = "us-west-1"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "us_west_2" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.us_west_2
  }

  count = contains(var.regions, "us-west-2") ? 1 : 0

  aws_region                       = "us-west-2"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "af_south_1" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.af_south_1
  }

  count = contains(var.regions, "af-south-1") ? 1 : 0

  aws_region                       = "af-south-1"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "ap_east_1" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.ap_east_1
  }

  count = contains(var.regions, "ap-east-1") ? 1 : 0

  aws_region                       = "ap-east-1"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "ap_east_2" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.ap_east_2
  }

  count = contains(var.regions, "ap-east-2") ? 1 : 0

  aws_region                       = "ap-east-2"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "ap_south_1" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.ap_south_1
  }

  count = contains(var.regions, "ap-south-1") ? 1 : 0

  aws_region                       = "ap-south-1"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "ap_south_2" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.ap_south_2
  }

  count = contains(var.regions, "ap-south-2") ? 1 : 0

  aws_region                       = "ap-south-2"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "ap_southeast_1" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.ap_southeast_1
  }

  count = contains(var.regions, "ap-southeast-1") ? 1 : 0

  aws_region                       = "ap-southeast-1"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "ap_southeast_2" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.ap_southeast_2
  }

  count = contains(var.regions, "ap-southeast-2") ? 1 : 0

  aws_region                       = "ap-southeast-2"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "ap_southeast_3" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.ap_southeast_3
  }

  count = contains(var.regions, "ap-southeast-3") ? 1 : 0

  aws_region                       = "ap-southeast-3"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "ap_southeast_4" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.ap_southeast_4
  }

  count = contains(var.regions, "ap-southeast-4") ? 1 : 0

  aws_region                       = "ap-southeast-4"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "ap_southeast_5" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.ap_southeast_5
  }

  count = contains(var.regions, "ap-southeast-5") ? 1 : 0

  aws_region                       = "ap-southeast-5"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "ap_southeast_6" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.ap_southeast_6
  }

  count = contains(var.regions, "ap-southeast-6") ? 1 : 0

  aws_region                       = "ap-southeast-6"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "ap_southeast_7" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.ap_southeast_7
  }

  count = contains(var.regions, "ap-southeast-7") ? 1 : 0

  aws_region                       = "ap-southeast-7"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "ap_northeast_1" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.ap_northeast_1
  }

  count = contains(var.regions, "ap-northeast-1") ? 1 : 0

  aws_region                       = "ap-northeast-1"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "ap_northeast_2" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.ap_northeast_2
  }

  count = contains(var.regions, "ap-northeast-2") ? 1 : 0

  aws_region                       = "ap-northeast-2"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "ap_northeast_3" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.ap_northeast_3
  }

  count = contains(var.regions, "ap-northeast-3") ? 1 : 0

  aws_region                       = "ap-northeast-3"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "ca_central_1" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.ca_central_1
  }

  count = contains(var.regions, "ca-central-1") ? 1 : 0

  aws_region                       = "ca-central-1"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "ca_west_1" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.ca_west_1
  }

  count = contains(var.regions, "ca-west-1") ? 1 : 0

  aws_region                       = "ca-west-1"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "eu_central_1" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.eu_central_1
  }

  count = contains(var.regions, "eu-central-1") ? 1 : 0

  aws_region                       = "eu-central-1"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "eu_central_2" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.eu_central_2
  }

  count = contains(var.regions, "eu-central-2") ? 1 : 0

  aws_region                       = "eu-central-2"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "eu_west_1" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.eu_west_1
  }

  count = contains(var.regions, "eu-west-1") ? 1 : 0

  aws_region                       = "eu-west-1"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "eu_west_2" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.eu_west_2
  }

  count = contains(var.regions, "eu-west-2") ? 1 : 0

  aws_region                       = "eu-west-2"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "eu_west_3" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.eu_west_3
  }

  count = contains(var.regions, "eu-west-3") ? 1 : 0

  aws_region                       = "eu-west-3"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "eu_north_1" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.eu_north_1
  }

  count = contains(var.regions, "eu-north-1") ? 1 : 0

  aws_region                       = "eu-north-1"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "eu_south_1" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.eu_south_1
  }

  count = contains(var.regions, "eu-south-1") ? 1 : 0

  aws_region                       = "eu-south-1"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "eu_south_2" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.eu_south_2
  }

  count = contains(var.regions, "eu-south-2") ? 1 : 0

  aws_region                       = "eu-south-2"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "il_central_1" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.il_central_1
  }

  count = contains(var.regions, "il-central-1") ? 1 : 0

  aws_region                       = "il-central-1"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "me_central_1" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.me_central_1
  }

  count = contains(var.regions, "me-central-1") ? 1 : 0

  aws_region                       = "me-central-1"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "me_south_1" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.me_south_1
  }

  count = contains(var.regions, "me-south-1") ? 1 : 0

  aws_region                       = "me-south-1"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "mx_central_1" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.mx_central_1
  }

  count = contains(var.regions, "mx-central-1") ? 1 : 0

  aws_region                       = "mx-central-1"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

module "sa_east_1" {
  source = "./modules/msp-guardduty-datadog-single-region"

  providers = {
    aws = aws.sa_east_1
  }

  count = contains(var.regions, "sa-east-1") ? 1 : 0

  aws_region                       = "sa-east-1"
  eventbridge_role_arn             = aws_iam_role.eventbridge_invoke_datadog.arn
  datadog_api_key                  = var.datadog_api_key
  datadog_site                     = var.datadog_site
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  max_event_age_seconds            = var.max_event_age_seconds
  max_retry_attempts               = var.max_retry_attempts
}

