output "role_arn" {
  description = "ARN of the IAM role GitHub Actions assumes to deploy to EKS. Set as DEPLOY_ROLE_ARN in the staging-eks GitHub Environment."
  value       = aws_iam_role.deploy.arn
}

output "role_name" {
  description = "Name of the IAM role (useful for aws_eks_access_entry.principal_arn cross-references or debugging)."
  value       = aws_iam_role.deploy.name
}