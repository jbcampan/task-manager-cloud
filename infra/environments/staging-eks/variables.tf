variable "aws_region" {
  description = "AWS region for the staging-eks environment"
  type        = string
  default     = "eu-west-3"
}

variable "environment" {
  description = <<-EOT
    Environment name for AWS resource naming ("staging-eks"). Deliberately
    distinct from the ECS environment's "staging" so cluster/resource names
    never collide with the ECS stack while both coexist during the migration.
  EOT
  type        = string
  default     = "staging-eks"
}

variable "project_name" {
  description = "Project name, used as a prefix for all resource names"
  type        = string
  default     = "task-manager"
}

variable "tfstate_bucket" {
  description = "S3 bucket holding Terraform state - must match backend.tf and the bucket used by the staging (ECS) environment"
  type        = string
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version, \"major.minor\" (e.g. \"1.30\"). See infra/_modules/eks/variables.tf for the standard-support-window cost rationale - verify before every apply."
  type        = string
}