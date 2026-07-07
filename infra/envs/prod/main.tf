module "network" {
  source = "../../modules/network"

  project_name         = var.project_name
  environment          = "prod"
  vpc_cidr             = "10.20.0.0/16"
  availability_zones   = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnet_cidrs  = ["10.20.1.0/24", "10.20.2.0/24"]
  private_subnet_cidrs = ["10.20.11.0/24", "10.20.12.0/24"]
  enable_nat_gateway   = true
}

module "ecs" {
  source = "../../modules/ecs"

  project_name       = var.project_name
  environment        = "prod"
  aws_region         = var.aws_region
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  task_cpu           = 512
  task_memory        = 1024
  desired_count      = 2
}

module "rds" {
  source = "../../modules/rds"

  project_name            = var.project_name
  environment             = "prod"
  vpc_id                  = module.network.vpc_id
  private_subnet_ids      = module.network.private_subnet_ids
  ecs_security_group_id   = module.ecs.ecs_security_group_id
  db_name                 = "hotelapp"
  db_username             = "hotel_admin"
  db_password             = var.db_password
  instance_class          = "db.t4g.small"
  allocated_storage       = 50
  backup_retention_period = 14
  deletion_protection     = true
  multi_az                = true
  skip_final_snapshot     = false
}
