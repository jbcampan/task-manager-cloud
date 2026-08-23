variable "project_name" {
  description = "Project name, used in the IAM role name (matches the $${project_name}-$${environment} convention)."
  type        = string
}

variable "environment" {
  description = "Environment name, used in the IAM role name (e.g. \"staging-eks\")."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository in \"owner/repo\" form, used to scope the OIDC trust policy's sub condition."
  type        = string
}

variable "github_environment" {
  description = "GitHub Environment name (e.g. \"staging-eks\") this role's trust policy is scoped to - only a workflow job declaring this exact environment can assume it."
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the GitHub Actions OIDC provider (aws_iam_openid_connect_provider for token.actions.githubusercontent.com) - the same one already used by the ECS deploy role, not a new one."
  type        = string
}

variable "cluster_arn" {
  description = "ARN of the target EKS cluster - scopes the eks:DescribeCluster permission to this cluster only."
  type        = string
}

variable "tags" {
  description = "Common resource tags."
  type        = map(string)
  default     = {}
}