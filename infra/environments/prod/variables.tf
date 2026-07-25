variable "aws_region" {
  description = "AWS region for the prod environment"
  type        = string
  default     = "eu-west-3"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "prod"
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

variable "vpc_cidr" {
  description = "CIDR block for the prod VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "azs" {
  description = "Availability zones for the prod environment"
  type        = list(string)
  default     = ["eu-west-3a", "eu-west-3b"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs (ALB, NAT Gateway)"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs (ECS tasks, RDS)"
  type        = list(string)
  default     = ["10.1.11.0/24", "10.1.12.0/24"]
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

variable "eks_ready" {
  description = "Add Kubernetes subnet auto-discovery tags to ease a future EKS migration"
  type        = bool
  default     = false
}

variable "alert_email" {
  description = "Email address subscribed to the alerts SNS topic. Leave empty to skip the subscription."
  type        = string
  default     = ""
}

variable "cpu_alarm_threshold" {
  description = "CPU utilization percentage above which an alarm fires"
  type        = number
  default     = 80
}

variable "memory_alarm_threshold" {
  description = "Memory utilization percentage above which an alarm fires"
  type        = number
  default     = 80
}

variable "db_name" {
  description = "Name of the default database"
  type        = string
  default     = "taskmanager"
}

variable "db_username" {
  description = "Master username. The password is managed natively by RDS in Secrets Manager."
  type        = string
  default     = "postgres"
}

variable "db_instance_class" {
  description = "RDS instance class. Kept minimal on purpose - this is a personal project, not a real production workload."
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_multi_az" {
  description = "Enable Multi-AZ deployment. Kept false to minimize cost for a personal learning project."
  type        = bool
  default     = false
}

variable "db_skip_final_snapshot" {
  description = "Skip the final snapshot on destroy. true on purpose: no data worth keeping in this environment, and it must destroy cleanly without manual snapshot cleanup."
  type        = bool
  default     = true
}

variable "db_deletion_protection" {
  description = "Prevent accidental deletion via the API/Terraform. false on purpose so 'terraform destroy' works without a manual override, since this environment is spun up for punctual testing."
  type        = bool
  default     = false
}

variable "s3_allowed_origins" {
  description = "Origins allowed to upload directly to the uploads bucket (CORS). Leave empty until the frontend URL (ALB or CloudFront) is known."
  type        = list(string)
  default     = []
}

variable "github_repository" {
  description = "GitHub repository allowed to assume the deploy role, format: owner/repo"
  type        = string
}

variable "github_environment" {
  description = "GitHub Environment name required in the workflow job (Settings > Environments) - must be 'production', matching deploy-reusable.yml, NOT the same as var.environment ('prod')."
  type        = string
  default     = "production"
}