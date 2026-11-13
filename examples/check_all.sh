#!/usr/bin/env bash
# Проверяет все примеры справочника. Работает в Linux, macOS, WSL и Git Bash на Windows.
# Ничего не меняет вне временных каталогов; Docker-образы не собирает и не запускает.
# PowerShell-проверки запускаются при наличии pwsh/powershell и на Ubuntu в CI необязательны;
# полный прогон с PSScriptAnalyzer — job windows-latest в GitHub Actions.
#
# Запуск из корня репозитория:
#   bash examples/check_all.sh
#
# STRICT=1 (или переменная CI) — отсутствие обязательных инструментов считается ошибкой,
# а не пропуском. Так устроен GitHub Actions.

set -uo pipefail

examples_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd -- "$examples_dir/.." && pwd)"
failed=0
passed=0
skipped=0
strict=0
if [[ "${STRICT:-0}" == "1" || "${CI:-}" == "true" ]]; then
  strict=1
fi

ok()   { printf '  [OK]   %s\n' "$*"; passed=$((passed + 1)); }
fail() { printf '  [FAIL] %s\n' "$*"; failed=$((failed + 1)); }
skip() {
  printf '  [SKIP] %s\n' "$*"
  skipped=$((skipped + 1))
  if (( strict )); then
    fail "обязательная проверка пропущена (STRICT=1): $*"
  fi
}

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
  printf '  [SKIP] %s\n' "shellcheck не установлен (необязательная проверка)"
  skipped=$((skipped + 1))
fi
run_check "safe_script_template.sh" bash "$examples_dir/bash/safe_script_template.sh" -n Тест a b
run_check "log_stats.sh" bash "$examples_dir/bash/log_stats.sh"

backup_tmp="$(mktemp -d)"
run_check "backup_dir.sh" bash "$examples_dir/bash/backup_dir.sh" "$examples_dir/bash" "$backup_tmp"
rm -rf -- "$backup_tmp"

nest="$(mktemp -d)"
mkdir -p "$nest/src"
printf 'data\n' > "$nest/src/f.txt"
if bash "$examples_dir/bash/backup_dir.sh" "$nest/src" "$nest/src/backups" >/dev/null \
   && sleep 1 \
   && bash "$examples_dir/bash/backup_dir.sh" "$nest/src" "$nest/src/backups" >/dev/null; then
  nested=0
  for archive in "$nest/src/backups"/*.tar.gz; do
    if tar -tzf "$archive" | grep -q '/backups/'; then
      nested=1
    fi
  done
  if (( nested )); then
    fail "backup_dir.sh не должен класть каталог архивов внутрь архива"
  else
    ok "backup_dir.sh исключает каталог архивов"
  fi
else
  fail "backup_dir.sh (каталог архивов внутри источника)"
fi
rm -rf -- "$nest"

echo
echo "== Git"
if command -v git >/dev/null 2>&1; then
  run_check "conflict_demo.sh" bash "$examples_dir/git/conflict_demo.sh"
  run_check "undo_demo.sh" bash "$examples_dir/git/undo_demo.sh"
  run_check "choose_side_demo.sh" bash "$examples_dir/git/choose_side_demo.sh"
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
  run_check "внутренние ссылки Markdown" "$py" "$repo_root/tools/check_markdown_links.py" --root "$repo_root"
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
echo "== PowerShell"
# На Ubuntu/macOS это необязательная проверка (как ShellCheck): Windows-команды
# и PSScriptAnalyzer гоняет отдельный job на windows-latest.
ps_runner=""
if command -v pwsh >/dev/null 2>&1; then
  ps_runner=pwsh
elif command -v powershell >/dev/null 2>&1; then
  ps_runner=powershell
fi
if [[ -n "$ps_runner" ]]; then
  if output="$("$ps_runner" -NoProfile -NonInteractive -File "$examples_dir/powershell/Invoke-Checks.ps1" 2>&1)"; then
    ok "Invoke-Checks.ps1"
  else
    fail "Invoke-Checks.ps1"
    printf '%s\n' "$output" | sed 's/^/         /'
  fi
else
  printf '  [SKIP] %s\n' "PowerShell не установлен (необязательная проверка на этой ОС)"
  skipped=$((skipped + 1))
fi

echo
echo "Итого: успешно $passed, с ошибками $failed, пропусков $skipped"
[[ $failed -eq 0 ]]
