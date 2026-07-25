terraform {
  required_version = ">= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  # These ARNs are built from the naming convention shared with the ECS
  # module - the resources do not exist yet, but IAM allows
  # referencing an ARN before the resource behind it is created.
  cluster_arn          = "arn:aws:ecs:${local.region}:${local.account_id}:cluster/${var.ecs_cluster_name}"
  backend_service_arn  = "arn:aws:ecs:${local.region}:${local.account_id}:service/${var.ecs_cluster_name}/${var.backend_service_name}"
  frontend_service_arn = "arn:aws:ecs:${local.region}:${local.account_id}:service/${var.ecs_cluster_name}/${var.frontend_service_name}"

  # Family-scoped, all revisions - RunTask needs the task definition ARN,
  # not the family name, and the CD workflow registers a fresh revision
  # on every deploy.
  backend_task_def_arn = "arn:aws:ecs:${local.region}:${local.account_id}:task-definition/${var.project_name}-${var.environment}-backend:*"

  # Task ARNs are only known once RunTask has already run, so this scopes
  # DescribeTasks/StopTask to "any task in this cluster" rather than "*".
  cluster_task_arn = "arn:aws:ecs:${local.region}:${local.account_id}:task/${var.ecs_cluster_name}/*"

  ecs_execution_role_arn = "arn:aws:iam::${local.account_id}:role/${var.project_name}-${var.environment}-ecs-execution"
  ecs_task_role_arn      = "arn:aws:iam::${local.account_id}:role/${var.project_name}-${var.environment}-ecs-task"
}

# -----------------------------------------------------------------
# Trust policy - only a workflow job that declares
# `environment: ${var.github_environment}` in GitHub Actions can assume
# this role. This is what makes manual approval gates possible:
# GitHub blocks the job from even requesting a token until the gate
# protecting that Environment is cleared.
# -----------------------------------------------------------------
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
  name               = "${var.project_name}-${var.environment}-github-deploy"
  assume_role_policy = data.aws_iam_policy_document.deploy_assume_role.json
  tags               = var.tags
}

# -----------------------------------------------------------------
# Permissions - scoped to this environment's cluster/services only,
# never wildcarded across environments.
# -----------------------------------------------------------------
data "aws_iam_policy_document" "deploy_permissions" {
  statement {
    sid    = "EcsServiceUpdates"
    effect = "Allow"
    actions = [
      "ecs:UpdateService",
      "ecs:DescribeServices",
    ]
    resources = [
      local.backend_service_arn,
      local.frontend_service_arn,
    ]
  }

  statement {
    sid    = "EcsTaskDefinitions"
    effect = "Allow"
    actions = [
      "ecs:RegisterTaskDefinition",
      "ecs:DeregisterTaskDefinition",
      "ecs:DescribeTaskDefinition",
    ]
    # AWS does not support resource-level scoping for these three actions,
    # "*" is required here regardless of how narrow the rest of the policy is.
    resources = ["*"]
  }

  # ---------------------------------------------------------------
  # One-off migration task (Prisma "migrate deploy"), run via
  # "aws ecs run-task" before the backend service is updated.
  # Scoped to the backend task definition family and gated to this
  # cluster only via the ecs:cluster condition key.
  # ---------------------------------------------------------------
  statement {
    sid    = "EcsRunMigrationTask"
    effect = "Allow"
    actions = [
      "ecs:RunTask",
    ]
    resources = [local.backend_task_def_arn]

    condition {
      test     = "ArnEquals"
      variable = "ecs:cluster"
      values   = [local.cluster_arn]
    }
  }

  statement {
    sid    = "EcsMonitorMigrationTask"
    effect = "Allow"
    actions = [
      "ecs:DescribeTasks",
      "ecs:StopTask",
    ]
    resources = [local.cluster_task_arn]
  }

  statement {
    sid     = "PassEcsRoles"
    effect  = "Allow"
    actions = ["iam:PassRole"]
    resources = [
      local.ecs_execution_role_arn,
      local.ecs_task_role_arn,
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "deploy" {
  name   = "deploy-permissions"
  role   = aws_iam_role.deploy.id
  policy = data.aws_iam_policy_document.deploy_permissions.json
}
