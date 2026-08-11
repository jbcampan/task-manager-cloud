variable "project_name" {
  description = "Project name, used as a prefix for all resource names"
  type        = string
}

variable "environment" {
  description = "Environment name, used as a prefix for all resource names (e.g. \"staging-eks\")"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace the External Secrets Operator is installed into"
  type        = string
  default     = "external-secrets"
}

variable "chart_version" {
  description = <<-EOT
    external-secrets Helm chart version. Pinned deliberately (same rationale as
    the ALB Controller module) - verify against the current release before
    every apply with `helm search repo external-secrets/external-secrets --versions`.
  EOT
  type        = string
  default     = "2.6.0"
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN of the EKS cluster (module.eks.oidc_provider_arn) - required for IRSA"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC provider URL of the EKS cluster (module.eks.oidc_provider_url) - required for IRSA"
  type        = string
}

variable "secret_arns" {
  description = <<-EOT
    ARNs of the Secrets Manager secrets the operator's ServiceAccount is
    allowed to read (secretsmanager:GetSecretValue, DescribeSecret). Keep this
    list scoped to exactly the secrets consumed by ExternalSecret resources in
    this cluster - never a wildcard "*", the operator's IAM role is otherwise
    a single point of access to every secret in the account.
  EOT
  type        = list(string)
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
