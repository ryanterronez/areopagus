# Project status

Terraform still defines two unused application resources in `us-east-2`: the private S3 bucket `areopagus-app-ingestion-uploads` and the on-demand DynamoDB table `areopagus-video-metadata`. They are not used by the current local-only downloader.

The local downloader uses unauthenticated yt-dlp access to download compact (preferably 128 kbps or lower) audio by default. It can also download a video-only stream or combined audio and video at a selected resolution, or accept an exact yt-dlp format selector. Combined downloads normally require local FFmpeg for stream merging. Files are retained in the gitignored `downloads` directory as `<video-title>.<extension>`. It has no AWS credential, S3, DynamoDB, IAM, Lambda, transcription, eventing, or lifecycle dependency.

Pull request CI validates Terraform with the remote backend disabled and without AWS credentials. GitHub Actions does not deploy infrastructure; Terraform apply remains a manual local operation.
