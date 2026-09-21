locals {
  project_name = "areopagus"

  common_tags = {
    "app-name" = local.project_name
  }
}
