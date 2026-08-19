terraform {
  # >= 1.11.0 for write-only attribute support (secret_string_wo in datadog.tf).
  required_version = ">= 1.11.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
