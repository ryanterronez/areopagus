resource "aws_s3_bucket" "ingestion_uploads" {
  bucket = "areopagus-app-ingestion-uploads"
}

resource "aws_s3_bucket_public_access_block" "ingestion_uploads" {
  bucket = aws_s3_bucket.ingestion_uploads.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ingestion_uploads" {
  bucket = aws_s3_bucket.ingestion_uploads.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
