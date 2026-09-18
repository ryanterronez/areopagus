# Project status

## Current phase

Local proof of concept, with the product direction defined and its first
application storage resources configured in Terraform. The repository can
download audio from one YouTube video URL to local disk; the application is not
yet deployed.

## Implemented in the repository

- Packaged Python CLI and `download_audio` utility using `yt-dlp` and Deno.
- Local output handling for audio-only downloads, with no video fallback or
  transcoding requirement.
- Repository scaffolding, dependency automation, and pull-request workflows
  for Python syntax and Terraform validation/plan.
- A Terraform apply workflow runs for pushes to `main` that change files under
  `terraform/`.
- Terraform remote-state backend and separate plan/apply access roles are
  configured. AWS organization and governance remain in `aws-platform`.
- Terraform configuration for a private S3 lecture-audio bucket and an
  on-demand DynamoDB ingestion-metadata table, including outputs for upcoming
  Lambda and IAM work.

## Defined direction, not yet implemented

- Ingestion is a one-time bootstrap operation, not the steady-state workload.
  A YouTube video should be deduplicated before ingesting, preferably by stable
  YouTube video ID.
- The primary experience is search across indexed lecture transcripts, with
  timestamp links back to the source video.
- Slack is the intended authentication and authorization mechanism. Only an
  admin/allowlisted Slack user can trigger ingestion; cohort users can search.
- Application infrastructure belongs here; organization and governance remain
  in `aws-platform`.

## Current work

Add the next application infrastructure slice: IAM and the lecture-ingestion
Lambda that consumes the existing S3 and DynamoDB outputs.

## Next steps

- Add automated behavior tests for the downloader and CLI.
- Add IAM and the lecture-ingestion Lambda.
- Design and implement transcript ingestion, indexing, search, and Slack
  access-control.

## Key decisions

- Keep downloaded audio in the source format; do not download video or require
  FFmpeg for conversion.
- Use Deno as `yt-dlp`'s JavaScript runtime for current YouTube extraction.
- Keep application infrastructure in this repository and organization/governance
  infrastructure in the separate `aws-platform` repository.
- Use an S3 Terraform backend in `us-east-2`, with distinct plan and apply
  roles.
- Store downloaded lecture audio in a private, versioned S3 bucket with
  lifecycle cleanup for incomplete uploads and noncurrent object versions.
- Use an on-demand DynamoDB table with `pk`/`sk` keys for ingestion metadata.
  A video is identified by `VIDEO#{youtube_video_id}` / `METADATA`; future
  course and professor relationships will use adjacency-list items.

## Open questions / blockers

- The detailed ingestion workflow, IAM permissions, and transcript-search
  architecture are still to be selected.
