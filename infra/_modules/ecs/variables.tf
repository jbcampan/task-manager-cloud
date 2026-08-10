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

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-3"
}

variable "vpc_id" {
  description = "VPC ID (from the vpc module)"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS tasks (from the vpc module)"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB (from the vpc module)"
  type        = list(string)
}

variable "master_user_secret_arn" {
  description = "Secrets Manager ARN holding the RDS master password, in username/password JSON keys (from the rds module)"
  type        = string
}

variable "jwt_secret_arn" {
  description = "Secrets Manager ARN holding the JWT signing secret (from the app-secrets module)"
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

variable "ecs_security_group_id" {
  description = "Security group ID for ECS tasks (from the vpc module)"
  type        = string
}

variable "ecr_backend_repository_url" {
  description = "URL of the backend ECR repository (from the shared/ state)"
  type        = string
}

variable "ecr_frontend_repository_url" {
  description = "URL of the frontend ECR repository (from the shared/ state)"
  type        = string
}

variable "backend_image_tag" {
  description = "Image tag to deploy for the backend. Defaults to latest for the first apply - the CD workflow (4.3) will override this with a git SHA on every deploy."
  type        = string
  default     = "latest"
}

variable "frontend_image_tag" {
  description = "Image tag to deploy for the frontend. Defaults to latest for the first apply - the CD workflow (4.3) will override this with a git SHA on every deploy."
  type        = string
  default     = "latest"
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

variable "backend_cpu" {
  description = "Fargate CPU units for the backend task (256 = 0.25 vCPU)"
  type        = number
  default     = 256
}

variable "backend_memory" {
  description = "Fargate memory in MB for the backend task"
  type        = number
  default     = 512
}

variable "frontend_cpu" {
  description = "Fargate CPU units for the frontend task"
  type        = number
  default     = 256
}

variable "frontend_memory" {
  description = "Fargate memory in MB for the frontend task"
  type        = number
  default     = 512
}

variable "backend_desired_count" {
  description = "Number of backend tasks to run"
  type        = number
  default     = 1
}

variable "frontend_desired_count" {
  description = "Number of frontend tasks to run"
  type        = number
  default     = 1
}

variable "backend_log_group_name" {
  description = "CloudWatch log group for backend container logs (from the cloudwatch module)"
  type        = string
}

variable "frontend_log_group_name" {
  description = "CloudWatch log group for frontend container logs (from the cloudwatch module)"
  type        = string
}

variable "db_address" {
  description = "RDS instance hostname, without port (from the rds module)"
  type        = string
}

variable "db_port" {
  description = "RDS instance port"
  type        = number
  default     = 5432
}

variable "db_name" {
  description = "Default database name (from the rds module)"
  type        = string
}

variable "db_username" {
  description = "Master username (from the rds module)"
  type        = string
}

variable "jwt_expires_in" {
  description = "JWT expiration, passed to the backend as an environment variable"
  type        = string
  default     = "7d"
}

variable "uploads_bucket_id" {
  description = "S3 uploads bucket name (from the s3 module)"
  type        = string
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

variable "cookie_secure" {
  description = "Whether the frontend session cookie must be marked Secure. Requires HTTPS on the ALB (ACM certificate) - set to false until that's in place."
  type        = bool
  default     = false
}