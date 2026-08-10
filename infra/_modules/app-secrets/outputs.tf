output "jwt_secret_arn" {
  description = "Secrets Manager ARN holding the JWT signing secret. Consumed by module.ecs (task definition secrets block) when ECS is deployed, and by module.external_secrets in staging-eks (ExternalSecret) independently of whether ECS is deployed at all."
  value       = aws_secretsmanager_secret.jwt.arn
}

output "jwt_secret_id" {
  description = "Secrets Manager secret ID/name (short form, not the full ARN) - useful for CLI lookups (aws secretsmanager get-secret-value)"
  value       = aws_secretsmanager_secret.jwt.id
}
