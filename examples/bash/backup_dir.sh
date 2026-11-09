#!/usr/bin/env bash
# Создаёт архив каталога с отметкой времени. Ничего не удаляет и не перезаписывает.
#
# Запуск:
#   bash examples/bash/backup_dir.sh ИСТОЧНИК [КАТАЛОГ_ДЛЯ_АРХИВОВ]
#   bash examples/bash/backup_dir.sh examples/bash /tmp/backups
#
# Проверить содержимое архива:  tar -tzf АРХИВ.tar.gz
# Распаковать в каталог:         mkdir -p restore && tar -xzf АРХИВ.tar.gz -C restore

set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Использование: ${0##*/} ИСТОЧНИК [КАТАЛОГ_ДЛЯ_АРХИВОВ]" >&2
  exit 2
fi

src="${1%/}"
dest_dir="${2:-./backups}"

[[ -d "$src" ]] || { echo "Каталог не найден: $src" >&2; exit 1; }
mkdir -p -- "$dest_dir"

src_abs="$(cd -- "$src" && pwd)"
dest_abs="$(cd -- "$dest_dir" && pwd)"
name="$(basename -- "$src_abs")"

if [[ "$dest_abs" == "$src_abs" ]]; then
  echo "Каталог архивов не должен совпадать с источником: $dest_abs" >&2
  exit 1
fi

archive="$dest_abs/${name}-$(date +%Y%m%d-%H%M%S).tar.gz"

if [[ -e "$archive" ]]; then
  echo "Архив уже существует, не перезаписываю: $archive" >&2
  exit 1
fi

tar_excludes=()
if [[ "$dest_abs" == "$src_abs"/* ]]; then
  rel="${dest_abs#"$src_abs"/}"
  tar_excludes=(--exclude="$name/$rel")
fi

tar -czf "$archive" "${tar_excludes[@]}" -C "$(dirname -- "$src_abs")" "$name"

echo "Создан архив: $archive"
echo "Размер: $(du -h "$archive" | cut -f1)"
echo "Файлов внутри: $(tar -tzf "$archive" | grep -vc '/$')"
