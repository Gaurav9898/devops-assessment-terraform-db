module "network" {
  source = "../../modules/network"

  project_name         = var.project_name
  environment          = "dev"
  vpc_cidr             = "10.10.0.0/16"
  availability_zones   = ["${var.aws_region}a", "${var.aws_region}b"]
  public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnet_cidrs = ["10.10.11.0/24", "10.10.12.0/24"]
  enable_nat_gateway   = true
}

module "ecs" {
  source = "../../modules/ecs"

  project_name       = var.project_name
  environment        = "dev"
  aws_region         = var.aws_region
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  task_cpu           = 256
  task_memory        = 512
  desired_count      = 1
}

module "rds" {
  source = "../../modules/rds"

  project_name            = var.project_name
  environment             = "dev"
  vpc_id                  = module.network.vpc_id
  private_subnet_ids      = module.network.private_subnet_ids
  ecs_security_group_id   = module.ecs.ecs_security_group_id
  db_name                 = "hotelapp"
  db_username             = "hotel_admin"
  db_password             = var.db_password
  instance_class          = "db.t4g.micro"
  allocated_storage       = 20
  backup_retention_period = 3
  deletion_protection     = false
  multi_az                = false
  skip_final_snapshot     = true
}
