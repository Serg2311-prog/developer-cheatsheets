"""Хранение заметок в JSON-файле: pathlib, json, dataclasses и собственные исключения."""

from __future__ import annotations

import json
from collections import Counter
from dataclasses import asdict, dataclass, field
from datetime import datetime, timezone
from pathlib import Path


class NotesError(Exception):
    """Базовая ошибка приложения: её удобно ловить одним except."""


class StorageCorruptedError(NotesError):
    """Файл с заметками есть, но его содержимое не удалось разобрать."""


def _now_iso() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


@dataclass
class Note:
    text: str
    tags: list[str] = field(default_factory=list)
    created_at: str = field(default_factory=_now_iso)

    def __post_init__(self) -> None:
        self.text = self.text.strip()
        if not self.text:
            raise ValueError("Текст заметки не может быть пустым")
        self.tags = sorted({tag.strip().lower() for tag in self.tags if tag.strip()})


class NotesStorage:
    """Читает и записывает список заметок в один JSON-файл."""

    def __init__(self, path: str | Path) -> None:
        self.path = Path(path)

    def load(self) -> list[Note]:
        if not self.path.exists():
            return []
        try:
            raw = json.loads(self.path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            raise StorageCorruptedError(f"Файл {self.path} содержит некорректный JSON: {exc}") from exc
        if not isinstance(raw, list):
            raise StorageCorruptedError(f"Ожидался JSON-массив в {self.path}, получено: {type(raw).__name__}")
        try:
            return [Note(**item) for item in raw]
        except (TypeError, ValueError) as exc:
            raise StorageCorruptedError(f"Некорректная запись в {self.path}: {exc}") from exc

    def save(self, notes: list[Note]) -> None:
        self.path.parent.mkdir(parents=True, exist_ok=True)
        payload = json.dumps([asdict(note) for note in notes], ensure_ascii=False, indent=2)
        # Пишем во временный файл и атомарно подменяем: при сбое старые данные не пострадают.
        tmp_path = self.path.with_name(self.path.name + ".tmp")
        tmp_path.write_text(payload + "\n", encoding="utf-8")
        tmp_path.replace(self.path)

    def add(self, text: str, tags: list[str] | tuple[str, ...] = ()) -> Note:
        notes = self.load()
        note = Note(text=text, tags=list(tags))
        notes.append(note)
        self.save(notes)
        return note

    def search(self, *, tag: str | None = None, query: str | None = None) -> list[Note]:
        result = self.load()
        if tag is not None:
            result = [note for note in result if tag.lower() in note.tags]
        if query is not None:
            needle = query.casefold()
            result = [note for note in result if needle in note.text.casefold()]
        return result

    def tag_stats(self) -> Counter[str]:
        return Counter(tag for note in self.load() for tag in note.tags)
