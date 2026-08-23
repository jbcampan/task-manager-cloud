module "github_deploy_eks" {
  source = "../../_modules/iam-github-deploy-eks"

  project_name       = var.project_name
  environment        = var.environment
  github_repository  = var.github_repository
  github_environment = "staging-eks"

  oidc_provider_arn = data.terraform_remote_state.shared.outputs.oidc_provider_arn
  cluster_arn       = module.eks.cluster_arn

  tags = local.common_tags

  depends_on = [module.eks]
}

resource "aws_eks_access_entry" "github_deploy" {
  cluster_name  = module.eks.cluster_name
  principal_arn = module.github_deploy_eks.role_arn
  type          = "STANDARD"
}

# AmazonEKSEditPolicy mirrors the built-in "edit" ClusterRole (includes
# pods/portforward, needed by the ArgoCD sync step in
# deploy-eks-reusable.yml). Scoped per-namespace, never cluster-wide -
# this role never needs kube-system, monitoring, or ESO's namespace.
resource "aws_eks_access_policy_association" "github_deploy_task_manager" {
  cluster_name  = module.eks.cluster_name
  principal_arn = module.github_deploy_eks.role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"

  access_scope {
    type       = "namespace"
    namespaces = ["task-manager"]
  }
}

resource "aws_eks_access_policy_association" "github_deploy_argocd" {
  cluster_name  = module.eks.cluster_name
  principal_arn = module.github_deploy_eks.role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"

  access_scope {
    type       = "namespace"
    namespaces = ["argocd"]
  }
}