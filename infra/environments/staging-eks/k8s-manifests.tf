# Renders the k8s-templates/*.tftpl files into k8s-generated/*.yaml with real
# values interpolated from Terraform outputs - no manual copy-pasting of
# ARNs into YAML, which is exactly the kind of drift this project's
# incidents.md already warns against (see incident #3 and the app-secrets
# refactor discussion). k8s-generated/ is applied manually via `kubectl
# apply -f` for now - not yet wired into `terraform apply` itself,
# since these are workload-layer resources, not infrastructure.

resource "local_file" "namespace" {
  filename = "${path.module}/k8s-generated/00-namespace.yaml"
  content  = file("${path.module}/k8s-templates/00-namespace.yaml")
}

resource "local_file" "cluster_secret_store" {
  filename = "${path.module}/k8s-generated/01-cluster-secret-store.yaml"
  content = templatefile("${path.module}/k8s-templates/01-cluster-secret-store.yaml.tftpl", {
    aws_region = var.aws_region
  })
}

resource "local_file" "external_secret_jwt" {
  filename = "${path.module}/k8s-generated/02-external-secret-jwt.yaml"
  content = templatefile("${path.module}/k8s-templates/02-external-secret-jwt.yaml.tftpl", {
    jwt_secret_arn = data.terraform_remote_state.staging.outputs.jwt_secret_arn
  })
}

resource "local_file" "external_secret_rds" {
  filename = "${path.module}/k8s-generated/03-external-secret-rds.yaml"
  content = templatefile("${path.module}/k8s-templates/03-external-secret-rds.yaml.tftpl", {
    rds_secret_arn = data.terraform_remote_state.staging.outputs.master_user_secret_arn
  })
}
