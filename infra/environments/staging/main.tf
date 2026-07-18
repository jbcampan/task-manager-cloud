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