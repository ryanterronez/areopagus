"""Download YouTube audio locally and upload it to the Areopagus S3 bucket."""

from __future__ import annotations

import argparse
import tempfile
from pathlib import Path
from typing import Any

import boto3
from boto3.exceptions import S3UploadFailedError
from botocore.exceptions import BotoCoreError, ClientError
import yt_dlp


# This is the value exposed by Terraform's ingestion_uploads_bucket_name output.
DEFAULT_INGESTION_BUCKET = "areopagus-app-ingestion-uploads"
AWS_REGION = "us-east-2"
# A lecture transcription source does not need the largest available audio stream.
AUDIO_FORMAT = "bestaudio[abr<=128]/bestaudio"


def video_id_from_metadata(metadata: dict[str, Any]) -> str:
    """Return the stable YouTube video ID supplied by yt-dlp metadata."""
    video_id = metadata.get("id")
    if not isinstance(video_id, str) or not video_id:
        raise ValueError("yt-dlp did not return a YouTube video ID")
    if len(video_id) != 11 or not all(char.isalnum() or char in "-_" for char in video_id):
        raise ValueError(f"yt-dlp returned an invalid YouTube video ID: {video_id!r}")
    return video_id


def object_key_for_video(video_id: str) -> str:
    """Build the single, predictable object key used for a video's audio."""
    # Validate here too, so callers cannot accidentally form unsafe object keys.
    validated_video_id = video_id_from_metadata({"id": video_id})
    return f"youtube/{validated_video_id}/audio"


def download_audio(url: str, workdir: Path) -> tuple[str, Path]:
    """Download one YouTube audio stream into *workdir* without transcoding it."""
    options = {
        "format": AUDIO_FORMAT,
        "noplaylist": True,
        "outtmpl": str(workdir / "audio.%(ext)s"),
        "quiet": True,
        "no_warnings": True,
    }
    try:
        with yt_dlp.YoutubeDL(options) as downloader:
            metadata = downloader.extract_info(url, download=True)
    except yt_dlp.utils.YoutubeDLError as error:
        raise RuntimeError(f"YouTube audio download failed: {error}") from error

    if metadata is None:
        raise RuntimeError("YouTube audio download failed: yt-dlp returned no metadata")
    video_id = video_id_from_metadata(metadata)
    audio_files = [
        path
        for path in workdir.glob("audio.*")
        if path.is_file() and not path.name.endswith(".part")
    ]
    if len(audio_files) != 1:
        raise RuntimeError("YouTube audio download failed: yt-dlp did not produce one audio file")
    audio_file = audio_files[0]
    return video_id, audio_file


def upload_audio(audio_file: Path, bucket: str, object_key: str) -> None:
    """Upload audio using the normal boto3 credential provider chain."""
    try:
        client = boto3.client("s3", region_name=AWS_REGION)
        client.upload_file(
            str(audio_file),
            bucket,
            object_key,
            ExtraArgs={"ContentType": "application/octet-stream"},
        )
    except (BotoCoreError, ClientError, S3UploadFailedError) as error:
        raise RuntimeError(f"S3 upload failed for s3://{bucket}/{object_key}: {error}") from error


def ingest(url: str, bucket: str) -> tuple[str, str]:
    """Download a video audio track, upload it, and return its ID and object key."""
    with tempfile.TemporaryDirectory(prefix="areopagus-ingest-") as temp_directory:
        video_id, audio_file = download_audio(url, Path(temp_directory))
        object_key = object_key_for_video(video_id)
        upload_audio(audio_file, bucket, object_key)
    return video_id, object_key


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Download YouTube audio locally and upload it to Areopagus S3."
    )
    parser.add_argument("url", help="YouTube video URL")
    parser.add_argument(
        "--bucket",
        default=DEFAULT_INGESTION_BUCKET,
        help=f"S3 ingestion bucket (default: {DEFAULT_INGESTION_BUCKET})",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    try:
        video_id, object_key = ingest(args.url, args.bucket)
    except (RuntimeError, ValueError) as error:
        raise SystemExit(f"Ingestion failed: {error}") from error
    print(f"Uploaded video_id={video_id} bucket={args.bucket} key={object_key}")


if __name__ == "__main__":
    main()
