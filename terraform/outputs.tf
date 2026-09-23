output "ingestion_uploads_bucket_name" {
  description = "Name of the private S3 bucket for files uploaded by the local ingestion script."
  value       = aws_s3_bucket.ingestion_uploads.bucket
}

output "video_metadata_table_name" {
  description = "Name of the DynamoDB table for Areopagus video and ingestion metadata."
  value       = aws_dynamodb_table.video_metadata.name
}
