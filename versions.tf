terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.43.0"
    }
    datadog = {
      source  = "DataDog/datadog"
      version = ">= 3.0.0"
    }
  }
}
