# Project status

Terraform manages one application resource: the private S3 bucket `areopagus-ingestion-uploads` in `us-east-2`. It is for files uploaded by the local ingestion script using the developer's existing AWS IAM Identity Center / SSO credentials.

The bucket blocks all public access and uses SSE-S3 encryption. No application IAM, Lambda, transcription, database, eventing, or lifecycle resources exist yet.
