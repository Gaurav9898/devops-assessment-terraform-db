output "alb_dns_name" {
  description = "Prod ALB DNS name."
  value       = module.ecs.alb_dns_name
}

output "rds_endpoint" {
  description = "Prod RDS endpoint."
  value       = module.rds.db_endpoint
  sensitive   = true
}
