module "rds" {
  source = "../../_modules/rds"

  environment           = var.environment
  project_name          = var.project_name
  private_subnet_ids    = module.vpc.private_subnet_ids
  rds_security_group_id = module.vpc.rds_security_group_id
  db_name               = var.db_name
  db_username           = var.db_username
  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  multi_az              = var.db_multi_az
  skip_final_snapshot   = var.db_skip_final_snapshot
  deletion_protection   = var.db_deletion_protection
  tags                  = local.common_tags
}

module "cloudwatch" {
  source = "../../_modules/cloudwatch"

  environment            = var.environment
  project_name           = var.project_name
  aws_region             = var.aws_region
  alert_email            = var.alert_email
  ecs_cluster_name       = local.ecs_cluster_name
  backend_service_name   = local.backend_service_name
  frontend_service_name  = local.frontend_service_name
  cpu_alarm_threshold    = var.cpu_alarm_threshold
  memory_alarm_threshold = var.memory_alarm_threshold
  tags                   = local.common_tags
}

module "vpc" {
  source = "../../_modules/vpc"

  environment             = var.environment
  project_name            = var.project_name
  vpc_cidr                = var.vpc_cidr
  azs                     = var.azs
  public_subnet_cidrs     = var.public_subnet_cidrs
  private_subnet_cidrs    = var.private_subnet_cidrs
  backend_container_port  = var.backend_container_port
  frontend_container_port = var.frontend_container_port
  eks_ready               = var.eks_ready
  tags                    = local.common_tags
}