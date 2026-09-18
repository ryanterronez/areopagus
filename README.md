# Areopagus

Areopagus is an application under development. Its first local Python proof of
concept downloads the audio from one YouTube video URL and saves it to disk.

This repository contains application code, tests, Terraform for future
application resources, and GitHub Actions tooling. AWS organization and
governance are managed separately in the `aws-platform` repository.

## Repository layout

```text
.agents/skills/       # Repository-local agent skills
.github/workflows/    # GitHub Actions workflows
src/                  # Python application code
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
Python, activate it, then install the package:

```cmd
pyenv exec python -m venv .venv
.venv\Scripts\activate.bat
python -m pip install --upgrade pip
python -m pip install -e .
```

Always activate `.venv` before running local Python commands for this project.

Download audio by passing a single YouTube video URL. The command prints the
saved file path and writes the audio to `downloads/` by default:

```cmd
areopagus "https://www.youtube.com/watch?v=VIDEO_ID"
```

Use `--output-dir` to choose another destination:

```cmd
areopagus "https://www.youtube.com/watch?v=VIDEO_ID" --output-dir .\audio
```

This POC downloads only the best available audio-only stream and saves it in
its source format. It never falls back to downloading video. The Python install
includes yt-dlp's EJS challenge solver; yt-dlp uses Deno from `PATH` for
YouTube extraction. FFmpeg is not required, and the POC does not transcode to
MP3. Only download videos you are permitted to download and use.
