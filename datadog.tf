# Datadog's Logs intake endpoint is https://http-intake.logs.<site domain>/api/v2/logs,
# and the site domain is not always <lowercase site>.datadoghq.com (EU and the FedRAMP
# sites use distinct top-level domains), so the site name is mapped explicitly rather
# than derived by string interpolation.
locals {
  datadog_site_domains = {
    "US1"     = "datadoghq.com"
    "US3"     = "us3.datadoghq.com"
    "US5"     = "us5.datadoghq.com"
    "EU"      = "datadoghq.eu"
    "AP1"     = "ap1.datadoghq.com"
    "AP2"     = "ap2.datadoghq.com"
    "UK1"     = "uk1.datadoghq.com"
    "US1-FED" = "ddog-gov.com"
    "US2-FED" = "us2.ddog-gov.com"
  }

  datadog_api_destination_endpoint = "https://http-intake.logs.${local.datadog_site_domains[var.datadog_site]}/api/v2/logs"
}

# aws_cloudwatch_event_connection has no write-only or ephemeral variant for
# auth_parameters, and no argument to reference an existing Secrets Manager secret —
# it only accepts a plaintext value, which AWS then stores in its own managed secret.
# The plaintext is therefore unavoidably persisted in Terraform state; supply
# var.datadog_api_key via TF_VAR_datadog_api_key or an untracked .tfvars file and
# protect state per this project's state-security controls.
resource "aws_cloudwatch_event_connection" "datadog" {
  name               = "datadog"
  description        = "Datadog API Connection"
  authorization_type = "API_KEY"

  auth_parameters {
    api_key {
      key   = "DD-API-KEY"
      value = var.datadog_api_key
    }
  }
}

resource "aws_cloudwatch_event_api_destination" "datadog" {
  name                             = "datadog-api-destination"
  description                      = "Datadog API Destination"
  invocation_endpoint              = local.datadog_api_destination_endpoint
  http_method                      = "POST"
  connection_arn                   = aws_cloudwatch_event_connection.datadog.arn
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
}
