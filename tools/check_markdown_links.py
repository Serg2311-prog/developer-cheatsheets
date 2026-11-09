"""Проверка ссылок в Markdown-файлах репозитория.

По умолчанию проверяет только внутренние ссылки: существование файлов и каталогов
и якоря заголовков по правилам GitHub (включая кириллицу). С флагом --external
дополнительно запрашивает внешние URL.

Запуск из корня репозитория:
    python tools/check_markdown_links.py
    python tools/check_markdown_links.py --external
"""

from __future__ import annotations

import argparse
import re
import sys
import urllib.error
import urllib.parse
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

SKIP_DIRS = {".git", ".venv", "venv", "node_modules", ".pytest_cache", ".audit-tmp"}
FENCE_RE = re.compile(r"^(`{3,}|~{3,}).*?^\1[ \t]*$", re.M | re.S)
INLINE_CODE_RE = re.compile(r"(`+)(?:(?!\1).)+?\1", re.S)
HEADING_RE = re.compile(r"^(#{1,6})[ \t]+(.+?)[ \t]*#*[ \t]*$", re.M)
LINK_RE = re.compile(r"!?\[(?:[^\[\]]|\[[^\]]*\])*\]\(\s*<?([^)\s>]+)>?(?:\s+\"[^\"]*\")?\s*\)")


def markdown_files(root: Path) -> list[Path]:
    return sorted(
        p for p in root.rglob("*.md") if not SKIP_DIRS.intersection(p.relative_to(root).parts)
    )


def strip_code(text: str) -> str:
    return INLINE_CODE_RE.sub("", FENCE_RE.sub("", text))


def github_slug(heading: str) -> str:
    text = re.sub(r"`|\*\*|__", "", heading.strip().lower())
    text = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", text)
    text = re.sub(r"[^\w\- ]", "", text)
    return text.replace(" ", "-")


def heading_anchors(text: str) -> set[str]:
    anchors: set[str] = set()
    counts: dict[str, int] = {}
    for match in HEADING_RE.finditer(FENCE_RE.sub("", text)):
        slug = github_slug(match.group(2))
        if slug in counts:
            counts[slug] += 1
            anchors.add(f"{slug}-{counts[slug]}")
        else:
            counts[slug] = 0
            anchors.add(slug)
    return anchors


def check_internal(root: Path, files: list[Path]) -> tuple[list[str], int, set[str]]:
    anchors = {f.resolve(): heading_anchors(f.read_text(encoding="utf-8")) for f in files}
    errors: list[str] = []
    external: set[str] = set()
    checked = 0
    for f in files:
        for target in LINK_RE.findall(strip_code(f.read_text(encoding="utf-8"))):
            if target.startswith(("http://", "https://")):
                external.add(target)
                continue
            if target.startswith("mailto:"):
                continue
            checked += 1
            path_part, _, fragment = target.partition("#")
            resolved = (f.parent / urllib.parse.unquote(path_part)).resolve() if path_part else f.resolve()
            where = f.relative_to(root).as_posix()
            if not resolved.exists():
                errors.append(f"{where}: файл не найден: {target}")
            elif fragment and resolved.suffix == ".md":
                if urllib.parse.unquote(fragment) not in anchors.get(resolved, set()):
                    errors.append(f"{where}: якорь не найден: {target}")
    return errors, checked, external


def fetch_status(url: str) -> tuple[str, str]:
    request = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (link-check)"})
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            return url, str(response.status)
    except urllib.error.HTTPError as exc:
        return url, f"HTTP {exc.code}"
    except Exception as exc:  # noqa: BLE001 — для отчёта нужна любая сетевая ошибка
        return url, f"ошибка: {exc}"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parent.parent)
    parser.add_argument("--external", action="store_true", help="проверить и внешние ссылки")
    args = parser.parse_args()

    root = args.root.resolve()
    files = markdown_files(root)
    errors, checked, external = check_internal(root, files)

    if args.external:
        with ThreadPoolExecutor(max_workers=8) as pool:
            for url, status in sorted(pool.map(fetch_status, sorted(external))):
                if status != "200":
                    errors.append(f"внешняя ссылка: {url} -> {status}")

    for error in errors:
        print(f"ОШИБКА: {error}")
    scope = f", внешних ссылок: {len(external)}" if args.external else ""
    print(f"Markdown-файлов: {len(files)}, внутренних ссылок: {checked}{scope}, ошибок: {len(errors)}")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
