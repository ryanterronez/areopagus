data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "audio" {
  bucket = "${local.project_name}-${data.aws_caller_identity.current.account_id}-audio"

  force_destroy = false
}

resource "aws_s3_bucket" "lambda_artifact" {
  bucket = "${local.project_name}-${data.aws_caller_identity.current.account_id}-lambda-artifacts"

  force_destroy = false
}

resource "aws_s3_bucket_ownership_controls" "lambda_artifact" {
  bucket = aws_s3_bucket.lambda_artifact.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "lambda_artifact" {
  bucket = aws_s3_bucket.lambda_artifact.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lambda_artifact" {
  bucket = aws_s3_bucket.lambda_artifact.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "lambda_artifact" {
  bucket = aws_s3_bucket.lambda_artifact.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lambda_artifact" {
  bucket = aws_s3_bucket.lambda_artifact.id

  rule {
    id     = "expire-noncurrent-lambda-artifacts"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = var.lambda_artifact_noncurrent_version_expiration_days
    }
  }
}

resource "aws_s3_bucket_policy" "lambda_artifact_deployment" {
  bucket = aws_s3_bucket.lambda_artifact.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowDeploymentRoleToUploadLambdaArtifacts"
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${var.lambda_artifact_deployment_account_id}:role/areopagus-github-actions-deployment"
      }
      Action   = ["s3:AbortMultipartUpload", "s3:PutObject"]
      Resource = "${aws_s3_bucket.lambda_artifact.arn}/lambda/*"
    }]
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "audio" {
  bucket = aws_s3_bucket.audio.id

  rule {
    id     = "manage-noncurrent-versions-and-incomplete-uploads"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    noncurrent_version_expiration {
      noncurrent_days = var.audio_noncurrent_version_expiration_days
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "audio" {
  bucket = aws_s3_bucket.audio.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "audio" {
  bucket = aws_s3_bucket.audio.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "audio" {
  bucket = aws_s3_bucket.audio.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "audio" {
  bucket = aws_s3_bucket.audio.id

  versioning_configuration {
    status = "Enabled"
  }
}
