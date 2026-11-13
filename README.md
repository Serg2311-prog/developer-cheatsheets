[![Проверки](https://github.com/Serg2311-prog/developer-cheatsheets/actions/workflows/check.yml/badge.svg)](https://github.com/Serg2311-prog/developer-cheatsheets/actions/workflows/check.yml)

# Developer Cheatsheets

**Главная** · [Bash](bash/README.md) · [Python](python/README.md) · [Git](git/README.md) · [Docker](docker/README.md) · [PowerShell](powershell/README.md) · [Примеры](examples/README.md) · [Источники](SOURCES.md)

Русскоязычный справочник по инструментам, с которыми разработчик работает каждый день: **Bash**, **Python**, **Git**, **Docker** и **PowerShell**. Для каждой команды указаны назначение, проверяемый пример и подводные камни. Кроме таблиц, в каждом разделе есть практические сценарии и разбор частых ошибок. Команды, которые могут уничтожить данные, явно помечены.

## Оглавление

- [Разделы](#разделы)
- [Подробное содержание](#подробное-содержание)
- [Условные обозначения](#условные-обозначения)
- [Как пользоваться](#как-пользоваться)
- [Проверка примеров](#проверка-примеров)
- [Структура репозитория](#структура-репозитория)
- [Окружение](#окружение)
- [Лицензия](#лицензия)

## Разделы

| Раздел | О чём | Начать с |
|---|---|---|
| [Bash](bash/README.md) | Навигация, файлы, поиск, процессы, права, пайпы, переменные, скрипты, Git Bash в Windows и WSL | [Пайпы и перенаправления](bash/README.md#пайпы-и-перенаправления) |
| [Python](python/README.md) | Синтаксис, коллекции, функции, классы, исключения, pathlib, JSON, pip, venv, запуск модулей, pytest | [venv](python/README.md#venv) |
| [Git](git/README.md) | init, clone, add, commit, status, log, diff, branch, switch, merge, rebase, stash, reset, restore, remote, pull, push, конфликты | [Конфликт слияния](git/README.md#конфликт-слияния) |
| [Docker](docker/README.md) | Образы, контейнеры, build, run, exec, logs, тома, сети, Docker Compose, диагностика и очистка | [Docker Compose](docker/README.md#docker-compose) |
| [PowerShell](powershell/README.md) | Основы, файлы, Windows, Git/gh, Python, Docker Desktop, WSL2, отличия от Bash, скрипты и безопасность | [PowerShell и Bash: эквиваленты](powershell/README.md#powershell-и-bash-эквиваленты) |
| [Примеры](examples/README.md) | Рабочие скрипты и мини-проекты к каждому разделу и скрипт проверки | [Проверить всё одной командой](examples/README.md#проверить-всё-одной-командой) |
| [Источники](SOURCES.md) | Ссылки на официальную документацию | — |

## Подробное содержание

**[Bash](bash/README.md)**
[Навигация](bash/README.md#навигация) ·
[Файлы и каталоги](bash/README.md#файлы-и-каталоги) ·
[Просмотр содержимого](bash/README.md#просмотр-содержимого) ·
[Поиск](bash/README.md#поиск) ·
[Процессы и задания](bash/README.md#процессы-и-задания) ·
[Права доступа](bash/README.md#права-доступа) ·
[Пайпы и перенаправления](bash/README.md#пайпы-и-перенаправления) ·
[Обработка текста](bash/README.md#обработка-текста-в-конвейере) ·
[Переменные и окружение](bash/README.md#переменные-и-окружение) ·
[Скрипты](bash/README.md#скрипты) ·
[Git Bash в Windows](bash/README.md#git-bash-в-windows) ·
[WSL](bash/README.md#wsl) ·
[Сценарии](bash/README.md#практические-сценарии) ·
[Частые ошибки](bash/README.md#частые-ошибки)

**[Python](python/README.md)**
[Запуск интерпретатора](python/README.md#запуск-интерпретатора) ·
[Синтаксис](python/README.md#синтаксис) ·
[Строки](python/README.md#строки) ·
[Коллекции](python/README.md#коллекции) ·
[Функции](python/README.md#функции) ·
[Классы](python/README.md#классы) ·
[Исключения](python/README.md#исключения) ·
[pathlib](python/README.md#pathlib-и-файлы) ·
[JSON](python/README.md#json) ·
[pip](python/README.md#pip) ·
[venv](python/README.md#venv) ·
[Запуск модулей](python/README.md#запуск-модулей) ·
[pytest](python/README.md#pytest) ·
[Сценарии](python/README.md#практические-сценарии) ·
[Частые ошибки](python/README.md#частые-ошибки)

**[Git](git/README.md)**
[Как устроен Git](git/README.md#как-устроен-git) ·
[Настройка](git/README.md#настройка) ·
[init и clone](git/README.md#init-и-clone) ·
[status, add, commit](git/README.md#status-add-commit) ·
[log](git/README.md#log-и-show) ·
[diff](git/README.md#diff) ·
[branch и switch](git/README.md#branch-и-switch) ·
[merge](git/README.md#merge) ·
[rebase](git/README.md#rebase) ·
[stash](git/README.md#stash) ·
[restore, reset, revert, clean](git/README.md#restore-reset-revert-clean) ·
[remote, fetch, pull, push](git/README.md#remote-fetch-pull-push) ·
[Конфликт слияния](git/README.md#конфликт-слияния) ·
[reflog](git/README.md#восстановление-и-reflog) ·
[.gitignore](git/README.md#gitignore-и-gitattributes) ·
[Сценарии](git/README.md#практические-сценарии) ·
[Частые ошибки](git/README.md#частые-ошибки)

**[Docker](docker/README.md)**
[Понятия](docker/README.md#основные-понятия) ·
[Images](docker/README.md#images) ·
[Containers](docker/README.md#containers) ·
[Флаги run](docker/README.md#флаги-docker-run) ·
[Build и Dockerfile](docker/README.md#build-и-dockerfile) ·
[exec](docker/README.md#exec) ·
[logs](docker/README.md#logs) ·
[Volumes](docker/README.md#volumes) ·
[Networks](docker/README.md#networks) ·
[Compose](docker/README.md#docker-compose) ·
[Диагностика](docker/README.md#диагностика) ·
[Очистка](docker/README.md#очистка) ·
[Docker в Windows](docker/README.md#docker-в-windows) ·
[Сценарии](docker/README.md#практические-сценарии) ·
[Частые ошибки](docker/README.md#частые-ошибки)

**[PowerShell](powershell/README.md)**
[Основы](powershell/README.md#основы) ·
[Навигация и файлы](powershell/README.md#навигация-и-файлы) ·
[Windows](powershell/README.md#работа-с-windows) ·
[Git и GitHub CLI](powershell/README.md#git-и-github-cli) ·
[Python](powershell/README.md#python-из-powershell) ·
[Docker Desktop](powershell/README.md#docker-desktop) ·
[WSL2](powershell/README.md#wsl2) ·
[Эквиваленты Bash](powershell/README.md#powershell-и-bash-эквиваленты) ·
[Скрипты](powershell/README.md#скрипты-ошибки-функции) ·
[Безопасность](powershell/README.md#безопасность) ·
[Сценарии](powershell/README.md#практические-сценарии) ·
[Частые ошибки](powershell/README.md#частые-ошибки) ·
[5.1 и 7+](powershell/README.md#различия-51-и-7)

## Условные обозначения

| Обозначение | Значение |
|---|---|
| ⚠️ **Опасно** | Команда может безвозвратно удалить или перезаписать данные, уничтожить незакоммиченную работу или переписать общую историю. Прочитайте замечание в той же строке **до** запуска |
| ⚠️ **Очень опасно** | Последствия затрагивают не только вас: чужие коммиты на сервере, все данные Docker и т. п. |
| `ИМЯ`, `ПУТЬ`, `ХЕШ` | Заглушки: подставьте своё значение |
| `<PID>` | То же — заглушка, угловые скобки вводить не нужно |
| `# комментарий` | Пояснение внутри блока кода, вводить его не нужно |

Таблицы во всех разделах устроены одинаково: **команда — назначение — пример — важные замечания**.

## Как пользоваться

- **Ищете команду** — откройте нужный раздел и найдите её через `Ctrl+F`: у каждой темы своя таблица.
- **Решаете задачу** — начните с раздела «Практические сценарии»: там готовые последовательности команд для типовых ситуаций.
- **Что-то пошло не так** — загляните в «Частые ошибки». Там собраны типичные сообщения об ошибках и способы их исправить.
- **Учитесь** — запустите примеры из [`examples/`](examples/README.md). Опасные Git-команды можно безопасно потренировать в одноразовом репозитории: `bash examples/git/undo_demo.sh`.

## Проверка примеров

```bash
bash examples/check_all.sh
```

Скрипт проверяет синтаксис Bash-скриптов, запускает Bash- и Git-примеры во временных каталогах, тесты pytest, внутренние ссылки Markdown и `docker compose config`. Если доступен PowerShell, дополнительно вызывается `examples/powershell/Invoke-Checks.ps1` (на Ubuntu в CI это необязательный skip). Локально отсутствующий инструмент помечается `[SKIP]`. В CI (`STRICT=1`) пропуск обязательной проверки — это ошибка. Подробности — в [examples/README.md](examples/README.md). GitHub Actions дополнительно собирает Docker-пример и на `windows-latest` прогоняет PowerShell-скрипты через PSScriptAnalyzer.

## Структура репозитория

```text
developer-cheatsheets/
├── README.md               # вы здесь: навигация и оглавление
├── LICENSE                 # MIT: код примеров и текст справочника
├── SOURCES.md              # ссылки на официальную документацию
├── bash/README.md          # Bash, утилиты, Git Bash, WSL
├── python/README.md        # Python, pip, venv, pytest
├── git/README.md           # Git и разрешение конфликтов
├── docker/README.md        # Docker и Docker Compose
├── powershell/README.md    # PowerShell 5.1 / 7+, Windows, WSL2
├── examples/
│   ├── README.md           # описание примеров
│   ├── check_all.sh        # проверка всех примеров
│   ├── bash/               # шаблон скрипта, статистика по логам, резервное копирование
│   ├── python/             # CLI-приложение заметок + тесты pytest
│   ├── git/                # конфликт слияния, выбор стороны, reflog
│   ├── docker/             # Dockerfile, compose.yaml и HTTP-сервис
│   └── powershell/         # диагностика системы, Git, Docker; PSScriptAnalyzer
├── tools/                  # проверка внутренних ссылок Markdown
├── .github/workflows/      # GitHub Actions (Ubuntu + Windows для PowerShell)
├── .gitattributes          # LF для .sh, .ps1, Dockerfile и YAML
└── .gitignore
```

## Окружение

Примеры рассчитаны на следующие версии и проверены на них:

| Инструмент | Минимальная версия | Проверено в этом репозитории |
|---|---|---|
| Bash | 4.0 (`declare -A`, `${var^^}`; системный Bash 3.2 на macOS недостаточен) | 5.2.37, Git Bash для Windows |
| Python | 3.10 (`match`, `list[str]`, `dict \| dict`) | 3.13.7 |
| pytest | 8.0 | 9.0.3 |
| Git | 2.28 (`git init -b`; `switch`/`restore` — с 2.23, `zdiff3` — с 2.35) | 2.51.2 (Windows) |
| Docker | Engine 23+, Compose v2 (`docker compose` с пробелом) | CLI 29.3, Compose v5.1.1; `compose config` без daemon. Сборка образа — в GitHub Actions |
| PowerShell | 5.1 (Windows PowerShell) и 7+ (`pwsh`); различия отмечены в разделе | 5.1.26100; PSScriptAnalyzer в job на `windows-latest` |

В Windows команды Bash выполняйте в **Git Bash** или **WSL**. Справочник по оболочке Windows — в [PowerShell](powershell/README.md). Особенности Git Bash и WSL: [Git Bash в Windows](bash/README.md#git-bash-в-windows), [WSL](bash/README.md#wsl), [WSL2 в PowerShell](powershell/README.md#wsl2).

## Лицензия

Собственный текст справочника и код в `examples/` распространяются по лицензии [MIT](LICENSE). Это разрешает использование, копирование и изменение при сохранении уведомления об авторском праве. Официальная документация Bash, Python, Git, Docker и PowerShell, на которую ссылается [SOURCES.md](SOURCES.md), принадлежит их правообладателям и здесь не воспроизводится.
