"""Lambda entry point for exercising the YouTube downloader runtime."""

from __future__ import annotations

from pathlib import Path
from typing import Any

from audio import download_audio


def lambda_handler(event: dict[str, Any], _context: Any) -> dict[str, str]:
    """Download the requested audio to Lambda's ephemeral storage.

    This intentionally does not persist the audio. Storage and ingestion metadata
    are added in the next application slice.
    """
    url = event.get("url")
    if not isinstance(url, str) or not url:
        raise ValueError("event.url must be a non-empty YouTube URL")

    audio_path = download_audio(url, Path("/tmp/areopagus-audio"))
    return {"audio_path": str(audio_path), "status": "DOWNLOADED"}
