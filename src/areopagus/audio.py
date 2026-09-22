"""Local YouTube audio download utilities."""

from __future__ import annotations

import os
from pathlib import Path

import yt_dlp


def download_audio(url: str, output_directory: Path = Path("downloads")) -> Path:
    """Download the best available audio-only stream for *url* locally."""
    output_directory.mkdir(parents=True, exist_ok=True)
    deno_path = os.environ.get("AREOPAGUS_DENO_PATH")
    deno_config = {"path": deno_path} if deno_path else {}
    options = {
        "format": "bestaudio/best",
        "outtmpl": str(output_directory / "%(title)s.%(ext)s"),
        "noplaylist": True,
        "js_runtimes": {"deno": deno_config},
    }

    with yt_dlp.YoutubeDL(options) as downloader:
        info = downloader.extract_info(url, download=True)
        return Path(downloader.prepare_filename(info))
