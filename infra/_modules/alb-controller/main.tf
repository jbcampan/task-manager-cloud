resource "aws_iam_policy" "alb_controller" {
  name = "${var.cluster_name}-alb-controller-policy"
  # Downloaded from the official source - see this module's README for the
  # exact command. Do not hand-edit; re-download when chart_version changes.
  policy = file("${path.module}/iam-policy.json")
  tags   = var.tags
}

module "irsa" {
  source = "../irsa-role"

  role_name            = "${var.cluster_name}-alb-controller"
  namespace            = "kube-system"
  service_account_name = "aws-load-balancer-controller"

  oidc_provider_arn = var.oidc_provider_arn
  oidc_provider_url = var.oidc_provider_url

  policy_arns = [aws_iam_policy.alb_controller.arn]

  tags = var.tags
}

# Created explicitly (rather than serviceAccount.create=true in the chart) so
# the eks.amazonaws.com/role-arn annotation is set by Terraform, in the same
# place the IAM role itself is defined - avoids a chart value and an IAM
# resource needing to be kept in sync by hand across two different tools.
resource "kubernetes_service_account" "alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.irsa.role_arn
    }
    labels = {
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
      "app.kubernetes.io/component" = "controller"
    }
  }
}

resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.chart_version
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  # The ServiceAccount is created above (not by the chart) so the IAM role
  # annotation stays defined next to the role itself.
  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.alb_controller.metadata[0].name
  }

  depends_on = [kubernetes_service_account.alb_controller]
}