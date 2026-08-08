module "eks" {
  source = "../../_modules/eks"

  project_name       = var.project_name
  environment        = var.environment
  kubernetes_version = var.kubernetes_version

  vpc_id = data.terraform_remote_state.staging.outputs.vpc_id
  subnet_ids = concat(
    data.terraform_remote_state.staging.outputs.private_subnet_ids,
    data.terraform_remote_state.staging.outputs.public_subnet_ids,
  )
  private_subnet_ids = data.terraform_remote_state.staging.outputs.private_subnet_ids

  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  node_instance_types = var.node_instance_types
  node_capacity_type  = var.node_capacity_type

  tags = local.common_tags
}