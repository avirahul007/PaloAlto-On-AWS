
output "bucket_id" {
  value       = aws_s3_bucket.bucket.id
  description = "ID of created bucket."
}

output "instance_profile_name" {
  value       = aws_iam_instance_profile.bootstrap.name
  description = "Name of created IAM instance profile."
}