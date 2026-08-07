locals {
  cluster_name = "${var.project_name}-${var.environment}"
}

# ── IAM role assumed by the EKS control plane itself ─────────────────────────

data "aws_iam_policy_document" "cluster_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cluster" {
  name               = "${local.cluster_name}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# ── Optional envelope encryption of K8s Secrets ───────────────────────────────

resource "aws_kms_key" "eks_secrets" {
  count                   = var.enable_secrets_encryption ? 1 : 0
  description             = "Envelope encryption key for ${local.cluster_name} EKS Secrets"
  deletion_window_in_days = 0
  tags                    = var.tags
}

resource "aws_kms_alias" "eks_secrets" {
  count         = var.enable_secrets_encryption ? 1 : 0
  name          = "alias/${local.cluster_name}-eks-secrets"
  target_key_id = aws_kms_key.eks_secrets[0].key_id
}

# The KMS key above uses AWS's default key policy (root account access + IAM-managed
# permissions) - the standard, low-friction pattern for keys with a single or evolving
# set of consumers, consistent with attaching AmazonEKSClusterPolicy above rather than
# writing a custom resource policy.
#
# But that default policy alone is NOT enough: at cluster creation, EKS calls
# kms:CreateGrant / DescribeKey / Encrypt / Decrypt USING THE CLUSTER'S OWN IAM ROLE.
# Without an explicit IAM policy granting those actions on this key, aws_eks_cluster.this
# fails during apply at the encryption_config step with a KMS access-denied error - not a
# Terraform-side error, an API-level rejection surfaced only at apply time, same category
# as incident #1 in docs/incidents.md (RDS FreeTierRestrictionError).
data "aws_iam_policy_document" "cluster_kms" {
  count = var.enable_secrets_encryption ? 1 : 0

  statement {
    sid = "AllowClusterRoleToUseSecretsKey"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:CreateGrant",
    ]
    resources = [aws_kms_key.eks_secrets[0].arn]
  }
}

resource "aws_iam_role_policy" "cluster_kms" {
  count  = var.enable_secrets_encryption ? 1 : 0
  name   = "${local.cluster_name}-eks-secrets-kms"
  role   = aws_iam_role.cluster.id
  policy = data.aws_iam_policy_document.cluster_kms[0].json
}

# ── Control plane log group (created explicitly so retention is enforced;      ─
#    EKS auto-creates it with "never expire" retention otherwise)             ──

resource "aws_cloudwatch_log_group" "cluster" {
  name              = "/aws/eks/${local.cluster_name}/cluster"
  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}

# ── EKS cluster (control plane) ───────────────────────────────────────────────

resource "aws_eks_cluster" "this" {
  name     = local.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.endpoint_public_access_cidrs
  }

  enabled_cluster_log_types = var.enabled_cluster_log_types

  dynamic "encryption_config" {
    for_each = var.enable_secrets_encryption ? [1] : []
    content {
      provider {
        key_arn = aws_kms_key.eks_secrets[0].arn
      }
      resources = ["secrets"]
    }
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
    aws_iam_role_policy.cluster_kms,
    aws_cloudwatch_log_group.cluster,
  ]
}

# ── OIDC provider — prerequisite for IRSA ──────────────────────────────
# Every EKS cluster exposes an OIDC issuer; registering it as an
# aws_iam_openid_connect_provider is what lets IAM roles trust individual
# Kubernetes ServiceAccounts (IRSA) instead of granting AWS permissions to
# entire worker nodes.

data "tls_certificate" "eks" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = data.tls_certificate.eks.certificates[*].sha1_fingerprint
  tags            = var.tags
}