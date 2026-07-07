terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = var.aws_region
  access_key                  = var.use_mock_aws_credentials ? "mock_access_key_for_plan_only" : null
  secret_key                  = var.use_mock_aws_credentials ? "mock_secret_key_for_plan_only" : null
  skip_credentials_validation = var.use_mock_aws_credentials
  skip_metadata_api_check     = var.use_mock_aws_credentials
  skip_region_validation      = var.use_mock_aws_credentials
  skip_requesting_account_id  = var.use_mock_aws_credentials
}
