output "audio_bucket_arn" {
  description = "ARN of the private S3 bucket that stores downloaded lecture audio."
  value       = aws_s3_bucket.audio.arn
}

output "audio_bucket_name" {
  description = "Name of the private S3 bucket that stores downloaded lecture audio."
  value       = aws_s3_bucket.audio.id
}

output "downloader_lambda_name" {
  description = "Name of the Lambda function that verifies the YouTube downloader runtime."
  value       = aws_lambda_function.downloader.function_name
}

output "lambda_artifact_bucket_name" {
  description = "Name of the private, versioned bucket that stores Lambda deployment packages."
  value       = "${local.project_name}-${data.aws_caller_identity.current.account_id}-lambda-artifacts"
}

output "ingestion_metadata_table_arn" {
  description = "ARN of the DynamoDB table that stores lecture ingestion metadata."
  value       = aws_dynamodb_table.ingestion_metadata.arn
}

output "ingestion_metadata_table_name" {
  description = "Name of the DynamoDB table that stores lecture ingestion metadata."
  value       = aws_dynamodb_table.ingestion_metadata.name
}
