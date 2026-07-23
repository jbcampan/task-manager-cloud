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
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "jwt" {
  secret_id     = aws_secretsmanager_secret.jwt.id
  secret_string = random_password.jwt_secret.result
}
