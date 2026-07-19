terraform {
  required_version = ">= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

locals {
  common_tags = {
    Project     = "task-manager-cloud"
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  # Naming convention shared with the ECS module - CloudWatch
  # alarms below are wired to these names before the ECS resources exist,
  # they will report INSUFFICIENT_DATA until the service is created.
  ecs_cluster_name      = "${var.project_name}-${var.environment}"
  backend_service_name  = "${var.project_name}-${var.environment}-backend"
  frontend_service_name = "${var.project_name}-${var.environment}-frontend"
}

