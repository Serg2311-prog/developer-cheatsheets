"""Учебное приложение для хранения заметок в JSON-файле."""

from notes_app.storage import Note, NotesError, NotesStorage, StorageCorruptedError

__all__ = ["Note", "NotesError", "NotesStorage", "StorageCorruptedError"]
__version__ = "0.1.0"
