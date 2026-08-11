output "role_arn" {
  description = "IAM role ARN assumed by the External Secrets Operator ServiceAccount"
  value       = module.irsa.role_arn
}

output "namespace" {
  description = "Kubernetes namespace the operator is installed into"
  value       = var.namespace
}

output "service_account_name" {
  description = "ServiceAccount name to reference from SecretStore resources (M2.2)"
  value       = "external-secrets"
}