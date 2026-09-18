terraform {
  backend "s3" {
    bucket       = "areopagus-terraform-state"
    key          = "areopagus/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
  }
}
