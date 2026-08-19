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

# aws_cloudwatch_event_connection has no argument to reference an existing Secrets
# Manager secret directly — it only accepts a plaintext value and creates its own
# AWS-managed secret behind the scenes. So the operator workflow is: Terraform seeds
# this secret with a placeholder, the operator overwrites it with the real Datadog API
# key, and a subsequent `terraform apply` reads the updated value and pushes it into
# the connection. Updating the secret alone does not rotate the live connection.
resource "aws_secretsmanager_secret" "datadog_api_key" {
  name        = "datadog-api-key"
  description = "Datadog API key for the GuardDuty-to-Datadog EventBridge connection. Replace the placeholder value after creation, then re-run terraform apply to push it into the connection."
}

resource "aws_secretsmanager_secret_version" "datadog_api_key" {
  secret_id                = aws_secretsmanager_secret.datadog_api_key.id
  secret_string_wo         = "REPLACE_ME"
  secret_string_wo_version = 1
}

data "aws_secretsmanager_secret_version" "datadog_api_key" {
  secret_id  = aws_secretsmanager_secret.datadog_api_key.id
  depends_on = [aws_secretsmanager_secret_version.datadog_api_key]
}

resource "aws_cloudwatch_event_connection" "datadog" {
  name               = "datadog"
  description        = "Datadog API Connection"
  authorization_type = "API_KEY"

  auth_parameters {
    api_key {
      key = "DD-API-KEY"
      # Wrapped in sensitive() as defense in depth: the Secrets Manager data source's
      # secret_string attribute is not documented as sensitive, unlike a variable
      # declared with sensitive = true.
      value = sensitive(data.aws_secretsmanager_secret_version.datadog_api_key.secret_string)
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
