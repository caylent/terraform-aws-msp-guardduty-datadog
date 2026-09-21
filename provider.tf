provider "aws" {
  region = var.aws_region
}

# Configured even when datadog_app_key is unset, since a provider block's
# arguments can't be conditional. validate = false skips this provider's own
# eager credential check at plan time, since a caller who never sets
# datadog_app_key never enables the monitor either; the datadog_monitor
# resource itself still calls the real API and fails there if credentials
# are actually missing or wrong once the monitor is enabled.
provider "datadog" {
  validate = false
  api_key  = var.datadog_api_key
  app_key  = var.datadog_app_key
}
