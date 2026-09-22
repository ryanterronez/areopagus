"""Tests for downloader runtime configuration."""

from __future__ import annotations

import os
import unittest
from pathlib import Path
from unittest.mock import patch

from areopagus.audio import download_audio


class _Downloader:
    options: dict[str, object]

    def __init__(self, options: dict[str, object]) -> None:
        type(self).options = options

    def __enter__(self) -> _Downloader:
        return self

    def __exit__(self, *_args: object) -> None:
        return None

    def extract_info(self, _url: str, download: bool) -> dict[str, str]:
        self.download = download
        return {"title": "lecture", "ext": "webm"}

    def prepare_filename(self, _info: dict[str, str]) -> str:
        return str(Path(self.options["outtmpl"]).with_name("lecture.webm"))


class DownloadAudioTests(unittest.TestCase):
    def test_uses_explicit_deno_path_when_configured(self) -> None:
        with patch.dict(os.environ, {"AREOPAGUS_DENO_PATH": "/opt/bin/deno"}):
            with patch("areopagus.audio.yt_dlp.YoutubeDL", _Downloader):
                download_audio("https://youtube.com/watch?v=video", Path.cwd())

        self.assertEqual(
            _Downloader.options["js_runtimes"],
            {"deno": {"path": "/opt/bin/deno"}},
        )

    def test_uses_path_discovery_for_local_downloads(self) -> None:
        with patch.dict(os.environ, {}, clear=True):
            with patch("areopagus.audio.yt_dlp.YoutubeDL", _Downloader):
                download_audio("https://youtube.com/watch?v=video", Path.cwd())

        self.assertEqual(_Downloader.options["js_runtimes"], {"deno": {}})
