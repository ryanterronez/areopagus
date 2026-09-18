terraform {
  backend "s3" {
    bucket       = "areopagus-terraform-state"
    key          = "areopagus/lambda-artifacts.tfstate"
    region       = "us-east-2"
    use_lockfile = true
  }
}
