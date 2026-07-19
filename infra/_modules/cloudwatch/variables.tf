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
  description = "AWS region, used in the dashboard widget metrics"
  type        = string
  default     = "eu-west-3"
}

variable "log_retention_days" {
  description = "Number of days to retain application logs"
  type        = number
  default     = 14
}

variable "log_group_class" {
  description = "CloudWatch log group class. STANDARD supports Logs Insights and real-time metric filters. INFREQUENT_ACCESS costs up to 50% less but drops those features - keep STANDARD while actively debugging."
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "INFREQUENT_ACCESS"], var.log_group_class)
    error_message = "log_group_class must be either \"STANDARD\" or \"INFREQUENT_ACCESS\"."
  }
}

variable "alert_email" {
  description = "Email address subscribed to the alerts SNS topic. Leave empty to skip the subscription (you can subscribe manually later)."
  type        = string
  default     = ""
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster, must match the cluster created before"
  type        = string
}

variable "backend_service_name" {
  description = "Name of the backend ECS service, must match the service created before"
  type        = string
}

variable "frontend_service_name" {
  description = "Name of the frontend ECS service, must match the service created before"
  type        = string
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

variable "alarm_evaluation_periods" {
  description = "Number of consecutive periods the threshold must be breached before the alarm fires"
  type        = number
  default     = 3
}

variable "alarm_period_seconds" {
  description = "Length of each evaluation period, in seconds"
  type        = number
  default     = 300
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
