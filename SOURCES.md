# Источники

[Главная](README.md) · [Bash](bash/README.md) · [Python](python/README.md) · [Git](git/README.md) · [Docker](docker/README.md) · [Примеры](examples/README.md) · **Источники**

Справочник написан самостоятельно, тексты из перечисленных источников не копировались. Ниже — официальная документация, по которой стоит сверяться: поведение команд и значения по умолчанию меняются от версии к версии. Встроенная справка всегда соответствует установленной у вас версии: `man КОМАНДА`, `КОМАНДА --help`, `help ВСТРОЕННАЯ_КОМАНДА` в Bash, `git help КОМАНДА`, `docker КОМАНДА --help`, `python -m pydoc МОДУЛЬ`.

## Оглавление

- [Bash и командная строка](#bash-и-командная-строка)
- [Python](#python)
- [Git](#git)
- [Docker](#docker)

## Bash и командная строка

| Ресурс | Что там искать |
|---|---|
| [GNU Bash Reference Manual](https://www.gnu.org/software/bash/manual/bash.html) | Официальное руководство: раскрытие параметров, перенаправления, условные выражения, встроенные команды |
| [GNU Bash — страница проекта](https://www.gnu.org/software/bash/) | Версии, новости, ссылки на руководство в других форматах |
| [GNU Coreutils Manual](https://www.gnu.org/software/coreutils/manual/coreutils.html) | `ls`, `cp`, `mv`, `rm`, `chmod`, `sort`, `uniq`, `cut`, `tr`, `head`, `tail`, `du`, `df` |
| [GNU Findutils Manual](https://www.gnu.org/software/findutils/manual/) | `find` и `xargs` |
| [GNU Grep Manual](https://www.gnu.org/software/grep/manual/grep.html) | `grep`, регулярные выражения |
| [GNU Sed Manual](https://www.gnu.org/software/sed/manual/sed.html) | `sed` |
| [GNU Awk User's Guide](https://www.gnu.org/software/gawk/manual/gawk.html) | `awk` |
| [Git for Windows](https://gitforwindows.org/) | Git Bash: установка, особенности MSYS2 |
| [MSYS2: Filesystem Paths](https://www.msys2.org/docs/filesystem-paths/) | Автоматическое преобразование путей в Git Bash и `MSYS_NO_PATHCONV` |
| [Документация WSL (Microsoft Learn)](https://learn.microsoft.com/ru-ru/windows/wsl/) | Установка, команды `wsl`, работа с файлами Windows и Linux |
| [Основные команды WSL](https://learn.microsoft.com/ru-ru/windows/wsl/basic-commands) | `wsl --install`, `--list`, `--shutdown`, `--export`, `--unregister` |
| [Настройка Git в WSL](https://learn.microsoft.com/ru-ru/windows/wsl/tutorials/wsl-git) | Git Credential Manager и окончания строк |
| [ShellCheck](https://www.shellcheck.net/) | Статический анализатор Bash-скриптов; у каждого предупреждения есть страница с объяснением |

## Python

| Ресурс | Что там искать |
|---|---|
| [Документация Python 3](https://docs.python.org/3/) | Главная страница официальной документации |
| [Учебник Python](https://docs.python.org/3/tutorial/index.html) | Синтаксис, коллекции, функции, классы, исключения |
| [Стандартная библиотека](https://docs.python.org/3/library/index.html) | Справочник по всем модулям |
| [Встроенные типы](https://docs.python.org/3/builtins/stdtypes.html) | Методы `str`, `list`, `dict`, `set` |
| [Встроенные исключения](https://docs.python.org/3/builtins/exceptions.html) | Иерархия исключений |
| [`pathlib`](https://docs.python.org/3/library/pathlib.html) | Работа с путями |
| [`json`](https://docs.python.org/3/library/json.html) | Сериализация и `python -m json.tool` |
| [`dataclasses`](https://docs.python.org/3/library/dataclasses.html) | Классы данных |
| [`venv`](https://docs.python.org/3/library/venv.html) | Виртуальные окружения, активация в разных оболочках |
| [Командная строка и окружение](https://docs.python.org/3/using/cmdline.html) | Флаги `-m`, `-c`, `-i`, `-X utf8`, переменные `PYTHON*` |
| [Python в Windows](https://docs.python.org/3/using/windows.html) | Установка, Python Launcher `py`, псевдонимы Microsoft Store |
| [`__main__` и `if __name__ == "__main__"`](https://docs.python.org/3/library/__main__.html) | Запуск модулей и пакетов |
| [Документация pip](https://pip.pypa.io/en/stable/) | Установка пакетов, файлы требований, editable-установка |
| [Python Packaging User Guide](https://packaging.python.org/en/latest/) | `pyproject.toml`, venv, публикация пакетов |
| [PEP 668](https://peps.python.org/pep-0668/) | Почему появляется ошибка `externally-managed-environment` |
| [PEP 8](https://peps.python.org/pep-0008/) | Стиль кода |
| [Документация pytest](https://docs.pytest.org/en/stable/) | Запуск тестов, фикстуры, параметризация, конфигурация |
| [Встроенные фикстуры pytest](https://docs.pytest.org/en/stable/reference/fixtures.html) | `tmp_path`, `monkeypatch`, `capsys`, `caplog` |

## Git

| Ресурс | Что там искать |
|---|---|
| [Справочник команд Git](https://git-scm.com/docs) | Официальная документация по каждой команде |
| [Книга Pro Git на русском](https://git-scm.com/book/ru/v2) | Подробное объяснение модели Git, ветвления, rebase |
| [`git merge`](https://git-scm.com/docs/git-merge) | Стратегии слияния, раздел *How conflicts are presented* |
| [`git rebase`](https://git-scm.com/docs/git-rebase) | Интерактивный rebase, `--onto`, `--autosquash` |
| [`git restore`](https://git-scm.com/docs/git-restore) | Восстановление файлов, `--staged`, `--ours`/`--theirs` |
| [`git reset`](https://git-scm.com/docs/git-reset) | Режимы `--soft`, `--mixed`, `--hard` |
| [`git stash`](https://git-scm.com/docs/git-stash) | Работа с отложенными изменениями |
| [`git switch`](https://git-scm.com/docs/git-switch) | Переключение и создание веток |
| [`git reflog`](https://git-scm.com/docs/git-reflog) | Журнал ссылок и восстановление |
| [`git push`](https://git-scm.com/docs/git-push) | `--force-with-lease`, удаление удалённых веток |
| [`git config`](https://git-scm.com/docs/git-config) | Все параметры конфигурации |
| [`gitignore`](https://git-scm.com/docs/gitignore) | Синтаксис шаблонов |
| [`gitattributes`](https://git-scm.com/docs/gitattributes) | Окончания строк, `eol=lf` |

## Docker

| Ресурс | Что там искать |
|---|---|
| [Документация Docker](https://docs.docker.com/) | Главная страница официальной документации |
| [Справочник Docker CLI](https://docs.docker.com/reference/cli/docker/) | Все команды `docker` и их флаги |
| [`docker container run`](https://docs.docker.com/reference/cli/docker/container/run/) | Подробно о флагах запуска |
| [Справочник Dockerfile](https://docs.docker.com/reference/dockerfile/) | Все инструкции, shell- и exec-формы |
| [Рекомендации по сборке образов](https://docs.docker.com/build/building/best-practices/) | Кэш слоёв, многоэтапная сборка, `.dockerignore` |
| [Многоэтапная сборка](https://docs.docker.com/build/building/multi-stage/) | `FROM ... AS`, `COPY --from` |
| [Тома](https://docs.docker.com/engine/storage/volumes/) | Создание, резервное копирование, восстановление |
| [Bind mounts](https://docs.docker.com/engine/storage/bind-mounts/) | Отличия `-v` и `--mount` |
| [Сети](https://docs.docker.com/engine/network/) | Драйверы сетей, DNS в пользовательских сетях |
| [Очистка неиспользуемых объектов](https://docs.docker.com/engine/manage-resources/pruning/) | Что удаляет каждая команда `prune` |
| [Docker Compose](https://docs.docker.com/compose/) | Обзор и руководства |
| [Справочник файла Compose](https://docs.docker.com/reference/compose-file/) | Ключи `services`, `volumes`, `networks`, `profiles`, `depends_on` |
| [Справочник `docker compose`](https://docs.docker.com/reference/cli/docker/compose/) | Команды `up`, `down`, `run`, `exec`, `logs`, `config` |
| [Docker Desktop и WSL 2](https://docs.docker.com/desktop/features/wsl/) | Настройка движка WSL 2 и интеграция с дистрибутивами |

---

[← Примеры](examples/README.md) · [↑ К оглавлению](#оглавление) · [На главную](README.md)
