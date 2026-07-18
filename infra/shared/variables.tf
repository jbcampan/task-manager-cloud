variable "aws_region" {
  description = "AWS region for shared resources"
  type        = string
  default     = "eu-west-3"
}

variable "project_name" {
  description = "Project name, used as a prefix for all resource names"
  type        = string
  default     = "task-manager"
}

variable "github_repository" {
  description = "GitHub repository allowed to assume the ECR push role, format: owner/repo"
  type        = string
}
