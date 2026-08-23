# Same mechanism as _modules/iam-github-deploy (ECS) - only a workflow job
# that declares `environment: staging-eks` in GitHub Actions can assume
# this role. AWS-side permissions here are deliberately minimal
# (eks:DescribeCluster only) - actual Kubernetes-level authorization is
# handled separately below, by an EKS Access Entry, not by IAM.
data "aws_iam_policy_document" "deploy_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repository}:environment:${var.github_environment}"]
    }
  }
}

resource "aws_iam_role" "deploy" {
  name               = "${var.project_name}-${var.environment}-github-deploy-eks"
  assume_role_policy = data.aws_iam_policy_document.deploy_assume_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "deploy_permissions" {
  statement {
    sid       = "EksDescribeCluster"
    effect    = "Allow"
    actions   = ["eks:DescribeCluster"]
    resources = [var.cluster_arn]
  }
}

resource "aws_iam_role_policy" "deploy" {
  name   = "deploy-permissions"
  role   = aws_iam_role.deploy.id
  policy = data.aws_iam_policy_document.deploy_permissions.json
}