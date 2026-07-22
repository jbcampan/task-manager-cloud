output "ecr_backend_repository_url" {
  description = "URL of the backend ECR repository (from shared/ state)"
  value       = data.terraform_remote_state.shared.outputs.ecr_backend_repository_url
}

output "ecr_frontend_repository_url" {
  description = "URL of the frontend ECR repository (from shared/ state)"
  value       = data.terraform_remote_state.shared.outputs.ecr_frontend_repository_url
}

output "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider (from shared/ state)"
  value       = data.terraform_remote_state.shared.outputs.oidc_provider_arn
}

output "vpc_id" {
  description = "ID of the staging VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = module.vpc.nat_gateway_id
}

output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = module.vpc.alb_security_group_id
}

output "ecs_security_group_id" {
  description = "ECS tasks security group ID"
  value       = module.vpc.ecs_security_group_id
}

output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = module.vpc.rds_security_group_id
}

output "backend_log_group_name" {
  description = "Backend CloudWatch log group name"
  value       = module.cloudwatch.backend_log_group_name
}

output "frontend_log_group_name" {
  description = "Frontend CloudWatch log group name"
  value       = module.cloudwatch.frontend_log_group_name
}

output "sns_topic_arn" {
  description = "SNS topic ARN for CPU/memory alarms"
  value       = module.cloudwatch.sns_topic_arn
}

output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = module.cloudwatch.dashboard_name
}

output "db_instance_endpoint" {
  description = "RDS connection endpoint, host:port"
  value       = module.rds.db_instance_endpoint
}

output "db_instance_address" {
  description = "RDS hostname, without the port"
  value       = module.rds.db_instance_address
}

output "db_name" {
  description = "Default database name"
  value       = module.rds.db_name
}

output "master_user_secret_arn" {
  description = "Secrets Manager ARN holding the RDS master password"
  value       = module.rds.master_user_secret_arn
}

output "uploads_bucket_id" {
  description = "S3 uploads bucket name"
  value       = module.s3.bucket_id
}

output "uploads_rw_policy_arn" {
  description = "IAM policy ARN for read/write access to the uploads bucket"
  value       = module.s3.uploads_rw_policy_arn
}

output "deploy_role_arn" {
  description = "ARN of the IAM role for the CD workflow"
  value       = module.iam_oidc.deploy_role_arn
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "ecs_execution_role_arn" {
  description = "ECS task execution role ARN"
  value       = module.ecs.execution_role_arn
}

output "ecs_task_role_arn" {
  description = "ECS task role ARN"
  value       = module.ecs.task_role_arn
}

output "app_url" {
  description = "Public URL of the application"
  value       = "http://${module.ecs.alb_dns_name}"
}