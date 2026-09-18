resource "aws_dynamodb_table" "ingestion_metadata" {
  name         = "${local.project_name}-ingestion-metadata"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pk"
  range_key    = "sk"

  attribute {
    name = "pk"
    type = "S"
  }

  attribute {
    name = "sk"
    type = "S"
  }

  deletion_protection_enabled = true

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  # Video metadata is stored as pk = "VIDEO#{youtube_video_id}",
  # sk = "METADATA". Future course and professor entities and their
  # many-to-many relationships use adjacency-list items in the same table.
  # Add indexes only when a concrete query cannot use this primary-key layout.
}
