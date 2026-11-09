#!/usr/bin/env bash
# Проверяет все примеры справочника. Работает в Linux, macOS, WSL и Git Bash на Windows.
# Ничего не меняет вне временных каталогов; Docker-образы не собирает и не запускает.
#
# Запуск из корня репозитория:
#   bash examples/check_all.sh

set -uo pipefail

examples_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
failed=0
passed=0

ok()   { printf '  [OK]   %s\n' "$*"; passed=$((passed + 1)); }
fail() { printf '  [FAIL] %s\n' "$*"; failed=$((failed + 1)); }
skip() { printf '  [SKIP] %s\n' "$*"; }

run_check() {
  local title="$1"; shift
  local output
  if output="$("$@" 2>&1)"; then
    ok "$title"
  else
    fail "$title"
    printf '%s\n' "$output" | sed 's/^/         /'
  fi
}

find_python() {
  local candidate
  for candidate in python3 python py; do
    if command -v "$candidate" >/dev/null 2>&1 && "$candidate" -c 'import sys; sys.exit(sys.version_info < (3, 10))' >/dev/null 2>&1; then
      echo "$candidate"
      return 0
    fi
  done
  return 1
}

echo "== Bash"
for script in "$examples_dir"/bash/*.sh "$examples_dir"/git/*.sh "$examples_dir"/check_all.sh; do
  run_check "синтаксис ${script#"$examples_dir"/}" bash -n "$script"
done
if command -v shellcheck >/dev/null 2>&1; then
  run_check "shellcheck" shellcheck "$examples_dir"/bash/*.sh "$examples_dir"/git/*.sh "$examples_dir"/check_all.sh
else
  skip "shellcheck не установлен"
fi
run_check "safe_script_template.sh" bash "$examples_dir/bash/safe_script_template.sh" -n Тест a b
run_check "log_stats.sh" bash "$examples_dir/bash/log_stats.sh"

backup_tmp="$(mktemp -d)"
run_check "backup_dir.sh" bash "$examples_dir/bash/backup_dir.sh" "$examples_dir/bash" "$backup_tmp"
rm -rf -- "$backup_tmp"

echo
echo "== Git"
if command -v git >/dev/null 2>&1; then
  run_check "conflict_demo.sh" bash "$examples_dir/git/conflict_demo.sh"
  run_check "undo_demo.sh" bash "$examples_dir/git/undo_demo.sh"
else
  skip "git не установлен"
fi

echo
echo "== Python"
if py="$(find_python)"; then
  run_check "компиляция notes_app и app.py" "$py" -m py_compile \
    "$examples_dir"/python/notes_app/*.py "$examples_dir/docker/app.py"
  if "$py" -c 'import pytest' >/dev/null 2>&1; then
    run_check "pytest (examples/python)" bash -c "cd \"$examples_dir/python\" && \"$py\" -m pytest -q"
  else
    skip "pytest не установлен: $py -m pip install -r examples/python/requirements-dev.txt"
  fi
else
  skip "Python 3.10+ не найден"
fi

echo
echo "== Docker"
if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  run_check "docker compose config" docker compose -f "$examples_dir/docker/compose.yaml" config --quiet
else
  skip "docker compose не установлен"
fi

echo
echo "Итого: успешно $passed, с ошибками $failed"
[[ $failed -eq 0 ]]
