provider "aws" {
  region = "us-east-2"

  dynamic "assume_role" {
    for_each = var.assume_local_terraform_role ? [true] : []

    content {
      role_arn = "arn:aws:iam::242668368155:role/areopagus-local-terraform"
    }
  }

  default_tags {
    tags = local.common_tags
  }
}
