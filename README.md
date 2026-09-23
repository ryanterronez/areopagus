# Areopagus

The project is at a clean restart point.

There is currently no application implementation and no Terraform-managed Areopagus application infrastructure. Architecture for the rebuild has not yet been implemented.
# Areopagus

Areopagus is a small application for ingesting lecture content and making transcripts searchable. This repository currently contains only the Terraform and GitHub Actions bootstrap; application infrastructure has not been created yet.

## Terraform

Terraform uses the existing S3 state bucket `areopagus-terraform-state` with the state key `areopagus/terraform.tfstate` in `us-east-2`. Native S3 state locking is enabled. Authenticate to AWS locally through your normal IAM Identity Center / SSO workflow, then run:

```text
cd terraform
terraform init
terraform plan
terraform apply
```

## GitHub Actions

Pull requests targeting `main` run `terraform init` and `terraform plan`; they never apply changes. Pushes to `main`, including merged pull requests, run `terraform init` and `terraform apply`.

Both workflows use GitHub OIDC to assume `arn:aws:iam::242668368155:role/areopagus-github-actions`. They request only `contents: read` and `id-token: write` permissions.
