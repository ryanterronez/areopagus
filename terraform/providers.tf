provider "aws" {
  region = "us-east-2"
  assume_role {
    role_arn = "arn:aws:iam::242668368155:role/areopagus-local-terraform"
  }
  default_tags {
    tags = local.common_tags
  }
}
