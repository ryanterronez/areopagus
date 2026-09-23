# Project status

Terraform defines two application resources in `us-east-2`: the private S3 bucket `areopagus-app-ingestion-uploads` and the on-demand DynamoDB table `areopagus-video-metadata`. The table uses the stable YouTube video ID (`video_id`, string) as its partition key and holds video and ingestion metadata. The local ingestion script uses the developer's existing AWS IAM Identity Center / SSO credentials.

The bucket blocks all public access and uses unauthenticated yt-dlp access to download a compact (preferably 128 kbps or lower) YouTube audio stream without transcoding it, then uploads `youtube/<video_id>/audio` through the developer's normal AWS SSO credential chain. No application IAM, Lambda, transcription, eventing, or lifecycle resources exist yet.
