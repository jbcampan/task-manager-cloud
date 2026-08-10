variable "project_name" {
  description = "Project name, used as a prefix for the secret name"
  type        = string
}

variable "environment" {
  description = "Environment name, used as a prefix for the secret name (keeps staging and prod secrets isolated from each other)"
  type        = string
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
