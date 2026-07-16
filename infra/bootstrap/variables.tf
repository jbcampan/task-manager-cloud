variable "aws_region" {
  description = "AWS region for the state backend resources"
  type        = string
  default     = "eu-west-3"
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name for Terraform remote state"
  type        = string
}