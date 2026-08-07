terraform {
  backend "s3" {
    # Same bucket as staging/, but a different key, which means a completely
    # separate Terraform state (no apply/destroy here can affect
    # staging/terraform.tfstate).
    bucket       = "tfstate-jbcampan-task-manager-cloud"
    key          = "staging-eks/terraform.tfstate"
    region       = "eu-west-3"
    encrypt      = true
    use_lockfile = true
  }
}