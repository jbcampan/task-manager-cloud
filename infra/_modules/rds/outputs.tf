output "db_instance_endpoint" {
  description = "Connection endpoint, host:port"
  value       = aws_db_instance.this.endpoint
}

output "db_instance_address" {
  description = "Hostname of the RDS instance, without the port"
  value       = aws_db_instance.this.address
}

output "db_instance_port" {
  description = "Port the database listens on"
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Name of the default database"
  value       = aws_db_instance.this.db_name
}

output "db_username" {
  description = "Master username"
  value       = aws_db_instance.this.username
}

output "master_user_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the master password, consumed by the ECS task definition in step 3.3"
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}
