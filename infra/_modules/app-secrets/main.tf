# Moved from _modules/ecs/secrets.tf (EKS migration) - this secret is
# an application concern, not an ECS-platform concern. Coupling its lifecycle
# to the ECS module meant it could never be created without also deploying
# the full ECS stack (cluster, ALB, task definitions) - a problem invisible
# until a second compute platform (EKS) needed to read the same secret
# without deploying ECS at all.

# Generated once, stored in Secrets Manager - never appears in Terraform
# state as plaintext beyond this resource, never hardcoded in the task
# definition or in application code.
resource "random_password" "jwt_secret" {
  length  = 64
  special = false
}

resource "aws_secretsmanager_secret" "jwt" {
  name = "${var.project_name}-${var.environment}-jwt-secret"
  # 0 = delete immediately on destroy, no 30-day recovery window. Appropriate
  # for staging where destroy/apply cycles are frequent - reconsider for a
  # real production secret you'd want to be able to recover.
  recovery_window_in_days = 0
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "jwt" {
  secret_id     = aws_secretsmanager_secret.jwt.id
  secret_string = random_password.jwt_secret.result
}
