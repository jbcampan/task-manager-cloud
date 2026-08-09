variable "cluster_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "oidc_provider_url" {
  type = string
}

variable "chart_version" {
  description = <<-EOT
    aws-load-balancer-controller Helm chart version (NOT the eks-charts repo
    release tag, e.g. "v0.0.239" - that bundles multiple unrelated charts).
    Find the exact chart version matching a given controller appVersion with:
      helm repo add eks https://aws.github.io/eks-charts && helm repo update
      helm search repo eks/aws-load-balancer-controller --versions
    The IAM policy in iam-policy.json is tied to the controller's appVersion
    (not the chart version) - re-download it whenever the appVersion changes,
    see this module's README.
  EOT
  type        = string
  # No default on purpose - unlike kubernetes_version, this isn't a recurring
  # cost tradeoff, but the same principle applies: pick it deliberately via
  # `helm search repo --versions`, don't inherit a number that may already
  # be stale by the time this is read.
}

variable "tags" {
  type    = map(string)
  default = {}
}