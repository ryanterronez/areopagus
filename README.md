# Areopagus

Areopagus is an application under development. Its first local Python proof of
concept downloads the audio from one YouTube video URL and saves it to disk.

This repository contains application code, tests, Terraform for future
application resources, and GitHub Actions tooling. AWS organization and
governance are managed separately in the `aws-platform` repository.

## Application infrastructure

Terraform configures the first application resources in `us-east-2`: a private
S3 bucket for downloaded lecture audio, an on-demand DynamoDB table for
ingestion metadata, and a private Lambda runtime test for the downloader.
The Lambda uses a standard Python ZIP package plus a small Deno Lambda layer;
it currently downloads only into `/tmp` and does not persist audio. S3 upload,
DynamoDB ingestion metadata, event sources, and application integrations remain
out of scope until later slices.

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
src/lambda/            # Lambda handler and downloader source
scripts/build_lambda.py # Lambda ZIP and layer builder
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
set PYTHONPATH=src\lambda
python -c "from audio import download_audio; print(download_audio('https://www.youtube.com/watch?v=VIDEO_ID'))"
```

This POC downloads only the best available audio-only stream and saves it in
its source format. It never falls back to downloading video. The Python install
includes yt-dlp's EJS challenge solver; yt-dlp uses Deno from `PATH` for
YouTube extraction. FFmpeg is not required, and the POC does not transcode to
MP3. Only download videos you are permitted to download and use.

## Lambda downloader package

The `Deploy Lambda downloader` workflow builds `src/lambda` and the Deno layer on
Ubuntu, uploads them to a private versioned S3 artifact bucket, and deploys the
Lambda code through the AWS CLI. The generated archives are intentionally ignored under
`terraform/build/`; do not commit them. The function runs Python 3.13 on x86_64
with 1024 MB memory, a 15-minute timeout, and 2048 MB of ephemeral storage for
the downloaded source audio. Its execution role can write only to its dedicated
CloudWatch log group. It has no S3 or DynamoDB permissions yet.

The artifact bucket is managed in the main `terraform/` root and state. Later
Lambda workflow runs update only the code and Deno layer through the AWS CLI.

For a direct runtime smoke test after deployment, use this exact JSON payload in
the Lambda console's **Test event** editor:

```json
{"url":"https://www.youtube.com/watch?v=sanBMiA1HBY"}
```

From Command Prompt, save that exact payload as `payload.json`, then invoke the
function with:

```cmd
aws lambda invoke --region us-east-2 --function-name areopagus-downloader --cli-binary-format raw-in-base64-out --payload fileb://payload.json response.json
```

The returned path is in Lambda ephemeral storage and is not durable. Only invoke
the downloader for videos you are permitted to download and use.
