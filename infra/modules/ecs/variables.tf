variable "project_name" {
  description = "Project name used for resource naming."
  type        = string
}

variable "environment" {
  description = "Environment name, such as dev or prod."
  type        = string
}

variable "aws_region" {
  description = "AWS region used for CloudWatch log configuration."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS tasks."
  type        = list(string)
}

variable "container_image" {
  description = "Container image for the placeholder application."
  type        = string
  default     = "nginx:1.27-alpine"
}

variable "container_port" {
  description = "Container port exposed by the application."
  type        = number
  default     = 80
}

variable "task_cpu" {
  description = "Fargate task CPU units."
  type        = number
}

variable "task_memory" {
  description = "Fargate task memory in MiB."
  type        = number
}

variable "desired_count" {
  description = "Desired ECS service task count."
  type        = number
}

variable "certificate_arn" {
  description = "Optional ACM certificate ARN. When set, the ALB creates an HTTPS listener and redirects HTTP to HTTPS."
  type        = string
  default     = ""
}
