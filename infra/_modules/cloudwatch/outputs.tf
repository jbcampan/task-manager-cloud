output "backend_log_group_name" {
  description = "Name of the backend log group, used by the ECS task definition"
  value       = aws_cloudwatch_log_group.backend.name
}

output "frontend_log_group_name" {
  description = "Name of the frontend log group, used by the ECS task definition"
  value       = aws_cloudwatch_log_group.frontend.name
}

output "backend_log_group_arn" {
  description = "ARN of the backend log group"
  value       = aws_cloudwatch_log_group.backend.arn
}

output "frontend_log_group_arn" {
  description = "ARN of the frontend log group"
  value       = aws_cloudwatch_log_group.frontend.arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic used by CPU/memory alarms"
  value       = aws_sns_topic.alerts.arn
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = aws_cloudwatch_dashboard.this.dashboard_name
}
