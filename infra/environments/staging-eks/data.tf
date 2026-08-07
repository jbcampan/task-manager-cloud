# Reads outputs from the staging (ECS) Terraform state to reuse the existing
# VPC instead of provisioning a second one. This avoids the cost of an
# additional NAT Gateway (~$32/month) during the ECS/EKS coexistence period.
# This temporary coupling between the two states is intentional and should be
# revisited once ECS has been decommissioned.

data "terraform_remote_state" "staging" {
  backend = "s3"

  config = {
    bucket = var.tfstate_bucket
    key    = "staging/terraform.tfstate"
    region = var.aws_region
  }
}

# Required ECR for pod images and potentially IRSA for S3 access. 

data "terraform_remote_state" "shared" {
  backend = "s3"

  config = {
    bucket = var.tfstate_bucket
    key    = "shared/terraform.tfstate"
    region = var.aws_region
  }
}