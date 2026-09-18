resource "aws_cloudwatch_log_group" "downloader" {
  name              = "/aws/lambda/${local.project_name}-downloader"
  retention_in_days = 30
}

data "aws_s3_object" "downloader_package" {
  bucket = "${local.project_name}-${data.aws_caller_identity.current.account_id}-lambda-artifacts"
  key    = "lambda/current/areopagus-downloader.zip"
}

data "aws_s3_object" "deno_layer_package" {
  bucket = "${local.project_name}-${data.aws_caller_identity.current.account_id}-lambda-artifacts"
  key    = "lambda/current/areopagus-deno-layer.zip"
}

resource "aws_iam_role" "downloader" {
  name = "${local.project_name}-downloader"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "downloader_logging" {
  name = "${local.project_name}-downloader-logging"
  role = aws_iam_role.downloader.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "WriteFunctionLogs"
      Effect = "Allow"
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
      ]
      Resource = "${aws_cloudwatch_log_group.downloader.arn}:*"
    }]
  })
}

resource "aws_lambda_layer_version" "deno" {
  layer_name               = "${local.project_name}-deno"
  compatible_architectures = ["x86_64"]
  compatible_runtimes      = ["python3.13"]
  s3_bucket                = data.aws_s3_object.deno_layer_package.bucket
  s3_key                   = data.aws_s3_object.deno_layer_package.key
  s3_object_version        = data.aws_s3_object.deno_layer_package.version_id

  description = "Deno runtime required by yt-dlp for YouTube extraction."

  lifecycle {
    ignore_changes = [
      s3_bucket,
      s3_key,
      s3_object_version,
    ]
  }
}

resource "aws_lambda_function" "downloader" {
  function_name = "${local.project_name}-downloader"
  description   = "Downloads YouTube audio to ephemeral storage; it does not persist audio."
  role          = aws_iam_role.downloader.arn
  runtime       = "python3.13"
  handler       = "lambda_handler.lambda_handler"
  architectures = ["x86_64"]

  s3_bucket         = data.aws_s3_object.downloader_package.bucket
  s3_key            = data.aws_s3_object.downloader_package.key
  s3_object_version = data.aws_s3_object.downloader_package.version_id
  timeout           = var.downloader_timeout_seconds
  memory_size       = var.downloader_memory_size_mb
  layers            = [aws_lambda_layer_version.deno.arn]

  ephemeral_storage {
    size = var.downloader_ephemeral_storage_mb
  }

  environment {
    variables = {
      AREOPAGUS_DENO_PATH = "/opt/bin/deno"
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.downloader,
    aws_iam_role_policy.downloader_logging,
  ]

  lifecycle {
    ignore_changes = [
      layers,
      s3_bucket,
      s3_key,
      s3_object_version,
    ]
  }
}
