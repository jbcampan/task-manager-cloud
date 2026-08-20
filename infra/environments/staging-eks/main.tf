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

module "irsa_backend" {
  source = "../../_modules/irsa-role"

  role_name            = "${var.project_name}-${var.environment}-backend-sa"
  namespace            = "task-manager"
  service_account_name = "backend"

  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url

  # Reuses the managed policy already attached to the ECS task role (staging/S3
  # module) - the S3 access requirements for uploads are identical regardless
  # of the compute platform. Secrets Manager (JWT, RDS) is intentionally excluded
  # here - this depends on whether we use native Kubernetes Secrets or the
  # External Secrets Operator.

  policy_arns = [data.terraform_remote_state.staging.outputs.uploads_rw_policy_arn]

  tags = local.common_tags
}

module "alb_controller" {
  source = "../../_modules/alb-controller"

  cluster_name = module.eks.cluster_name
  aws_region   = var.aws_region
  vpc_id       = data.terraform_remote_state.staging.outputs.vpc_id

  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  chart_version     = "3.4.1" # controller v3.4.1 - verified with `helm search repo eks/aws-load-balancer-controller --versions`

  tags = local.common_tags

  # The controller requires the worker nodes and their networking 
  # to be fully operational before its own pod can be scheduled.
  depends_on = [module.eks]
}

module "external_secrets" {
  source = "../../_modules/external-secrets-operator"

  project_name = var.project_name
  environment  = var.environment

  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  chart_version     = "2.6.0" # verified with `helm search repo external-secrets/external-secrets --versions`

  # Both confirmed against the real staging/outputs.tf. jwt_secret_arn
  # required adding a new output at two levels (_modules/ecs/outputs.tf and
  # staging/outputs.tf) - it didn't exist before, see the M2.1 changelog.
  secret_arns = [
    data.terraform_remote_state.staging.outputs.jwt_secret_arn,
    data.terraform_remote_state.staging.outputs.master_user_secret_arn,
  ]

  tags = local.common_tags

  depends_on = [module.eks]
}

module "kube_prometheus_stack" {
  source = "../../_modules/kube-prometheus-stack"

  chart_version          = "88.3.0" # verified with `helm search repo prometheus-community/kube-prometheus-stack --versions`
  grafana_admin_password = var.grafana_admin_password

  # Same reasoning as alb_controller/external_secrets above - node group
  # and cluster networking must be ready before this (much larger) chart's
  # pods, including the node-exporter DaemonSet, can schedule.
  depends_on = [module.eks]
}