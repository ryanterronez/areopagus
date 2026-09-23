resource "aws_dynamodb_table" "video_metadata" {
  name         = "areopagus-video-metadata"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "video_id"

  attribute {
    name = "video_id"
    type = "S"
  }
}
