"""Create the Lambda function and Deno layer ZIP files."""

from __future__ import annotations

import argparse
import os
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path


REPOSITORY_ROOT = Path(__file__).resolve().parents[1]
LAMBDA_SOURCE = REPOSITORY_ROOT / "src" / "lambda"
OUTPUT_DIR = REPOSITORY_ROOT / "terraform" / "build"


def create_zip(source: Path, destination: Path) -> None:
    """Write source contents to a ZIP while preserving executable modes."""
    with zipfile.ZipFile(destination, "w", zipfile.ZIP_DEFLATED) as archive:
        for path in source.rglob("*"):
            if path.is_file():
                archive.write(path, path.relative_to(source))


def build(deno_path: Path) -> None:
    """Build the function ZIP and the Deno layer ZIP."""
    if not deno_path.is_file():
        raise FileNotFoundError(f"Deno executable not found: {deno_path}")

    shutil.rmtree(OUTPUT_DIR, ignore_errors=True)
    OUTPUT_DIR.mkdir(parents=True)

    staging_directory = OUTPUT_DIR / "staging"
    try:
        function_root = staging_directory / "function"
        function_root.mkdir(parents=True)
        pip_temp_directory = staging_directory / "pip-temp"
        pip_temp_directory.mkdir()
        pip_environment = os.environ | {
            "TEMP": str(pip_temp_directory),
            "TMP": str(pip_temp_directory),
            "TMPDIR": str(pip_temp_directory),
        }
        subprocess.run(
            [
                sys.executable,
                "-m",
                "pip",
                "install",
                "--disable-pip-version-check",
                "--no-compile",
                "--target",
                str(function_root),
                "yt-dlp[default]>=2025.1.15",
            ],
            check=True,
            env=pip_environment,
        )
        shutil.copytree(LAMBDA_SOURCE, function_root, dirs_exist_ok=True)
        create_zip(function_root, OUTPUT_DIR / "areopagus-downloader.zip")

        layer_root = staging_directory / "layer"
        deno_destination = layer_root / "bin" / "deno"
        deno_destination.parent.mkdir(parents=True)
        shutil.copy2(deno_path, deno_destination)
        deno_destination.chmod(0o755)
        create_zip(layer_root, OUTPUT_DIR / "areopagus-deno-layer.zip")
    finally:
        shutil.rmtree(staging_directory, ignore_errors=True)


def main() -> None:
    parser = argparse.ArgumentParser(description="Build Areopagus Lambda ZIP files.")
    parser.add_argument("--deno-path", required=True, type=Path)
    args = parser.parse_args()
    build(args.deno_path.resolve())


if __name__ == "__main__":
    main()
