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

variable "vpc_id" {
  description = "VPC ID (from the vpc module)"
  type        = string
}

variable "master_user_secret_arn" {
  description = "Secrets Manager ARN holding the RDS master password, in username/password JSON keys (from the rds module)"
  type        = string
}

variable "uploads_rw_policy_arn" {
  description = "IAM policy ARN for read/write access to the uploads bucket (from the s3 module), attached to the ECS task role"
  type        = string
}

variable "alb_security_group_id" {
  description = "Security group ID for the ALB (from the vpc module)"
  type        = string
}

variable "backend_container_port" {
  description = "Port the NestJS backend container listens on"
  type        = number
  default     = 3001
}

variable "frontend_container_port" {
  description = "Port the Next.js frontend container listens on"
  type        = number
  default     = 3000
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB (from the vpc module)"
  type        = list(string)
}

variable "alb_deletion_protection" {
  description = "Prevent the ALB from being deleted via the API/Terraform without first disabling this flag"
  type        = bool
  default     = false
}

variable "backend_health_check_path" {
  description = "Path the ALB polls to determine backend task health"
  type        = string
  default     = "/api/v1/health/live"
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
