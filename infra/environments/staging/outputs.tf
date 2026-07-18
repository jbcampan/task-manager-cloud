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
