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

variable "node_desired_size" {
  description = "Desired worker node count for staging-eks"
  type        = number
  default     = 2
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 3
}

variable "node_instance_types" {
  description = "See infra/_modules/eks/variables.tf for the Free-Tier-eligibility vs cost rationale (eligible ≠ equal price)."
  type        = list(string)
  default     = ["m7i-flex.large"]
}

variable "node_capacity_type" {
  description = "SPOT for staging (cost), ON_DEMAND recommended if this were ever a real prod cluster."
  type        = string
  default     = "SPOT"
}

variable "image_tag" {
  description = <<-EOT
    Docker image tag (commit SHA) to deploy on EKS - backend and frontend
    share the same tag. Not auto-resolved from ECR's most recent push: EKS
    has no CD job of its own yet (cd.yml only deploys to ECS), so "most
    recent" would silently mean "whatever ECS last deployed" - an implicit
    coupling, not a real guarantee. Pick a SHA you've confirmed exists in
    both ECR repos (`aws ecr describe-images --repository-name ...`) and
    set it explicitly in terraform.tfvars.
  EOT
  type        = string
}

variable "grafana_admin_password" {
  description = "Grafana admin password for the kube-prometheus-stack deployment. Set in terraform.tfvars, never committed."
  type        = string
  sensitive   = true
}