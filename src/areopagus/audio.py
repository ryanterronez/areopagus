"""Download audio from YouTube videos."""

from __future__ import annotations

from pathlib import Path

import yt_dlp


def download_audio(url: str, output_dir: Path | str = "downloads") -> Path:
    """Download the best available audio for a YouTube URL and return its path.

    The source audio is retained in its available format, so this does not require
    FFmpeg. ``yt-dlp`` raises an exception when the URL cannot be downloaded.
    """
    destination = Path(output_dir)
    destination.mkdir(parents=True, exist_ok=True)
    options = {
        "format": "bestaudio",
        "js_runtimes": {"deno": {}},
        "noplaylist": True,
        "outtmpl": str(destination / "%(title)s.%(ext)s"),
        "quiet": True,
    }
    with yt_dlp.YoutubeDL(options) as downloader:
        info = downloader.extract_info(url, download=True)
        return Path(downloader.prepare_filename(info))
