output "alb_dns_name" {
  description = "Dev ALB DNS name."
  value       = module.ecs.alb_dns_name
}

output "rds_endpoint" {
  description = "Dev RDS endpoint."
  value       = module.rds.db_endpoint
  sensitive   = true
}
