#!/usr/bin/env bash
# Шаблон надёжного Bash-скрипта: строгий режим, справка, разбор опций,
# временный каталог с гарантированной очисткой и логирование в stderr.
#
# Запуск:
#   bash examples/bash/safe_script_template.sh -n Сергей -v файл1 файл2
#   bash examples/bash/safe_script_template.sh -h

set -Eeuo pipefail

readonly SCRIPT_NAME="${0##*/}"

usage() {
  cat <<EOF
Использование: $SCRIPT_NAME [-n ИМЯ] [-v] [-h] [АРГУМЕНТЫ...]

  -n ИМЯ   кого поприветствовать (по умолчанию: мир)
  -v       подробный вывод
  -h       показать эту справку
EOF
}

log() { printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*" >&2; }
die() { log "ОШИБКА: $*"; exit 1; }

name="мир"
verbose=0

while getopts ":n:vh" opt; do
  case "$opt" in
    n) name="$OPTARG" ;;
    v) verbose=1 ;;
    h) usage; exit 0 ;;
    :) die "опции -$OPTARG нужен аргумент" ;;
    \?) usage >&2; die "неизвестная опция -$OPTARG" ;;
  esac
done
shift $((OPTIND - 1))

workdir="$(mktemp -d)"
# shellcheck disable=SC2317,SC2329 # cleanup вызывается только через trap EXIT
cleanup() { rm -rf -- "$workdir"; }
trap cleanup EXIT
trap 'log "сбой в строке $LINENO: $BASH_COMMAND"' ERR

(( verbose )) && log "временный каталог: $workdir"

greeting_file="$workdir/greeting.txt"
printf 'Привет, %s!\n' "$name" > "$greeting_file"
cat "$greeting_file"

printf 'Передано позиционных аргументов: %d\n' "$#"
for arg in "$@"; do
  printf '  - %s\n' "$arg"
done

(( verbose )) && log "готово, временный каталог будет удалён"
exit 0
