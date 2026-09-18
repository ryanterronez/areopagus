"""Tests for the downloader Lambda entry point."""

from __future__ import annotations

import unittest
from pathlib import Path
from unittest.mock import patch

from areopagus.lambda_handler import lambda_handler


class LambdaHandlerTests(unittest.TestCase):
    def test_downloads_event_url_to_ephemeral_storage(self) -> None:
        with patch("areopagus.lambda_handler.download_audio", return_value=Path("/tmp/audio.webm")) as download:
            result = lambda_handler({"url": "https://youtube.com/watch?v=video"}, None)

        download.assert_called_once_with(
            "https://youtube.com/watch?v=video", Path("/tmp/areopagus-audio")
        )
        self.assertEqual(
            result,
            {"audio_path": str(Path("/tmp/audio.webm")), "status": "DOWNLOADED"},
        )

    def test_rejects_missing_url(self) -> None:
        with self.assertRaisesRegex(ValueError, "event.url"):
            lambda_handler({}, None)
