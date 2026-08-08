variable "role_name" {
  description = "IAM role name."
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace of the ServiceAccount this role trusts."
  type        = string
}

variable "service_account_name" {
  description = "Kubernetes ServiceAccount name this role trusts. Must match the name of the SA the pod actually runs under - a mismatch here fails silently at pod runtime (AssumeRoleWithWebIdentity access denied), not at apply time."
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the cluster's IAM OIDC provider (eks module output)."
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC issuer URL without the https:// prefix (eks module output, already stripped)."
  type        = string
}

variable "policy_arns" {
  description = "Managed policy ARNs to attach to this role - use for reusing an existing policy (e.g. one already used by an ECS task role)."
  type        = list(string)
  default     = []
}

variable "policy_json" {
  description = "Optional inline policy document (JSON), for permissions specific enough that a standalone managed policy isn't warranted."
  type        = string
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}