terraform {
  required_version = ">= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  # Naming convention shared with the cloudwatch and iam-oidc modules -
  # keep these three in sync if you ever change the pattern.
  cluster_name          = "${var.project_name}-${var.environment}"
  backend_service_name  = "${var.project_name}-${var.environment}-backend"
  frontend_service_name = "${var.project_name}-${var.environment}-frontend"
}

resource "aws_ecs_cluster" "this" {
  name = local.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(var.tags, {
    Name = local.cluster_name
  })
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 100
  }
}