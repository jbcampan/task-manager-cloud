terraform {
  required_version = ">= 1.11.0"   # use_lockfile requires 1.10+, GA since 1.11

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
    tags = {
      Project   = "task-manager-cloud"
      ManagedBy = "terraform"
      Purpose   = "terraform-state-backend"
    }
  }
}

# ─────────────────────────────────────────────────────────────
# S3 bucket — remote state storage
# ─────────────────────────────────────────────────────────────
resource "aws_s3_bucket" "tfstate" {
  bucket = var.bucket_name

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Every state file has an encrypted history of previous versions.
# Protects against a bad `apply` overwriting state with no way back.
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# No aws_dynamodb_table resource - locking is handled natively by S3
# via use_lockfile = true in each module's backend.tf (Terraform >= 1.10).