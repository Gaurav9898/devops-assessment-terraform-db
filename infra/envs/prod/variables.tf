variable "aws_region" {
  description = "AWS region for the environment."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
  default     = "hotel-platform"
}

variable "db_password" {
  description = "Plan-only placeholder password. Use a secret source for real deployments."
  type        = string
  sensitive   = true
  default     = "change-me-prod-plan-only-123"
}

variable "use_mock_aws_credentials" {
  description = "Use mock provider credentials for local plan-only review. Set false to use the normal AWS credential chain."
  type        = bool
  default     = true
}
