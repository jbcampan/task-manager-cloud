output "role_arn" {
  description = "IAM role ARN - annotate the K8s ServiceAccount with eks.amazonaws.com/role-arn = this value."
  value       = aws_iam_role.this.arn
}

output "role_name" {
  value = aws_iam_role.this.name
}