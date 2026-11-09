"""Командная строка приложения заметок на argparse.

Запуск из каталога examples/python:
    python -m notes_app --file notes.json add "Купить молоко" --tag дом
    python -m notes_app --file notes.json list --tag дом
    python -m notes_app --file notes.json tags
"""

from __future__ import annotations

import argparse
import sys
from collections.abc import Sequence

from notes_app.storage import Note, NotesError, NotesStorage


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="notes_app", description="Заметки в JSON-файле")
    parser.add_argument("--file", default="notes.json", help="путь к файлу заметок (по умолчанию notes.json)")
    commands = parser.add_subparsers(dest="command", required=True)

    add = commands.add_parser("add", help="добавить заметку")
    add.add_argument("text", help="текст заметки")
    add.add_argument("--tag", action="append", default=[], help="тег (можно указать несколько раз)")

    list_cmd = commands.add_parser("list", help="показать заметки")
    list_cmd.add_argument("--tag", help="только заметки с этим тегом")
    list_cmd.add_argument("--query", help="поиск подстроки без учёта регистра")

    commands.add_parser("tags", help="статистика по тегам")
    return parser


def format_note(index: int, note: Note) -> str:
    tags = f" [{', '.join(note.tags)}]" if note.tags else ""
    return f"{index}. {note.text}{tags}"


def main(argv: Sequence[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    storage = NotesStorage(args.file)

    try:
        if args.command == "add":
            note = storage.add(args.text, args.tag)
            print(f"Добавлено: {format_note(len(storage.load()), note)}")
        elif args.command == "list":
            notes = storage.search(tag=args.tag, query=args.query)
            if not notes:
                print("Заметок не найдено")
            for index, note in enumerate(notes, start=1):
                print(format_note(index, note))
        elif args.command == "tags":
            for tag, count in storage.tag_stats().most_common():
                print(f"{tag}: {count}")
    except (NotesError, ValueError) as exc:
        print(f"Ошибка: {exc}", file=sys.stderr)
        return 1
    return 0
