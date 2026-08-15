# Renders the k8s-templates/*.tftpl files into k8s-generated/*.yaml with real
# values interpolated from Terraform outputs - no manual copy-pasting of
# ARNs, image URLs, or role ARNs into YAML. k8s-generated/ is applied
# manually via `kubectl apply -f` for now - not yet wired into
# `terraform apply` itself, since these are workload-layer resources, not
# infrastructure. Filenames are numbered so `kubectl apply -f
# k8s-generated/` applies them in a safe order (namespace/CRDs before
# secrets before configmaps before deployments).

locals {
  # "latest" is never used - image_tag is explicit, see variables.tf.
  backend_image  = "${data.terraform_remote_state.staging.outputs.ecr_backend_repository_url}:${var.image_tag}"
  frontend_image = "${data.terraform_remote_state.staging.outputs.ecr_frontend_repository_url}:${var.image_tag}"
  # Job names are immutable once created - a short SHA suffix lets a new
  # image tag get a fresh Job without colliding with a previous migration
  # run, while re-applying the same tag stays a safe no-op.
  image_tag_short = substr(var.image_tag, 0, 7)
}

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

resource "local_file" "configmap_backend" {
  filename = "${path.module}/k8s-generated/04-configmap-backend.yaml"
  content = templatefile("${path.module}/k8s-templates/04-configmap-backend.yaml.tftpl", {
    aws_region        = var.aws_region
    uploads_bucket_id = data.terraform_remote_state.staging.outputs.uploads_bucket_id
  })
}

resource "local_file" "configmap_frontend" {
  filename = "${path.module}/k8s-generated/05-configmap-frontend.yaml"
  content  = file("${path.module}/k8s-templates/05-configmap-frontend.yaml.tftpl")
}

resource "local_file" "serviceaccount_backend" {
  filename = "${path.module}/k8s-generated/06-serviceaccount-backend.yaml"
  content = templatefile("${path.module}/k8s-templates/06-serviceaccount-backend.yaml.tftpl", {
    backend_irsa_role_arn = module.irsa_backend.role_arn
  })
}

resource "local_file" "serviceaccount_frontend" {
  filename = "${path.module}/k8s-generated/07-serviceaccount-frontend.yaml"
  content  = file("${path.module}/k8s-templates/07-serviceaccount-frontend.yaml")
}

resource "local_file" "deployment_backend" {
  filename = "${path.module}/k8s-generated/08-deployment-backend.yaml"
  content = templatefile("${path.module}/k8s-templates/08-deployment-backend.yaml.tftpl", {
    backend_image = local.backend_image
    db_host       = data.terraform_remote_state.staging.outputs.db_instance_address
    db_port       = 5432
    db_name       = data.terraform_remote_state.staging.outputs.db_name
  })
}

resource "local_file" "deployment_frontend" {
  filename = "${path.module}/k8s-generated/09-deployment-frontend.yaml"
  content = templatefile("${path.module}/k8s-templates/09-deployment-frontend.yaml.tftpl", {
    frontend_image = local.frontend_image
  })
}

resource "local_file" "service_backend" {
  filename = "${path.module}/k8s-generated/10-service-backend.yaml"
  content  = file("${path.module}/k8s-templates/10-service-backend.yaml")
}

resource "local_file" "service_frontend" {
  filename = "${path.module}/k8s-generated/11-service-frontend.yaml"
  content  = file("${path.module}/k8s-templates/11-service-frontend.yaml")
}

resource "local_file" "ingress_backend" {
  filename = "${path.module}/k8s-generated/12-ingress-backend.yaml"
  content  = file("${path.module}/k8s-templates/12-ingress-backend.yaml")
}

resource "local_file" "ingress_frontend" {
  filename = "${path.module}/k8s-generated/13-ingress-frontend.yaml"
  content  = file("${path.module}/k8s-templates/13-ingress-frontend.yaml")
}

resource "local_file" "networkpolicy_default_deny" {
  filename = "${path.module}/k8s-generated/14-networkpolicy-default-deny.yaml"
  content  = file("${path.module}/k8s-templates/14-networkpolicy-default-deny.yaml")
}

resource "local_file" "networkpolicy_dns_egress" {
  filename = "${path.module}/k8s-generated/15-networkpolicy-dns-egress.yaml"
  content  = file("${path.module}/k8s-templates/15-networkpolicy-dns-egress.yaml")
}

resource "local_file" "networkpolicy_frontend_to_backend_ingress" {
  filename = "${path.module}/k8s-generated/16-networkpolicy-frontend-to-backend-ingress.yaml"
  content  = file("${path.module}/k8s-templates/16-networkpolicy-frontend-to-backend-ingress.yaml")
}

resource "local_file" "networkpolicy_frontend_to_backend_egress" {
  filename = "${path.module}/k8s-generated/17-networkpolicy-frontend-to-backend-egress.yaml"
  content  = file("${path.module}/k8s-templates/17-networkpolicy-frontend-to-backend-egress.yaml")
}

resource "local_file" "networkpolicy_alb_to_backend" {
  filename = "${path.module}/k8s-generated/18-networkpolicy-alb-to-backend.yaml"
  content = templatefile("${path.module}/k8s-templates/18-networkpolicy-alb-to-backend.yaml.tftpl", {
    vpc_cidr = data.terraform_remote_state.staging.outputs.vpc_cidr
  })
}

resource "local_file" "networkpolicy_alb_to_frontend" {
  filename = "${path.module}/k8s-generated/19-networkpolicy-alb-to-frontend.yaml"
  content = templatefile("${path.module}/k8s-templates/19-networkpolicy-alb-to-frontend.yaml.tftpl", {
    vpc_cidr = data.terraform_remote_state.staging.outputs.vpc_cidr
  })
}

resource "local_file" "networkpolicy_backend_egress_external" {
  filename = "${path.module}/k8s-generated/20-networkpolicy-backend-egress-external.yaml"
  content = templatefile("${path.module}/k8s-templates/20-networkpolicy-backend-egress-external.yaml.tftpl", {
    vpc_cidr = data.terraform_remote_state.staging.outputs.vpc_cidr
  })
}

resource "local_file" "job_migrate" {
  filename = "${path.module}/k8s-generated/21-job-migrate.yaml"
  content = templatefile("${path.module}/k8s-templates/21-job-migrate.yaml.tftpl", {
    backend_image   = local.backend_image
    image_tag_short = local.image_tag_short
    db_host         = data.terraform_remote_state.staging.outputs.db_instance_address
    db_port         = 5432
    db_name         = data.terraform_remote_state.staging.outputs.db_name
  })
}