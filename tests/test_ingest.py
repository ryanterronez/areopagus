import pytest

from areopagus.ingest import AUDIO_FORMAT, object_key_for_video, video_id_from_metadata


def test_audio_format_prefers_compact_audio_only_streams() -> None:
    assert AUDIO_FORMAT == "bestaudio[abr<=128]/bestaudio"


def test_video_id_from_metadata_returns_youtube_id() -> None:
    assert video_id_from_metadata({"id": "dQw4w9WgXcQ"}) == "dQw4w9WgXcQ"


@pytest.mark.parametrize("metadata", [{}, {"id": "too-short"}, {"id": "invalid/id!"}])
def test_video_id_from_metadata_rejects_invalid_values(metadata: dict[str, object]) -> None:
    with pytest.raises(ValueError):
        video_id_from_metadata(metadata)


def test_object_key_is_predictable_and_scoped_to_the_video() -> None:
    assert object_key_for_video("dQw4w9WgXcQ") == "youtube/dQw4w9WgXcQ/audio"
