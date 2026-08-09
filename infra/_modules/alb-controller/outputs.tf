output "role_arn" {
  description = "IAM role ARN assumed by the ALB Controller's ServiceAccount."
  value       = module.irsa.role_arn
}