# Areopagus

Areopagus is a small application for ingesting lecture content and making transcripts searchable. Its current capability downloads YouTube media to your local Windows machine.

## Local YouTube media download

Prerequisites:

- Python selected by `pyenv`

Create and activate the project environment, then install dependencies:

```text
pyenv exec python -m venv .venv
.venv\Scripts\activate.bat
python -m pip install -r requirements-dev.txt
```

Run this from the repository root in Windows Command Prompt, replacing the URL:

```text
python -m src.ingest "https://www.youtube.com/watch?v=VIDEO_ID"
```

By default the CLI downloads compact audio: it prefers an audio-only stream at or below 128 kbps, falling back to the best audio-only stream when needed. Downloads are retained in the gitignored `downloads` directory as `<video-title>.<extension>`, commonly Opus or M4A. yt-dlp makes title-based filenames safe for Windows. To select another directory, add `--output-dir PATH`.

Select the media type with `--media`:

```text
python -m src.ingest "URL" --media audio --quality best
python -m src.ingest "URL" --media video --quality 720p
python -m src.ingest "URL" --media both --quality 1080p
```

`audio` downloads only audio; `video` downloads only the video stream; and `both` downloads and merges audio and video into one file. Video quality accepts `144p`, `240p`, `360p`, `480p`, `720p`, `1080p`, or `best`; `compact` means at most 480p for video. Audio accepts `compact` or `best` (a numeric video quality also selects the best audio stream). For exact yt-dlp stream control, use `--format`, which overrides `--quality`, for example:

```text
python -m src.ingest "URL" --media both --format "bv*[ext=mp4]+ba[ext=m4a]"
```

`both` commonly needs [FFmpeg](https://ffmpeg.org/download.html) available on `PATH` because YouTube usually serves audio and video as separate streams. Audio-only and video-only downloads do not require it. Videos that require a signed-in YouTube account are outside this local download slice and will fail clearly.

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

Pull requests targeting `main` initialize Terraform without the remote backend and run `terraform validate`. GitHub Actions does not receive AWS credentials or deploy infrastructure; Terraform apply remains a manual local operation.
