# Примеры

[Главная](../README.md) · [Bash](../bash/README.md) · [Python](../python/README.md) · [Git](../git/README.md) · [Docker](../docker/README.md) · [PowerShell](../powershell/README.md) · **Примеры** · [Источники](../SOURCES.md)

Небольшие рабочие примеры к разделам справочника. Каждый можно запустить и проверить. Команды Bash ниже выполняются из **корня репозитория** (Linux, macOS, WSL или Git Bash). PowerShell-примеры — в Windows PowerShell 5.1 или `pwsh` 7+.

## Оглавление

- [Проверить всё одной командой](#проверить-всё-одной-командой)
- [Bash](#bash)
- [Python](#python)
- [Git](#git)
- [Docker](#docker)
- [PowerShell](#powershell)

## Проверить всё одной командой

```bash
bash examples/check_all.sh
```

Скрипт проверяет синтаксис всех `.sh` (и прогоняет ShellCheck, если он установлен), запускает Bash- и Git-примеры во временных каталогах, компилирует Python-код, запускает pytest, проверяет внутренние ссылки Markdown и `compose.yaml` через `docker compose config`. Если доступен `pwsh` или `powershell`, вызывается [`powershell/Invoke-Checks.ps1`](powershell/Invoke-Checks.ps1) (при `STRICT=1`/`CI` — с `-Strict`). Если инструмента нет, проверка помечается как `[SKIP]`. В CI и при `STRICT=1` пропуск **обязательной** проверки (Bash-примеры, Git, Python/pytest, ShellCheck, ссылки, `docker compose config`) — это ошибка. Отсутствие самой оболочки PowerShell на Ubuntu по-прежнему необязательный skip; полный прогон с PSScriptAnalyzer также идёт в GitHub Actions на `windows-latest`.

Скрипт ничего не меняет вне временных каталогов и не собирает Docker-образы. Python ищется по порядку: `python3`, `python`, `py`.

Запуск из PowerShell: `& "C:\Program Files\Git\bin\bash.exe" examples/check_all.sh`.

## Bash

| Файл | Что показывает | Запуск |
|---|---|---|
| [`bash/safe_script_template.sh`](bash/safe_script_template.sh) | Каркас надёжного скрипта: `set -Eeuo pipefail`, `getopts`, `trap` для очистки, `mktemp -d`, логирование в stderr | `bash examples/bash/safe_script_template.sh -v -n Сергей a b` |
| [`bash/log_stats.sh`](bash/log_stats.sh) | Пайпы `awk \| sort \| uniq -c \| sort -rn \| head` на примере access-лога | `bash examples/bash/log_stats.sh` |
| [`bash/access.log`](bash/access.log) | Тестовые данные для `log_stats.sh` | — |
| [`bash/backup_dir.sh`](bash/backup_dir.sh) | Архив каталога с отметкой времени. Никогда не перезаписывает существующий архив | `bash examples/bash/backup_dir.sh examples/bash /tmp/backups` |

Ожидаемый фрагмент вывода `log_stats.sh`:

```text
Всего запросов: 10

Топ-3 IP-адреса:
      4 192.168.1.10
      ...
Ошибок сервера (5xx): 2
```

## Python

Каталог [`python/`](python) — маленький, но полноценный проект: CLI для заметок в JSON-файле. В нём собраны `pathlib`, `json`, `dataclasses`, собственные исключения, `argparse`, запуск через `python -m` и тесты pytest с фикстурами `tmp_path`, `capsys`, `monkeypatch` и параметризацией.

```text
python/
├── pyproject.toml          # метаданные проекта и настройки pytest
├── requirements-dev.txt    # зависимости для разработки (pytest)
├── notes_app/
│   ├── __init__.py
│   ├── __main__.py         # точка входа для `python -m notes_app`
│   ├── cli.py              # argparse, коды возврата, вывод ошибок в stderr
│   └── storage.py          # dataclass Note, JSON-хранилище с атомарной записью
└── tests/
    ├── test_cli.py
    └── test_storage.py
```

```bash
cd examples/python
python -m venv .venv
source .venv/bin/activate            # Git Bash: source .venv/Scripts/activate; PowerShell: .venv\Scripts\Activate.ps1
python -m pip install -r requirements-dev.txt
python -m pytest -v                  # 15 тестов

python -m notes_app add "Купить молоко" --tag дом --tag покупки
python -m notes_app add "Сдать отчёт" --tag работа
python -m notes_app list --tag дом   # 1. Купить молоко [дом, покупки]
python -m notes_app tags
python -m notes_app list --query ОТЧЁТ
```

По умолчанию заметки пишутся в `notes.json` в текущем каталоге (файл уже в `.gitignore`), другой путь задаётся флагом `--file`.

## Git

Скрипты создают одноразовый репозиторий во временном каталоге. Ваши репозитории и глобальный `~/.gitconfig` не затрагиваются.

| Файл | Что показывает | Запуск |
|---|---|---|
| [`git/conflict_demo.sh`](git/conflict_demo.sh) | Две ветки меняют одну строку → конфликт при `merge` → маркеры конфликта → разрешение → merge-коммит | `bash examples/git/conflict_demo.sh` |
| [`git/choose_side_demo.sh`](git/choose_side_demo.sh) | Выбор стороны через `--source=HEAD`/`MERGE_HEAD`/`REBASE_HEAD` и `git rm`/`git add` при delete/modify | `bash examples/git/choose_side_demo.sh` |
| [`git/undo_demo.sh`](git/undo_demo.sh) | `stash`, `restore --staged`, `restore`, `reset --hard` и спасение коммитов через `reflog` | `bash examples/git/undo_demo.sh` |

Чтобы самостоятельно поэкспериментировать с конфликтом, сохраните временный репозиторий: `KEEP=1 bash examples/git/conflict_demo.sh`. Путь к нему будет выведен в конце.

## Docker

Каталог [`docker/`](docker): HTTP-сервис на стандартной библиотеке Python, который считает посещения и хранит счётчик в именованном томе.

| Файл | Что показывает |
|---|---|
| [`docker/app.py`](docker/app.py) | Сервер слушает `0.0.0.0`, обрабатывает SIGTERM (быстрый `docker stop`), отдаёт `/health` |
| [`docker/Dockerfile`](docker/Dockerfile) | Фиксированный базовый образ, непривилегированный пользователь, `HEALTHCHECK`, JSON-форма `CMD` |
| [`docker/.dockerignore`](docker/.dockerignore) | Что не отправлять в контекст сборки |
| [`docker/compose.yaml`](docker/compose.yaml) | Сервис с томом и healthcheck, порт только на `127.0.0.1`, вспомогательный сервис в профиле `tools`, `depends_on` с `service_healthy` |

`docker compose config` работает без запущенного daemon. Сборка образа и `compose up` нуждаются в Docker Engine. Если daemon недоступен (типичная ситуация, когда Docker Desktop выключен), используйте запуск через `python app.py` ниже; сборку проверяет GitHub Actions.

```bash
cd examples/docker
docker compose config --quiet && echo "compose.yaml корректен"

docker compose up -d --build
docker compose ps                                  # web: (healthy) примерно через 5–10 секунд
curl http://localhost:8000/                        # visits увеличивается с каждым запросом
docker compose --profile tools run --rm checker    # запрос к http://web:8000 изнутри сети Compose
docker compose restart web && curl http://localhost:8000/   # счётчик сохранился в томе
docker compose down                                # ⚠️ с флагом -v был бы удалён и том со счётчиком
```

Без Docker сервис можно запустить напрямую:

```bash
cd examples/docker
DATA_DIR=./data PORT=8000 python app.py
# в другом терминале:
curl http://localhost:8000/health    # {"status": "ok"}
```

## PowerShell

Каталог [`powershell/`](powershell) — примеры к [разделу PowerShell](../powershell/README.md). Скрипты совместимы с **Windows PowerShell 5.1** и **PowerShell 7+**. Ничего не удаляют у других проектов: временные каталоги только свои, Docker — только чтение.

| Файл | Что показывает | Запуск |
|---|---|---|
| [`powershell/safe_script_template.ps1`](powershell/safe_script_template.ps1) | `param`, `$ErrorActionPreference = 'Stop'`, `try/catch/finally`, временный каталог | `powershell -NoProfile -File examples/powershell/safe_script_template.ps1 -Name Сергей -VerboseMsg a b` |
| [`powershell/system_info.ps1`](powershell/system_info.ps1) | ОС, CPU, память, диски, топ процессов, слушающие порты | `powershell -NoProfile -File examples/powershell/system_info.ps1` |
| [`powershell/check_git_repo.ps1`](powershell/check_git_repo.ps1) | Корень репозитория, ветка, `status -sb`, remote, `log`, опционально `gh` | `powershell -NoProfile -File examples/powershell/check_git_repo.ps1 -Path .` |
| [`powershell/docker_diag.ps1`](powershell/docker_diag.ps1) | `docker version`/`info`/`ps`, `compose config` без `down`/`rm`/`prune` | `powershell -NoProfile -File examples/powershell/docker_diag.ps1` |
| [`powershell/Invoke-Checks.ps1`](powershell/Invoke-Checks.ps1) | Парсер, PSScriptAnalyzer, запуск примеров | `powershell -NoProfile -File examples/powershell/Invoke-Checks.ps1 -Strict` |
| [`powershell/PSScriptAnalyzerSettings.psd1`](powershell/PSScriptAnalyzerSettings.psd1) | Настройки анализатора (исключён `PSAvoidUsingWriteHost` для CLI) | — |

```powershell
# Установка анализатора (один раз, CurrentUser):
Install-Module PSScriptAnalyzer -Scope CurrentUser -Force

# Полная проверка примеров PowerShell:
powershell -NoProfile -File examples/powershell/Invoke-Checks.ps1 -Strict
```

---

[← PowerShell](../powershell/README.md) · [↑ К оглавлению](#оглавление) · [Источники →](../SOURCES.md)
