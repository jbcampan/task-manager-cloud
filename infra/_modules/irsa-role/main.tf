# Trust policy: only a token issued by THIS cluster's OIDC provider, for THIS
# specific namespace/ServiceAccount pair, can assume this role. This is the
# entire IRSA mechanism - no agent, no long-lived credentials on the node,
# just a scoped AssumeRoleWithWebIdentity trust relationship.
data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.service_account_name}"]
    }

    # Without this second condition, any OIDC token with a matching "sub"
    # claim - even one issued for a completely different purpose - could
    # assume this role. Pinning "aud" to STS is required by AWS's own IRSA
    # documentation and is what eksctl/official IRSA tooling generate by
    # default; easy to forget when writing the trust policy by hand.
    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.trust.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each   = { for idx, arn in var.policy_arns : idx => arn }
  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "inline" {
  count  = var.policy_json != null ? 1 : 0
  name   = "${var.role_name}-inline"
  role   = aws_iam_role.this.id
  policy = var.policy_json
}