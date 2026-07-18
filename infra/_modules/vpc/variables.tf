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

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones to spread subnets across (at least 2, required by the RDS subnet group)"
  type        = list(string)

  validation {
    condition     = length(var.azs) >= 2
    error_message = "At least 2 availability zones are required (RDS subnet group constraint)."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets, one per AZ, same order as var.azs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets, one per AZ, same order as var.azs"
  type        = list(string)
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
  description = "Add Kubernetes subnet auto-discovery tags (kubernetes.io/role/elb and internal-elb) to ease a future EKS migration. No effect on the current ECS/ALB setup - safe to leave false until an EKS cluster exists."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
