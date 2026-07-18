output "ecr_backend_repository_url" {
  description = "URL of the backend ECR repository"
  value       = aws_ecr_repository.backend.repository_url
}

output "ecr_frontend_repository_url" {
  description = "URL of the frontend ECR repository"
  value       = aws_ecr_repository.frontend.repository_url
}

output "ecr_backend_repository_arn" {
  description = "ARN of the backend ECR repository"
  value       = aws_ecr_repository.backend.arn
}

output "ecr_frontend_repository_arn" {
  description = "ARN of the frontend ECR repository"
  value       = aws_ecr_repository.frontend.arn
}

output "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = aws_iam_openid_connect_provider.github.arn
}

output "ecr_push_role_arn" {
  description = "ARN of the IAM role assumable by GitHub Actions to push images to ECR"
  value       = aws_iam_role.ecr_push.arn
}
