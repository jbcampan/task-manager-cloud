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

variable "master_user_secret_arn" {
  description = "Secrets Manager ARN holding the RDS master password, in username/password JSON keys (from the rds module)"
  type        = string
}

variable "uploads_rw_policy_arn" {
  description = "IAM policy ARN for read/write access to the uploads bucket (from the s3 module), attached to the ECS task role"
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
