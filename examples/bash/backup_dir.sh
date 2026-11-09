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
name="$(basename -- "$src_abs")"
archive="$dest_dir/${name}-$(date +%Y%m%d-%H%M%S).tar.gz"

if [[ -e "$archive" ]]; then
  echo "Архив уже существует, не перезаписываю: $archive" >&2
  exit 1
fi

tar -czf "$archive" -C "$(dirname -- "$src_abs")" "$name"

echo "Создан архив: $archive"
echo "Размер: $(du -h "$archive" | cut -f1)"
echo "Файлов внутри: $(tar -tzf "$archive" | grep -vc '/$')"
