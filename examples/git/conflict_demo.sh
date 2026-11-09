#!/usr/bin/env bash
# Воспроизводит и разрешает конфликт слияния во временном репозитории.
# Ваши репозитории и глобальные настройки Git не затрагиваются.
#
# Запуск:
#   bash examples/git/conflict_demo.sh          # временный репозиторий удаляется в конце
#   KEEP=1 bash examples/git/conflict_demo.sh   # оставить репозиторий для самостоятельного изучения

set -euo pipefail

repo="$(mktemp -d)"
if [[ "${KEEP:-0}" == "1" ]]; then
  trap 'echo; echo "Репозиторий сохранён: $repo"' EXIT
else
  trap 'rm -rf -- "$repo"' EXIT
fi

step() { printf '\n===== %s =====\n' "$*"; }

cd "$repo"
git init --quiet -b main
git config user.name "Demo User"
git config user.email "demo@example.com"
git config core.autocrlf false
git config merge.conflictStyle merge

step "1. Общий предок: файл config.txt в main"
printf 'timeout=30\nretries=3\nmode=prod\n' > config.txt
git add config.txt
git commit --quiet -m "Добавить config.txt"
cat config.txt

step "2. Ветка feature меняет timeout"
git switch --quiet -c feature
sed 's/^timeout=30$/timeout=60/' config.txt > config.tmp && mv config.tmp config.txt
git commit --quiet -am "feature: увеличить timeout до 60"

step "3. Тем временем main меняет ту же строку"
git switch --quiet main
sed 's/^timeout=30$/timeout=45/' config.txt > config.tmp && mv config.tmp config.txt
git commit --quiet -am "main: timeout 45"
git log --oneline --graph --all

step "4. Сливаем feature в main — ожидаем конфликт"
if git merge feature; then
  echo "Неожиданно: конфликта не случилось" >&2
  exit 1
fi

step "5. Что видно во время конфликта"
git status --short
echo "--- Файлы с конфликтами:"
git diff --name-only --diff-filter=U
echo "--- Содержимое config.txt с маркерами:"
cat config.txt

step "6. Разрешаем: оставляем значение 60 из feature и убираем маркеры"
printf 'timeout=60\nretries=3\nmode=prod\n' > config.txt
if grep -nE '^(<<<<<<<|=======|>>>>>>>)' config.txt; then
  echo "В файле остались маркеры конфликта" >&2
  exit 1
fi
git add config.txt
git commit --quiet --no-edit

step "7. Результат"
git log --oneline --graph --all
cat config.txt
