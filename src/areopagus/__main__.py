"""Command-line entry point for the local audio proof of concept."""

from __future__ import annotations

import argparse
from pathlib import Path

from .audio import download_audio


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Download the best available audio from a YouTube video."
    )
    parser.add_argument("url", help="YouTube video URL")
    parser.add_argument(
        "--output-dir", type=Path, default=Path("downloads"),
        help="Directory for the downloaded audio (default: downloads)",
    )
    args = parser.parse_args()
    print(download_audio(args.url, args.output_dir))


if __name__ == "__main__":
    main()
