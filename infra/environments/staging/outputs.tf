output "ecr_backend_repository_url" {
  description = "URL of the backend ECR repository (from shared/ state)"
  value       = data.terraform_remote_state.shared.outputs.ecr_backend_repository_url
}

output "ecr_frontend_repository_url" {
  description = "URL of the frontend ECR repository (from shared/ state)"
  value       = data.terraform_remote_state.shared.outputs.ecr_frontend_repository_url
}

output "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider (from shared/ state)"
  value       = data.terraform_remote_state.shared.outputs.oidc_provider_arn
}

output "vpc_id" {
  description = "ID of the staging VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = module.vpc.nat_gateway_id
}