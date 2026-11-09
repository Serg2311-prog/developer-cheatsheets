#!/usr/bin/env bash
# Статистика по access-логу в формате Common Log Format с помощью пайпов:
# awk, sort, uniq, head, wc.
#
# Запуск:
#   bash examples/bash/log_stats.sh                       # встроенный пример access.log
#   bash examples/bash/log_stats.sh /var/log/nginx/access.log

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
log_file="${1:-$script_dir/access.log}"

[[ -r "$log_file" ]] || { echo "Не могу прочитать файл: $log_file" >&2; exit 1; }

total=$(wc -l < "$log_file")
echo "Всего запросов: $total"

echo
echo "Топ-3 IP-адреса:"
awk '{print $1}' "$log_file" | sort | uniq -c | sort -rn | head -n 3

echo
echo "Коды ответов:"
awk '{print $9}' "$log_file" | sort | uniq -c | sort -k2,2n

echo
errors=$(awk '$9 >= 500' "$log_file" | wc -l)
echo "Ошибок сервера (5xx): $errors"

echo
echo "Самые запрашиваемые пути:"
awk '{print $7}' "$log_file" | sort | uniq -c | sort -rn | head -n 3
