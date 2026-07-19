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

variable "allowed_origins" {
  description = "Origins allowed to upload directly to the bucket via presigned URLs (CORS). Leave empty to skip CORS entirely - the backend can still read/write server-side without it."
  type        = list(string)
  default     = []
}

variable "noncurrent_version_expiration_days" {
  description = "Days to keep noncurrent object versions before they are permanently deleted"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
