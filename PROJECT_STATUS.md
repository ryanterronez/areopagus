# Project status

Terraform manages two application resources in `us-east-2`: the private S3 bucket `areopagus-ingestion-uploads` and the on-demand DynamoDB table `areopagus-video-metadata`. The table uses the stable YouTube video ID (`video_id`, string) as its partition key and holds video and ingestion metadata. The local ingestion script uses the developer's existing AWS IAM Identity Center / SSO credentials.

The bucket blocks all public access and uses SSE-S3 encryption. No application IAM, Lambda, transcription, eventing, or lifecycle resources exist yet.
