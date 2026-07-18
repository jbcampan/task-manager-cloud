variable "aws_region" {
  description = "AWS region for the staging environment"
  type        = string
  default     = "eu-west-3"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "staging"
}

variable "project_name" {
  description = "Project name, used as a prefix for all resource names"
  type        = string
  default     = "task-manager"
}

variable "tfstate_bucket" {
  description = "S3 bucket holding Terraform state, must match the bucket set in backend.tf"
  type        = string
}
