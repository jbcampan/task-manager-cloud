output "bucket_name" {
  description = "Name of the S3 bucket holding Terraform state - copy into every backend.tf"
  value       = aws_s3_bucket.tfstate.id
}