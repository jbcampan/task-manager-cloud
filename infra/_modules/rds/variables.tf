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

variable "private_subnet_ids" {
  description = "Private subnet IDs for the DB subnet group (from the vpc module)"
  type        = list(string)
}

variable "rds_security_group_id" {
  description = "Security group ID allowing inbound PostgreSQL from ECS tasks (from the vpc module)"
  type        = string
}

variable "db_name" {
  description = "Name of the default database created on the instance"
  type        = string
  default     = "taskmanager"
}

variable "db_username" {
  description = "Master username. The password is managed natively by RDS in Secrets Manager, never set here."
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "PostgreSQL engine version. Verify currently supported versions for your region before applying (aws rds describe-db-engine-versions --engine postgres), AWS periodically retires old minor versions."
  type        = string
  default     = "16"
}

variable "instance_class" {
  description = "RDS instance class. db.t4g.micro (Graviton) is used by default for lower cost, but is NOT covered by the AWS Free Tier - use db.t3.micro if you want Free Tier eligibility."
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "Storage type"
  type        = string
  default     = "gp3"
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment for high availability. Doubles the cost - keep false for staging/lab, consider true for a real production workload."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups. Kept low (0) by default - AWS's restricted Free Plan caps this well below the standard RDS maximum of 35 days."
  type        = number
  default     = 0
}

variable "skip_final_snapshot" {
  description = "Skip taking a final snapshot on destroy. true is convenient for a staging environment you tear down often, false is safer for prod."
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Prevent the instance from being deleted via the API/Terraform without first disabling this flag"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
