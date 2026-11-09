#!/usr/bin/env bash
# Проверяет команды выбора стороны конфликта: --source=HEAD / MERGE_HEAD / REBASE_HEAD
# с --staged --worktree, а также git rm / git add при delete/modify.
# Во временном репозитории; глобальный Git не затрагивается.
#
# Запуск: bash examples/git/choose_side_demo.sh

set -euo pipefail

repo="$(mktemp -d)"
trap 'rm -rf -- "$repo"' EXIT

prepare() {
  rm -rf -- "$repo"
  mkdir -p "$repo"
  cd "$repo"
  git init --quiet -b main
  git config user.name "Demo User"
  git config user.email "demo@example.com"
  git config core.autocrlf false
  git config commit.gpgsign false
  printf 'a=1\n' > f.txt
  git add f.txt
  git commit --quiet -m "base"
  git switch --quiet -c feature
  printf 'a=FEATURE\n' > f.txt
  git commit --quiet -am "feature"
  git switch --quiet main
  printf 'a=MAIN\n' > f.txt
  git commit --quiet -am "main"
}

expect() {
  local title="$1" got="$2" want="$3"
  if [[ "$got" != "$want" ]]; then
    echo "FAIL: $title: получено [$got], ожидалось [$want]" >&2
    exit 1
  fi
  echo "OK: $title"
}

prepare
git merge feature >/dev/null 2>&1 || true
git restore --source=MERGE_HEAD --staged --worktree -- f.txt
expect "merge: MERGE_HEAD" "$(cat f.txt)" "a=FEATURE"
expect "merge: MERGE_HEAD уже в индексе" "$(git status --porcelain -- f.txt)" "M  f.txt"
git commit --quiet --no-edit

prepare
git merge feature >/dev/null 2>&1 || true
git restore --source=HEAD --staged --worktree -- f.txt
expect "merge: HEAD" "$(cat f.txt)" "a=MAIN"
git commit --quiet --no-edit

prepare
git switch --quiet feature
git rebase main >/dev/null 2>&1 || true
git restore --source=REBASE_HEAD --staged --worktree -- f.txt
expect "rebase: REBASE_HEAD (ваш коммит)" "$(cat f.txt)" "a=FEATURE"
GIT_EDITOR=true git rebase --continue >/dev/null

prepare
git switch --quiet feature
git rebase main >/dev/null 2>&1 || true
git restore --source=HEAD --staged --worktree -- f.txt
expect "rebase: HEAD (ветка, на которую переносим)" "$(cat f.txt)" "a=MAIN"
git rebase --abort

prepare
git switch --quiet feature
git rm --quiet f.txt
git commit --quiet -m "delete"
git switch --quiet main
git merge feature >/dev/null 2>&1 || true
expect "delete/modify статус" "$(git status --porcelain -- f.txt)" "UD f.txt"
git rm --quiet f.txt
expect "принять удаление" "$([[ -e f.txt ]] && echo yes || echo no)" "no"

prepare
git switch --quiet feature
git rm --quiet f.txt
git commit --quiet -m "delete"
git switch --quiet main
git merge feature >/dev/null 2>&1 || true
git add f.txt
expect "оставить нашу версию" "$(cat f.txt)" "a=MAIN"

echo "Все проверки выбора стороны прошли"
