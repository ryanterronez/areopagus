data "aws_caller_identity" "current" {}

locals {
  bucket_name = "areopagus-${data.aws_caller_identity.current.account_id}-lambda-artifacts"
}

resource "aws_s3_bucket" "main" {
  bucket        = local.bucket_name
  force_destroy = false
}

resource "aws_s3_bucket_ownership_controls" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "expire-noncurrent-lambda-artifacts"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

resource "aws_s3_bucket_policy" "deployment" {
  bucket = aws_s3_bucket.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowDeploymentRoleToUploadLambdaArtifacts"
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${var.deployment_account_id}:role/areopagus-github-actions-deployment"
      }
      Action   = ["s3:AbortMultipartUpload", "s3:PutObject"]
      Resource = "${aws_s3_bucket.main.arn}/lambda/*"
    }]
  })
}
