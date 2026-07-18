# Reads outputs from the shared/ state (ECR repositories, OIDC provider).
# Note: the bucket name here is duplicated from backend.tf on purpose -
# Terraform's backend block cannot reference variables, so this is the one
# place in the codebase where the bucket name has to be typed twice.
data "terraform_remote_state" "shared" {
  backend = "s3"

  config = {
    bucket = var.tfstate_bucket
    key    = "shared/terraform.tfstate"
    region = var.aws_region
  }
}
