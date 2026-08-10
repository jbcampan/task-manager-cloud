resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.project_name}-${var.environment}-backend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.backend_cpu
  memory                   = var.backend_memory
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = "${var.ecr_backend_repository_url}:${var.backend_image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = var.backend_container_port
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "NODE_ENV", value = var.environment == "prod" ? "production" : "development" },
        { name = "PORT", value = tostring(var.backend_container_port) },
        { name = "DB_HOST", value = var.db_address },
        { name = "DB_PORT", value = tostring(var.db_port) },
        { name = "DB_NAME", value = var.db_name },
        { name = "JWT_EXPIRES_IN", value = var.jwt_expires_in },
        { name = "CORS_ORIGIN", value = "http://${aws_lb.this.dns_name}" },
      ]

      # Individual fields, not a single DATABASE_URL - ECS reads specific
      # JSON keys straight out of the RDS-managed secret. The container
      # entrypoint assembles DATABASE_URL from these at startup (see the
      # backend entrypoint.sh note below).
      secrets = [
        { name = "DB_USERNAME", valueFrom = "${var.master_user_secret_arn}:username::" },
        { name = "DB_PASSWORD", valueFrom = "${var.master_user_secret_arn}:password::" },
        { name = "JWT_SECRET", valueFrom = var.jwt_secret_arn },
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.backend_log_group_name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "backend"
        }
      }
    }
  ])

  tags = var.tags
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.project_name}-${var.environment}-frontend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.frontend_cpu
  memory                   = var.frontend_memory
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = "${var.ecr_frontend_repository_url}:${var.frontend_image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = var.frontend_container_port
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "NODE_ENV", value = var.environment == "prod" ? "production" : "development" },
        { name = "PORT", value = tostring(var.frontend_container_port) },
        # Server-only, never NEXT_PUBLIC_ - same ALB serves both apps, so
        # the frontend calls /api/* on its own origin.
        { name = "API_URL", value = "http://${aws_lb.this.dns_name}/api/v1" },
        # false until an ACM certificate + HTTPS listener sit in front of
        # the ALB - see apps/frontend/src/lib/auth.ts for why this matters.
        { name = "COOKIE_SECURE", value = var.cookie_secure ? "true" : "false" },
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = var.frontend_log_group_name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "frontend"
        }
      }
    }
  ])

  tags = var.tags
}
