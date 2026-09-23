# Areopagus

Areopagus is a small application for ingesting lecture content and making transcripts searchable. Its first application capability downloads a YouTube video's audio on your local Windows machine and uploads that audio stream to the private ingestion S3 bucket.

## Local YouTube ingestion

Prerequisites:

- Python selected by `pyenv`
- AWS IAM Identity Center / SSO credentials already logged in and permitted to upload to `areopagus-app-ingestion-uploads`

Create and activate the project environment, then install dependencies:

```text
pyenv exec python -m venv .venv
.venv\Scripts\activate.bat
python -m pip install -r requirements-dev.txt
```

Run this from the repository root in Windows Command Prompt, replacing the URL and cookies path:

```text
python -m areopagus.ingest "https://www.youtube.com/watch?v=VIDEO_ID"
```

The CLI uses unauthenticated yt-dlp access and prefers an audio-only stream at or below 128 kbps, falling back to the best audio-only stream only when no such format is available. This keeps lecture uploads compact without transcoding. It does not download video, and FFmpeg is not required. It writes the audio stream to a temporary directory and removes it after a successful upload (and when the command exits after a failure). Videos that require a signed-in YouTube account are outside this local ingestion slice and will fail clearly.

The uploaded object is `youtube/<stable-youtube-video-id>/audio`, for example `youtube/dQw4w9WgXcQ/audio`. Its contents are the compact audio format YouTube serves for that video, commonly Opus or M4A. The CLI derives that stable ID from yt-dlp's YouTube metadata and prints the video ID, bucket, and object key only after S3 reports a successful upload. The default bucket is the existing Terraform output value, `areopagus-app-ingestion-uploads`; use `--bucket NAME` only when intentionally targeting a different bucket.

## Terraform

Terraform uses the existing S3 state bucket `areopagus-terraform-state` with the state key `areopagus/terraform.tfstate` in `us-east-2`. Native S3 state locking is enabled. Authenticate to AWS locally through your normal IAM Identity Center / SSO workflow, then run:

```text
cd terraform
terraform init
terraform plan
terraform apply
```

Terraform creates `areopagus-app-ingestion-uploads` for files uploaded by the local ingestion script. The bucket blocks all public access and uses Amazon S3-managed server-side encryption (SSE-S3). Terraform also creates `areopagus-video-metadata`, an on-demand DynamoDB table for video and ingestion metadata, keyed by the stable YouTube video ID (`video_id`). The script uses your existing AWS IAM Identity Center / SSO credentials through boto3's normal credential provider chain; this repository does not create credentials or IAM access for local uploads. After applying, the resource names are available as the `ingestion_uploads_bucket_name` and `video_metadata_table_name` Terraform outputs.

## GitHub Actions

Pull requests targeting `main` run `terraform init` and `terraform plan`; they never apply changes. Pushes to `main`, including merged pull requests, run `terraform init` and `terraform apply`.

Both workflows use GitHub OIDC to assume `arn:aws:iam::242668368155:role/areopagus-github-actions`. They request only `contents: read` and `id-token: write` permissions.
