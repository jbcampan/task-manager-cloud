variable "project_name" {
  description = "Project name, used in resource naming (\"$${project_name}-$${environment}\")."
  type        = string
}

variable "environment" {
  description = "Environment name for AWS resource naming (\"staging\" / \"prod\"). Not to be confused with the GitHub Environment name used elsewhere for OIDC trust policies."
  type        = string
}

variable "kubernetes_version" {
  description = <<-EOT
    EKS Kubernetes version, "major.minor" only (e.g. "1.30") - EKS does not allow
    omitting the minor version the way RDS allows omitting the patch version.

    No default on purpose. AWS EKS control plane pricing is ~$0.10/hour (~$73/month)
    while the version is under standard support. Once a version exits standard support
    (~14 months after release) and enters extended support, pricing jumps to ~$0.60/hour
    (~$438/month) for that same idle control plane - a 6x increase with zero functional
    change.

    Before every `apply` that touches this variable, check the current standard support
    window at https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions-standard.html
    and pick the latest version still comfortably inside it. This is a recurring
    maintenance task, not a one-time choice - unlike the RDS "major version only" fix
    (incident #2), there is no version string here that stays valid indefinitely.
  EOT
  type        = string

  validation {
    condition     = can(regex("^1\\.[0-9]{1,2}$", var.kubernetes_version))
    error_message = "kubernetes_version must be in \"major.minor\" format, e.g. \"1.30\"."
  }
}

variable "vpc_id" {
  description = "VPC ID the cluster's ENIs and worker nodes will live in."
  type        = string
}

variable "subnet_ids" {
  description = <<-EOT
    Subnet IDs for the EKS control plane ENIs. Should include private subnets (where
    worker nodes will live) and, if endpoint_public_access is enabled, public
    subnets as well so AWS can place ENIs reachable from the internet-facing side.
  EOT
  type        = list(string)
}

variable "endpoint_private_access" {
  description = "Enable private access to the Kubernetes API server endpoint (from inside the VPC, e.g. worker nodes, CI runners on a VPN/bastion)."
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = <<-EOT
    Enable public access to the Kubernetes API server endpoint (kubectl from a local
    machine without VPN/bastion). Kept true by default for this learning/demo project
    to avoid needing a bastion just to run kubectl - restrict endpoint_public_access_cidrs
    below instead of disabling this outright.
  EOT
  type        = bool
  default     = true
}

variable "endpoint_public_access_cidrs" {
  description = <<-EOT
    CIDR blocks allowed to reach the public API server endpoint when
    endpoint_public_access is true. Defaults to open (0.0.0.0/0) for convenience during
    development - restrict this to a known IP (home/office) before treating an
    environment as anything more than a personal demo.
  EOT
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enabled_cluster_log_types" {
  description = "EKS control plane log types to ship to CloudWatch. All five enabled by default for demo/interview purposes (full audit trail to show off in Phase Observability); trim this list on a real cost-sensitive production cluster."
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "log_retention_in_days" {
  description = "CloudWatch log group retention for EKS control plane logs."
  type        = number
  default     = 0
}

variable "enable_secrets_encryption" {
  description = "Enable envelope encryption of Kubernetes Secrets at rest using a dedicated KMS key. Recommended even for a demo project since it costs only the KMS key itself (~$1/month) and is a standard interview talking point."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags applied to all resources in this module."
  type        = map(string)
  default     = {}
}