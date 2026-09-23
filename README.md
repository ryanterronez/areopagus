# Areopagus

The project is at a clean restart point.

There is currently no application implementation and no Terraform-managed Areopagus application infrastructure. Architecture for the rebuild has not yet been implemented.
# Areopagus

Areopagus is a small application for ingesting lecture content and making transcripts searchable. This repository currently contains Terraform, GitHub Actions bootstrap, and a private S3 bucket for ingestion uploads.

## Terraform

Terraform uses the existing S3 state bucket `areopagus-terraform-state` with the state key `areopagus/terraform.tfstate` in `us-east-2`. Native S3 state locking is enabled. Authenticate to AWS locally through your normal IAM Identity Center / SSO workflow, then run:

```text
cd terraform
terraform init
terraform plan
terraform apply
```

Terraform creates `areopagus-ingestion-uploads` for files uploaded by the local ingestion script. The bucket blocks all public access and uses Amazon S3-managed server-side encryption (SSE-S3). The script should use your existing AWS IAM Identity Center / SSO credentials; this repository does not create credentials or IAM access for local uploads. After applying, the bucket name is also available as the `ingestion_uploads_bucket_name` Terraform output.

## GitHub Actions

Pull requests targeting `main` run `terraform init` and `terraform plan`; they never apply changes. Pushes to `main`, including merged pull requests, run `terraform init` and `terraform apply`.

Both workflows use GitHub OIDC to assume `arn:aws:iam::242668368155:role/areopagus-github-actions`. They request only `contents: read` and `id-token: write` permissions.
