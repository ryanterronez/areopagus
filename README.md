# Areopagus

Areopagus is an application under development. Its first local Python proof of
concept downloads the audio from one YouTube video URL and saves it to disk.

This repository contains application code, tests, Terraform for future
application resources, and GitHub Actions tooling. AWS organization and
governance are managed separately in the `aws-platform` repository.

## Application infrastructure

Terraform configures the first application resources in `us-east-2`: a private
S3 bucket for downloaded lecture audio and an on-demand DynamoDB table for
ingestion metadata. YouTube audio bootstrap runs locally; uploading the audio
to S3 and recording metadata in DynamoDB remain out of scope until the next
ingestion slice.

### Local Terraform

Terraform assumes the local Terraform role by default. After authenticating
your local AWS credentials, initialize the appropriate state backend, then run
Terraform normally:

```cmd
cd terraform
terraform init -backend-config=backend.plan.hcl
terraform plan
```

GitHub Actions sets `assume_local_terraform_role` to `false`, retaining the AWS
roles configured by its workflows. The backend configuration and its
state-access role remain separate from this provider setting. Use the backend
configuration appropriate to the operation; for example, `backend.plan.hcl`
for plan-state access.

## Repository layout

```text
.agents/skills/       # Repository-local agent skills
.github/workflows/    # GitHub Actions workflows
src/areopagus/         # Local downloader source
terraform/            # Areopagus application infrastructure
tests/                # Application tests
```

## Local audio proof of concept

Prerequisites: pyenv with a global Python 3.10 or newer selected, and Deno on
`PATH`. Deno is yt-dlp's JavaScript runtime for current YouTube extraction.
Install it once from Command Prompt:

```cmd
winget install DenoLand.Deno
```

Open a new Command Prompt after installing Deno, then verify it is available:

```cmd
deno --version
```

From the repository root, create a virtual environment with pyenv's selected
Python, activate it, then install the downloader dependency:

```cmd
pyenv exec python -m venv .venv
.venv\Scripts\activate.bat
python -m pip install --upgrade pip
python -m pip install "yt-dlp[default]>=2025.1.15"
```

Always activate `.venv` before running local Python commands for this project.

Download audio by calling `download_audio` with one YouTube video URL. This
prints the saved file path and writes the audio to `downloads/` by default:

```cmd
set PYTHONPATH=src
python -c "from areopagus.audio import download_audio; print(download_audio('https://www.youtube.com/watch?v=VIDEO_ID'))"
```

This POC downloads only the best available audio-only stream and saves it in
its source format. It never falls back to downloading video. The Python install
includes yt-dlp's EJS challenge solver; yt-dlp uses Deno from `PATH` for
YouTube extraction. FFmpeg is not required, and the POC does not transcode to
MP3. Only download videos you are permitted to download and use.
