import json

import pytest

from notes_app import Note, NotesStorage, StorageCorruptedError


@pytest.fixture
def storage(tmp_path):
    """Отдельное хранилище во временном каталоге для каждого теста."""
    return NotesStorage(tmp_path / "data" / "notes.json")


def test_missing_file_means_no_notes(storage):
    assert storage.load() == []


def test_add_creates_file_and_roundtrips(storage):
    storage.add("  Купить молоко  ", ["Дом", "дом", " покупки "])

    assert storage.path.exists()
    [note] = storage.load()
    assert note.text == "Купить молоко"
    assert note.tags == ["дом", "покупки"]


def test_file_is_readable_utf8_json(storage):
    storage.add("Привет")

    content = storage.path.read_text(encoding="utf-8")
    assert "Привет" in content
    assert json.loads(content)[0]["text"] == "Привет"


@pytest.mark.parametrize("text", ["", "   ", "\n\t"])
def test_empty_text_is_rejected(text):
    with pytest.raises(ValueError, match="пустым"):
        Note(text=text)


@pytest.mark.parametrize(
    "content",
    ["{не json", '{"text": "объект вместо массива"}', '[{"unknown_field": 1}]'],
)
def test_corrupted_file_raises_domain_error(storage, content):
    storage.path.parent.mkdir(parents=True)
    storage.path.write_text(content, encoding="utf-8")

    with pytest.raises(StorageCorruptedError):
        storage.load()


def test_search_by_tag_and_query(storage):
    storage.add("Купить молоко", ["дом"])
    storage.add("Починить кран", ["дом"])
    storage.add("Сдать отчёт", ["работа"])

    assert [n.text for n in storage.search(tag="ДОМ")] == ["Купить молоко", "Починить кран"]
    assert [n.text for n in storage.search(query="отчёт")] == ["Сдать отчёт"]
    assert storage.search(tag="дом", query="отчёт") == []


def test_tag_stats(storage):
    storage.add("a", ["x", "y"])
    storage.add("b", ["x"])

    assert storage.tag_stats().most_common() == [("x", 2), ("y", 1)]
