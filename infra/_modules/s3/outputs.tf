output "bucket_id" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.uploads.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.uploads.arn
}

output "bucket_regional_domain_name" {
  description = "Regional domain name, useful for building object URLs"
  value       = aws_s3_bucket.uploads.bucket_regional_domain_name
}

output "uploads_rw_policy_arn" {
  description = "ARN of the least-privilege IAM policy, to attach to the ECS task role"
  value       = aws_iam_policy.uploads_rw.arn
}
