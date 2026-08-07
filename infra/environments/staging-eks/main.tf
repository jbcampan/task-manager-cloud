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

  tags = local.common_tags
}