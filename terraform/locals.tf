locals {
  project_name = "areopagus"

  common_tags = {
    ManagedBy = "Terraform"
    Project   = local.project_name
  }
}
