variable "environment" {
  description = "Deployment environment (staging, prod)"
  type        = string

  validation {
    condition     = contains(["staging", "prod"], var.environment)
    error_message = "environment must be either \"staging\" or \"prod\"."
  }
}

variable "project_name" {
  description = "Project name, used as a prefix for all resource names"
  type        = string
  default     = "task-manager"
}

variable "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider (from the shared/ state)"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository allowed to assume this role, format: owner/repo"
  type        = string
}

variable "github_environment" {
  description = "GitHub Environment name (Settings > Environments) required in the workflow's job for the OIDC token to carry this claim. Must exist on GitHub before the first deploy - Terraform cannot create it."
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster this role is allowed to deploy to, must match the cluster created"
  type        = string
}

variable "backend_service_name" {
  description = "Name of the backend ECS service, must match the service created"
  type        = string
}

variable "frontend_service_name" {
  description = "Name of the frontend ECS service, must match the service created"
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
