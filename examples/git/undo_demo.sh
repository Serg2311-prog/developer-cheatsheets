#!/usr/bin/env bash
# Безопасная песочница для опасных команд: stash, restore, reset --hard и спасение через reflog.
# Всё происходит во временном репозитории, который удаляется в конце.
#
# Запуск:
#   bash examples/git/undo_demo.sh

set -euo pipefail

repo="$(mktemp -d)"
trap 'rm -rf -- "$repo"' EXIT

step() { printf '\n===== %s =====\n' "$*"; }

cd "$repo"
git init --quiet -b main
git config user.name "Demo User"
git config user.email "demo@example.com"
git config core.autocrlf false

for n in 1 2 3; do
  echo "строка $n" >> app.txt
  git add app.txt
  git commit --quiet -m "Коммит $n"
done

step "Исходная история"
git log --oneline

step "git stash: временно убрать незакоммиченные правки"
echo "черновик" >> app.txt
git stash push --quiet -m "черновик"
git stash list
echo "Рабочая копия чистая: [$(git status --porcelain)]"
git stash pop --quiet
tail -n 1 app.txt

step "git restore --staged: убрать файл из индекса, сохранив правки"
git add app.txt
git restore --staged app.txt
git status --short

step "git restore: ОТБРОСИТЬ правки в рабочей копии (необратимо для незакоммиченного)"
git restore app.txt
echo "Рабочая копия чистая: [$(git status --porcelain)]"

step "git reset --hard HEAD~2: «потеряли» два коммита"
git reset --quiet --hard HEAD~2
git log --oneline

step "git reflog: коммиты всё ещё доступны"
git reflog -n 3
lost="$(git rev-parse 'HEAD@{1}')"
git reset --quiet --hard "$lost"

step "История восстановлена"
git log --oneline
