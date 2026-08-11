# ── IAM policy: read-only access to exactly the secrets ESO is allowed to sync ─
#
# Deliberately scoped to var.secret_arns rather than "secretsmanager:*" or a
# wildcard resource - the operator's ServiceAccount is the single bridge
# between the cluster and Secrets Manager, so its IAM role is the highest-
# value target to keep minimal (same least-privilege posture as the S3
# policy already reused from the ECS stack for module.irsa_backend).

data "aws_iam_policy_document" "secrets_read" {
  statement {
    sid    = "ReadScopedSecrets"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = var.secret_arns
  }
}

resource "aws_iam_policy" "secrets_read" {
  name        = "${var.project_name}-${var.environment}-eso-secrets-read"
  description = "Read-only access to the JWT and RDS credentials secrets, for the External Secrets Operator ServiceAccount"
  policy      = data.aws_iam_policy_document.secrets_read.json
  tags        = var.tags
}

# ── IRSA role for the operator's own ServiceAccount ─────────────────────────────
#
# Only the controller's ServiceAccount needs AWS permissions (ClusterSecretStore
# pattern) - individual app ServiceAccounts (backend/frontend) never touch
# Secrets Manager directly, they only ever read the plain Kubernetes Secret
# that ESO materializes for them.

module "irsa" {
  source = "../irsa-role"

  role_name            = "${var.project_name}-${var.environment}-external-secrets"
  namespace            = var.namespace
  service_account_name = "external-secrets"

  oidc_provider_arn = var.oidc_provider_arn
  oidc_provider_url = var.oidc_provider_url

  policy_arns = [aws_iam_policy.secrets_read.arn]

  tags = var.tags
}

# ── External Secrets Operator (Helm) ─────────────────────────────────────────────
#
# installCRDs=true bootstraps SecretStore/ClusterSecretStore/ExternalSecret
# CRDs alongside the controller - required since manifests depend on
# them existing before they can be applied.

resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "external-secrets"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.irsa.role_arn
  }

  depends_on = [module.irsa]
}