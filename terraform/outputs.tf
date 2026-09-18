output "audio_bucket_arn" {
  description = "ARN of the private S3 bucket that stores downloaded lecture audio."
  value       = aws_s3_bucket.audio.arn
}

output "audio_bucket_name" {
  description = "Name of the private S3 bucket that stores downloaded lecture audio."
  value       = aws_s3_bucket.audio.id
}

output "ingestion_metadata_table_arn" {
  description = "ARN of the DynamoDB table that stores lecture ingestion metadata."
  value       = aws_dynamodb_table.ingestion_metadata.arn
}

output "ingestion_metadata_table_name" {
  description = "Name of the DynamoDB table that stores lecture ingestion metadata."
  value       = aws_dynamodb_table.ingestion_metadata.name
}
