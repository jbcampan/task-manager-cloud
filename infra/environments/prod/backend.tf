terraform {
  backend "s3" {
    # Replace with the bucket name you chose during the bootstrap step
    bucket       = "tfstate-jbcampan-task-manager-cloud"
    key          = "prod/terraform.tfstate"
    region       = "eu-west-3"
    encrypt      = true
    use_lockfile = true
  }
}
