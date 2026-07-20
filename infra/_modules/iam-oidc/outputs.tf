output "deploy_role_arn" {
  description = "ARN of the IAM role assumable by GitHub Actions to deploy this environment, consumed by the CD workflow in step 4.3"
  value       = aws_iam_role.deploy.arn
}
