# PowerShell: справочник

[Главная](../README.md) · [Bash](../bash/README.md) · [Python](../python/README.md) · [Git](../git/README.md) · [Docker](../docker/README.md) · **PowerShell** · [Примеры](../examples/README.md) · [Источники](../SOURCES.md)

Шпаргалка по **Windows PowerShell 5.1** и **PowerShell 7+** (`pwsh`). Где команды или синтаксис различаются, это отмечено явно. Практические скрипты — в [`examples/powershell`](../examples/powershell).

> [!WARNING]
> Пометка **⚠️ Опасно** означает, что команда может удалить файлы, остановить службы, сбросить диск или изменить систему. В PowerShell нет «корзины» для `Remove-Item -Recurse -Force`. Перед разрушительными действиями используйте `-WhatIf` и `-Confirm`.

## Оглавление

- [Основы](#основы)
- [Навигация и файлы](#навигация-и-файлы)
- [Работа с Windows](#работа-с-windows)
- [Git и GitHub CLI](#git-и-github-cli)
- [Python из PowerShell](#python-из-powershell)
- [Docker Desktop](#docker-desktop)
- [WSL2](#wsl2)
- [PowerShell и Bash: эквиваленты](#powershell-и-bash-эквиваленты)
- [Скрипты, ошибки, функции](#скрипты-ошибки-функции)
- [Безопасность](#безопасность)
- [Практические сценарии](#практические-сценарии)
- [Частые ошибки](#частые-ошибки)
- [Различия 5.1 и 7+](#различия-51-и-7)

---

## Основы

PowerShell работает с **объектами**, а не только с текстом. Конвейер `|` передаёт объекты; свойства выбирают через `Select-Object`, фильтруют через `Where-Object`.

| Команда / конструкция | Назначение | Пример | Важные замечания |
|---|---|---|---|
| `Get-Command` | Найти команду, функцию, алиас | `Get-Command *Item*` | `-CommandType Cmdlet` / `Alias` / `Function` |
| `Get-Help` | Справка | `Get-Help Get-ChildItem -Full` | Обновить справку (от админа): `Update-Help` |
| `Get-Help … -Online` | Открыть справку в браузере | `Get-Help Get-Process -Online` | Нужен интернет |
| `Get-Member` | Свойства и методы объекта | `Get-Process \| Get-Member` | Смотрите тип: `Get-Process \| Get-Member -MemberType Property` |
| `Get-Alias` | Список алиасов | `Get-Alias gci, ls, dir` | `ls`/`dir` — алиасы `Get-ChildItem`, поведение не как в Bash |
| `Set-Alias` | Создать алиас в текущей сессии | `Set-Alias ll Get-ChildItem` | Для постоянства — профиль (`$PROFILE`) |
| `$var = значение` | Переменная | `$name = 'Сергей'` | Имена без пробелов; расширение: `"Привет, $name"` |
| `${путь с пробелами}` | Переменная с необычным именем | `${env:ProgramFiles}` | См. также диск `Env:` |
| `$true` / `$false` / `$null` | Логические и пустое значение | `if ($null -eq $x) { … }` | Сравнивайте `$null` слева: `$null -eq $x` |
| `Write-Output` / `Write-Host` | Вывод в конвейер / на экран | `Write-Output 'ok'` | `Write-Host` **не** попадает в конвейер |
| `Write-Error` / `Write-Warning` | Ошибка / предупреждение | `Write-Warning 'устарело'` | Код выхода смотрите через `$LASTEXITCODE` у внешних программ |
| `Get-Variable` | Список переменных сессии | `Get-Variable PATH` | Автоматические: `$?`, `$LASTEXITCODE`, `$PSVersionTable` |
| `\|` | Конвейер объектов | `Get-Process \| Where-Object CPU -gt 10` | Справа обычно cmdlet, принимающий pipeline |
| `ForEach-Object` / `%` | Обработать каждый объект | `1..3 \| ForEach-Object { $_ * 2 }` | `$_` — текущий объект |
| `Where-Object` / `?` | Фильтр | `Get-ChildItem \| Where-Object Length -gt 1KB` | Упрощённый синтаксис: `Where-Object Length -gt 1KB` |
| `Select-Object` | Выбрать свойства / первые N | `Get-Process \| Select-Object -First 5 Name, CPU` | `-ExpandProperty` разворачивает одно свойство |
| `Sort-Object` | Сортировка | `Get-ChildItem \| Sort-Object Length -Descending` | `-Unique` убирает дубликаты |
| `Measure-Object` | Подсчёт / сумма / среднее | `1..10 \| Measure-Object -Sum` | Для файлов: `Get-ChildItem \| Measure-Object -Property Length -Sum` |
| `Compare-Object` | Сравнить две коллекции | `Compare-Object $a $b` | Полезно для списков файлов |
| `Group-Object` | Сгруппировать | `Get-ChildItem \| Group-Object Extension` | |
| `-eq` `-ne` `-lt` `-gt` `-like` `-match` | Операторы сравнения | `'Hello' -like 'H*'` | По умолчанию **без** учёта регистра. `-cmatch` / `-clike` — с учётом |
| `-and` `-or` `-not` | Логика | `if ($a -and -not $b) { }` | |
| `# комментарий` | Комментарий | `# так` | Блок: `<# … #>` |
| `Get-PSDrive` | Диски PowerShell | `Get-PSDrive` | Кроме `C:`, есть `Env:`, `HKCU:`, `Variable:` |
| `$PSVersionTable` | Версия оболочки | `$PSVersionTable.PSVersion` | 5.1 — Desktop; 7+ — Core (`PSEdition`) |

Параметры: именованные (`-Path`), позиционные, переключатели (`-Recurse`). Автодополнение — `Tab`. Справка по параметру: `Get-Help Get-ChildItem -Parameter Filter`.

Профиль (команды при старте):

```powershell
$PROFILE                          # путь к профилю текущего хоста
Test-Path $PROFILE                # существует ли файл
notepad $PROFILE                  # создать/править (5.1)
# pwsh: if (!(Test-Path $PROFILE)) { New-Item -Path $PROFILE -ItemType File -Force }
```

---

## Навигация и файлы

| Команда | Назначение | Пример | Важные замечания |
|---|---|---|---|
| `Get-Location` / `pwd` | Текущий каталог | `Get-Location` | |
| `Set-Location` / `cd` | Сменить каталог | `Set-Location C:\projects` | `cd ..`, `cd ~` (домашний), `cd -` **нет** в 5.1; в 7+ есть `Push-Location`/`Pop-Location` |
| `Push-Location` / `Pop-Location` | Стек каталогов | `Push-Location $env:TEMP; Pop-Location` | Аналог `pushd`/`popd` |
| `Get-ChildItem` / `gci` / `ls` / `dir` | Список файлов | `Get-ChildItem -Force` | `-Force` показывает скрытые. `-Recurse` — вглубь |
| `Get-ChildItem -Filter` | Фильтр по маске (быстрее) | `Get-ChildItem -Filter *.md` | `-Include` требует `-Recurse` или завершающий `*` в пути |
| `New-Item` | Создать файл или каталог | `New-Item -ItemType Directory -Path logs -Force` | `-ItemType File` для файла |
| `Copy-Item` | Копировать | `Copy-Item a.txt b.txt` | ⚠️ **Опасно:** перезаписывает без вопросов. `-Confirm`, `-WhatIf` |
| `Copy-Item -Recurse` | Копировать каталог | `Copy-Item src dest -Recurse` | |
| `Move-Item` | Переместить / переименовать | `Move-Item old.txt new.txt` | ⚠️ **Опасно:** перезапись. `-Force` подавляет часть запросов |
| `Rename-Item` | Переименовать | `Rename-Item .\a.txt b.txt` | |
| `Remove-Item` | Удалить | `Remove-Item temp.log` | ⚠️ **Опасно.** `-Recurse -Force` удаляет дерево без корзины |
| `Remove-Item -WhatIf` | Показать, что было бы удалено | `Remove-Item *.tmp -WhatIf` | Всегда пробуйте `-WhatIf` перед массовым удалением |
| `Get-Content` | Прочитать файл | `Get-Content .\README.md -TotalCount 20` | `-Tail 50`, `-Wait` (как `tail -f`) |
| `Set-Content` / `Add-Content` | Записать / дописать | `Set-Content out.txt 'hello'` | ⚠️ `Set-Content` перезаписывает. Кодировка: в 5.1 часто UTF-16LE; в 7 — UTF-8 без BOM. Явно: `-Encoding utf8` |
| `Out-File` | Записать вывод команды | `Get-ChildItem \| Out-File list.txt -Encoding utf8` | |
| `Select-String` | Поиск по тексту (как grep) | `Select-String -Path *.md -Pattern 'TODO'` | `-Recurse` через `Get-ChildItem -Recurse \| Select-String` |
| `Select-String -Context` | Контекст вокруг совпадения | `Select-String -Path app.log -Pattern ERROR -Context 2,2` | |
| `Test-Path` | Существует ли путь | `Test-Path .\README.md` | `$true`/`$false` |
| `Resolve-Path` | Абсолютный путь | `Resolve-Path .` | |
| `Join-Path` | Склеить путь | `Join-Path $PWD 'examples'` | Кроссплатформеннее, чем ручная склейка со `\` |
| `Split-Path` | Каталог или имя файла | `Split-Path C:\a\b.txt -Leaf` | `-Parent` — каталог |
| `Get-Item` | Один объект файла/каталога | `Get-Item .\LICENSE` | Свойства: `Length`, `LastWriteTime` |
| `Get-FileHash` | Контрольная сумма | `Get-FileHash .\LICENSE -Algorithm SHA256` | |
| `Expand-Archive` / `Compress-Archive` | ZIP | `Compress-Archive -Path .\docs -DestinationPath docs.zip` | ⚠️ Перезаписывает ZIP при `-Force` |

Поиск файлов:

```powershell
Get-ChildItem -Path . -Recurse -Filter *.ps1 -File |
  Where-Object { $_.FullName -notmatch '\\.git\\' } |
  Select-Object FullName, Length
```

---

## Работа с Windows

Команды ниже рассчитаны на **Windows**. В PowerShell 7 на Linux/macOS часть из них недоступна.

| Команда | Назначение | Пример | Важные замечания |
|---|---|---|---|
| `Get-Process` | Список процессов | `Get-Process \| Sort-Object CPU -Descending \| Select-Object -First 10` | |
| `Get-Process -Id` / `-Name` | Конкретный процесс | `Get-Process -Name powershell` | |
| `Stop-Process` | Завершить процесс | `Stop-Process -Id 1234 -Confirm` | ⚠️ **Опасно.** Без `-Force` некоторые процессы не завершатся |
| `Start-Process` | Запустить программу | `Start-Process notepad.exe` | `-Verb RunAs` — с правами администратора (UAC) |
| `Get-Service` | Службы Windows | `Get-Service \| Where-Object Status -eq Running` | Только Windows |
| `Start-Service` / `Stop-Service` | Управление службой | `Stop-Service -Name Spooler -WhatIf` | ⚠️ Нужны права администратора. Сначала `-WhatIf` |
| `Get-CimInstance Win32_OperatingSystem` | Сведения об ОС и памяти | `Get-CimInstance Win32_OperatingSystem \| Select-Object Caption, TotalVisibleMemorySize, FreePhysicalMemory` | Память в KB |
| `Get-CimInstance Win32_Processor` | CPU | `Get-CimInstance Win32_Processor \| Select-Object Name, LoadPercentage, NumberOfCores` | |
| `Get-PSDrive -PSProvider FileSystem` | Логические диски | `Get-PSDrive -PSProvider FileSystem` | `Used`/`Free` в байтах |
| `Get-Volume` | Тома (Win10+) | `Get-Volume \| Select-Object DriveLetter, FileSystemLabel, SizeRemaining` | Модуль Storage |
| `Get-NetIPAddress` | IP-адреса | `Get-NetIPAddress -AddressFamily IPv4` | |
| `Get-NetTCPConnection` | TCP-соединения и порты | `Get-NetTCPConnection -State Listen \| Select-Object LocalPort, OwningProcess` | Сопоставить PID: `Get-Process -Id` |
| `Test-NetConnection` | Проверка сети / порта | `Test-NetConnection example.com -Port 443` | Замена `ping`+`telnet` |
| `Get-DnsClientCache` | DNS-кэш | `Get-DnsClientCache` | |
| `Clear-DnsClientCache` | Очистить DNS-кэш | `Clear-DnsClientCache` | Иногда нужны права администратора |
| `Get-ChildItem Env:` | Переменные окружения | `Get-ChildItem Env: \| Sort-Object Name` | Чтение: `$env:PATH` |
| `$env:NAME = 'value'` | Задать переменную **сессии** | `$env:MY_FLAG = '1'` | Не постоянно. Для пользователя/машины — `[Environment]::SetEnvironmentVariable` |
| `[Environment]::SetEnvironmentVariable` | Постоянная переменная | `[Environment]::SetEnvironmentVariable('MY_FLAG','1','User')` | ⚠️ `'Machine'` требует админа. Новый процесс подхватит после перезапуска терминала |
| `Get-ComputerInfo` | Сводка по системе | `Get-ComputerInfo \| Select-Object CsName, WindowsVersion, OsArchitecture` | Может работать медленно |
| `whoami` / `whoami /groups` | Текущий пользователь и группы | `whoami` | Внешняя команда Windows |

Быстрая диагностика (см. также [`examples/powershell/system_info.ps1`](../examples/powershell/system_info.ps1)):

```powershell
Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 5 Name, Id, @{N='MB';E={[math]::Round($_.WorkingSet64/1MB,1)}}
Get-NetTCPConnection -State Listen | Group-Object LocalPort | Sort-Object Name
```

---

## Git и GitHub CLI

Git и `gh` — внешние программы: код выхода в `$LASTEXITCODE`, вывод — текст (если не используете обёртки).

| Команда | Назначение | Пример | Важные замечания |
|---|---|---|---|
| `git status` | Состояние репозитория | `git status -sb` | Запускайте из корня репозитория |
| `git rev-parse --show-toplevel` | Корень репозитория | `git rev-parse --show-toplevel` | Код ≠ 0 вне репозитория |
| `git branch -vv` | Ветки и upstream | `git branch -vv` | |
| `git remote -v` | Пульты | `git remote -v` | |
| `git log -5 --oneline` | Краткая история | `git log -5 --oneline --decorate` | |
| `git diff` | Непроиндексированные изменения | `git diff --stat` | |
| `gh --version` | Проверка GitHub CLI | `gh --version` | Установка: [cli.github.com](https://cli.github.com/) |
| `gh auth status` | Статус входа | `gh auth status` | |
| `gh repo view` | Информация о репозитории | `gh repo view --json name,url` | |
| `gh run list` | Список workflow runs | `gh run list --limit 5` | |
| `gh run view ID --log-failed` | Логи упавших job | `gh run view 42636912549 --log-failed` | Удобно разбирать CI |

Вызов из скрипта с проверкой кода:

```powershell
git status -sb
if ($LASTEXITCODE -ne 0) { throw "git status завершился с кодом $LASTEXITCODE" }
```

Учебный скрипт: [`examples/powershell/check_git_repo.ps1`](../examples/powershell/check_git_repo.ps1).

---

## Python из PowerShell

| Команда | Назначение | Пример | Важные замечания |
|---|---|---|---|
| `py -3 --version` | Версия через Launcher | `py -3.13 --version` | Надёжнее, чем `python`, если установлен Store-псевдоним-заглушка |
| `python --version` | Версия интерпретатора | `python --version` | |
| `py -3 -m venv .venv` | Создать venv | `py -3 -m venv .venv` | |
| `.\.venv\Scripts\Activate.ps1` | Активировать venv | `.\.venv\Scripts\Activate.ps1` | См. ExecutionPolicy ниже |
| `deactivate` | Деактивировать | `deactivate` | Функция из скрипта активации |
| `python -m pip install -r requirements-dev.txt` | Зависимости | `python -m pip install -U pip` | Всегда `python -m pip`, не голый `pip` |
| `python -m pytest` | Тесты | `python -m pytest -q` | |
| `python -m notes_app` | Запуск пакета | `Set-Location examples\python; python -m notes_app list` | |

### ExecutionPolicy

Политика влияет на **локальные** `.ps1` (в том числе `Activate.ps1`).

| Команда | Назначение | Пример | Важные замечания |
|---|---|---|---|
| `Get-ExecutionPolicy -List` | Политики на всех уровнях | `Get-ExecutionPolicy -List` | Итоговая — самая жёсткая из применённых уровней |
| `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` | Разрешить локальные скрипты | `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` | Рекомендуемый минимум для разработки. Не требует админа |
| `Set-ExecutionPolicy … MachinePolicy` | Политика через GPO | — | ⚠️ Меняет админ/домен; не трогайте без необходимости |
| `powershell -NoProfile -ExecutionPolicy Bypass -File script.ps1` | Разовый обход для одного запуска | см. пример | Не отключает политику навсегда; используйте осознанно |
| `Unblock-File` | Снять пометку Zone.Identifier | `Unblock-File .\Activate.ps1` | Нужно для файлов, скачанных из интернета, при `RemoteSigned` |

```powershell
Get-ExecutionPolicy -List
# Если CurrentUser = Undefined / Restricted:
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
.\.venv\Scripts\Activate.ps1
```

PowerShell 7 (`pwsh`) на Windows тоже соблюдает ExecutionPolicy; на Linux/macOS политика не применяется так же.

---

## Docker Desktop

| Команда | Назначение | Пример | Важные замечания |
|---|---|---|---|
| `docker version` | Клиент и сервер | `docker version` | Если server недоступен — Desktop не запущен |
| `docker info` | Сводка daemon | `docker info` | |
| `docker compose version` | Версия Compose v2 | `docker compose version` | С пробелом, не `docker-compose` |
| `docker ps -a` | Контейнеры | `docker ps -a` | |
| `docker compose ps` | Сервисы Compose | `Set-Location examples\docker; docker compose ps` | |
| `docker compose config` | Проверить YAML | `docker compose config --quiet` | Не требует running daemon |
| `docker logs` | Логи контейнера | `docker logs --tail 100 ИМЯ` | |
| `docker inspect` | Детали объекта | `docker inspect ИМЯ --format '{{.State.Health.Status}}'` | |
| `docker stats --no-stream` | CPU/RAM контейнеров | `docker stats --no-stream` | |
| `docker compose down` | Остановить проект | `docker compose down` | ⚠️ `-v` удалит тома |
| `wsl -l -v` | Дистрибутивы для backend WSL2 | `wsl -l -v` | Docker Desktop часто использует WSL2 |

Диагностика без удаления данных: [`examples/powershell/docker_diag.ps1`](../examples/powershell/docker_diag.ps1).

```powershell
docker version
docker compose -f examples/docker/compose.yaml config --quiet
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

---

## WSL2

| Команда | Назначение | Пример | Важные замечания |
|---|---|---|---|
| `wsl --status` | Состояние WSL | `wsl --status` | |
| `wsl --list --verbose` / `wsl -l -v` | Дистрибутивы и версии | `wsl -l -v` | VERSION 2 — WSL2 |
| `wsl --install` | Установить WSL | `wsl --install` | ⚠️ Нужны админ и перезагрузка |
| `wsl -d Ubuntu` | Войти в дистрибутив | `wsl -d Ubuntu` | |
| `wsl -d Ubuntu -- bash -lc 'команда'` | Одна Bash-команда | `wsl -d Ubuntu -- bash -lc 'uname -a'` | Кавычки экранируйте осторожно |
| `wsl --shutdown` | Остановить **все** дистрибутивы | `wsl --shutdown` | ⚠️ Остановит и Docker Desktop (backend WSL2) |
| `wsl --terminate Ubuntu` | Остановить один дистрибутив | `wsl --terminate Ubuntu` | |
| `wsl --export` / `--import` | Бэкап / восстановление | `wsl --export Ubuntu D:\backup\ubuntu.tar` | Файл большой; место на диске |
| `wsl --unregister` | Удалить дистрибутив | `wsl --unregister OldDistro` | ⚠️ **Опасно:** удаляет файловую систему дистрибутива |

### `.wslconfig`

Файл: `%UserProfile%\.wslconfig` (не внутри дистрибутива). Пример ограничения памяти и swap:

```ini
[wsl2]
memory=8GB
processors=4
swap=4GB
localhostForwarding=true
```

После правки: `wsl --shutdown`, затем снова откройте дистрибутив. Подробности — в [документации Microsoft](https://learn.microsoft.com/ru-ru/windows/wsl/wsl-config).

Запуск проверок справочника из PowerShell через Bash в Git или WSL:

```powershell
& "C:\Program Files\Git\bin\bash.exe" examples/check_all.sh
# или, если установлен Ubuntu в WSL и репозиторий доступен из Linux-пути:
wsl -d Ubuntu -- bash -lc "cd /mnt/c/Users/$env:USERNAME/Documents/Личное/Учеба/developer-cheatsheets && STRICT=1 bash examples/check_all.sh"
```

Проекты, активно собираемые в Linux-инструментах, лучше держать **внутри** файловой системы WSL (`\\wsl$\Ubuntu\home\...`), а не на `/mnt/c` — иначе сильное замедление.

---

## PowerShell и Bash: эквиваленты

| Задача | Bash | PowerShell |
|---|---|---|
| Текущий каталог | `pwd` | `Get-Location` (`pwd`) |
| Список файлов | `ls -la` | `Get-ChildItem -Force` |
| Сменить каталог | `cd path` | `Set-Location path` |
| Создать каталог | `mkdir -p a/b` | `New-Item -ItemType Directory -Force -Path a/b` |
| Копировать | `cp -r src dst` | `Copy-Item src dst -Recurse` |
| Переместить | `mv a b` | `Move-Item a b` |
| Удалить | `rm -rf dir` | `Remove-Item dir -Recurse -Force` ⚠️ |
| Прочитать файл | `cat f` / `less f` | `Get-Content f` |
| Найти в файлах | `grep -rn PAT` | `Select-String -Path * -Pattern PAT -Recurse` (через `gci`) |
| Переменная окружения | `export A=1` | `$env:A = '1'` |
| Конвейер | текст по строкам | объекты (свойства сохраняются) |
| Код выхода | `$?` | `$?` (успех последней **cmdlet**); для exe — `$LASTEXITCODE` |
| Условие | `if [[ … ]]; then` | `if (… ) { }` |
| Цикл по файлам | `for f in *; do` | `foreach ($f in Get-ChildItem) { }` |
| Домашний каталог | `$HOME` / `~` | `$HOME` / `~` |
| Корень диска | `/` | `C:\` (или `/` в pwsh на Linux) |
| Справка | `man` / `--help` | `Get-Help` / `-?` |
| Строгий скрипт | `set -euo pipefail` | `$ErrorActionPreference = 'Stop'` |

Алиасы `ls`, `cat`, `cp` в PowerShell **не** повторяют GNU-утилиты один в один: это другие команды с другими параметрами.

---

## Скрипты, ошибки, функции

| Конструкция | Назначение | Пример | Важные замечания |
|---|---|---|---|
| `param(…)` | Параметры скрипта/функции | см. ниже | Ставьте в начале файла или функции |
| `[CmdletBinding()]` | Расширенные параметры (`-Verbose`, `-WhatIf`) | `[CmdletBinding(SupportsShouldProcess)]` | Нужен для `-WhatIf` в своих функциях |
| `$ErrorActionPreference` | Поведение при ошибках cmdlet | `$ErrorActionPreference = 'Stop'` | `Stop` / `Continue` / `SilentlyContinue` / `Inquire` |
| `try / catch / finally` | Обработка исключений | см. ниже | Ловит ошибки cmdlet при `Stop`; внешние exe проверяйте через `$LASTEXITCODE` |
| `throw` | Выбросить ошибку | `throw 'нет файла'` | |
| `trap` | Глобальный обработчик (редко) | `trap { Write-Error $_; continue }` | Обычно предпочитают `try/catch` |
| `function Имя { }` | Функция | `function Get-Hello { param($Name) "Привет, $Name" }` | Глагол-существительное: `Get-`, `Set-`, `Test-` |
| `if / elseif / else` | Условия | `if ($x -gt 0) { 'ok' } else { 'no' }` | |
| `switch` | Ветвление | `switch ($code) { 0 { 'ok' } default { 'fail' } }` | |
| `foreach` | Цикл по коллекции | `foreach ($i in 1..3) { $i }` | |
| `while` / `do { } while` | Цикл с условием | `while ($n -lt 3) { $n++ }` | |
| `for` | Классический цикл | `for ($i = 0; $i -lt 3; $i++) { $i }` | |
| `return` | Вернуть значение / выйти | `return $result` | В функциях выводит в конвейер |
| `. .\lib.ps1` | Точечный источник (dot-sourcing) | `. .\safe_script_template.ps1` | Импортирует функции в текущую область |
| `#Requires` | Требование версии/модуля | `#Requires -Version 5.1` | Скрипт не запустится на более старой версии |

Шаблон скрипта (полный пример — [`safe_script_template.ps1`](../examples/powershell/safe_script_template.ps1)):

```powershell
#Requires -Version 5.1
[CmdletBinding()]
param(
    [string] $Name = 'мир',
    [switch] $VerboseMsg
)
$ErrorActionPreference = 'Stop'
try {
    if ($VerboseMsg) { Write-Verbose "стартуем для $Name" -Verbose }
    Write-Output "Привет, $Name!"
}
catch {
    Write-Error $_
    exit 1
}
```

Проверка синтаксиса без запуска:

```powershell
$errors = $null
$null = [System.Management.Automation.Language.Parser]::ParseFile(
  '.\examples\powershell\safe_script_template.ps1',
  [ref]$null,
  [ref]$errors
)
$errors
```

Статический анализ: модуль [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer) (`Invoke-ScriptAnalyzer`). В этом репозитории его запускает [`examples/powershell/Invoke-Checks.ps1`](../examples/powershell/Invoke-Checks.ps1).

---

## Безопасность

| Тема | Рекомендация |
|---|---|
| Подтверждение | `-Confirm` и `$ConfirmPreference`; для своих cmdlet — `SupportsShouldProcess` |
| Пробный прогон | Всегда `-WhatIf` перед `Remove-Item`, `Stop-Service`, массовым `Move-Item` |
| Администратор | Нужен для служб, `Machine`-переменных, некоторых сетевых настроек. Запускайте **только** нужную команду с повышенными правами (`Start-Process -Verb RunAs`), а не весь день от админа |
| Удаление | Нет корзины у `Remove-Item -Recurse -Force`. Сначала `Get-ChildItem` / `-WhatIf` |
| Скрипты из сети | `RemoteSigned` + `Unblock-File`; не ставьте `Unrestricted` навсегда |
| Секреты | Не храните токены в `.ps1` и не коммитьте их. Используйте переменные окружения или секрет-хранилище |
| Резервные копии | Перед массовыми правками: `Copy-Item` / `Compress-Archive` / `wsl --export` / снимок диска. Git: коммит или `git stash` до эксперимента |
| Опасные сочетания | `Remove-Item C:\ -Recurse`, `Format-Volume`, `Clear-Disk`, `wsl --unregister`, `docker compose down -v`, `git reset --hard` + удаление файлов |

```powershell
# Пример безопасного удаления временных файлов только в своём каталоге:
Get-ChildItem $env:TEMP -Filter 'myapp-*' -ErrorAction SilentlyContinue |
  Remove-Item -Recurse -Force -Confirm
```

---

## Практические сценарии

### Диагностика системы

```powershell
pwsh -NoProfile -File examples/powershell/system_info.ps1
# или Windows PowerShell 5.1:
powershell -NoProfile -File examples/powershell/system_info.ps1
```

### Проверка Git-репозитория

```powershell
powershell -NoProfile -File examples/powershell/check_git_repo.ps1 -Path .
```

### Диагностика Docker

```powershell
powershell -NoProfile -File examples/powershell/docker_diag.ps1
```

### Все проверки примеров PowerShell (включая PSScriptAnalyzer)

```powershell
powershell -NoProfile -File examples/powershell/Invoke-Checks.ps1 -Strict
```

### Активация venv и pytest

```powershell
Set-Location examples\python
py -3 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements-dev.txt
python -m pytest -q
```

---

## Частые ошибки

| Симптом | Причина | Что сделать |
|---|---|---|
| `невозможно загрузить файл … так как выполнение сценариев отключено` | ExecutionPolicy | `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` или `Unblock-File` |
| `bash` открывает WSL с ошибкой «нет дистрибутива» | В `PATH` первым идёт `bash.exe` от WSL | Вызывайте Git Bash полным путём или установите дистрибутив WSL |
| `$LASTEXITCODE` пуст / старый | Смотрели код после cmdlet, а не после exe | Проверяйте сразу после `git`/`docker`/`python` |
| `ls` не понимает `-la` | Это алиас `Get-ChildItem`, не GNU ls | `Get-ChildItem -Force` или `Get-ChildItem \| Format-List` |
| Кириллица «ломается» в файле | Кодировка 5.1 по умолчанию | `Set-Content -Encoding utf8` / `-Encoding utf8BOM` в 7+ |
| `&&` не работает в 5.1 | Цепочки команд — фича 7+ | `; if ($?) { … }` или обновитесь до pwsh 7 |
| `$IsWindows` не найден | Переменная есть только в 7+ | `$env:OS -eq 'Windows_NT'` |
| `Activate.ps1` не находится | Другая структура venv или не создан | `py -3 -m venv .venv` заново; путь `Scripts\Activate.ps1` на Windows |
| Docker: `open //./pipe/dockerDesktopLinuxEngine` | Desktop не запущен | Запустите Docker Desktop и дождитесь Idle |
| `wsl --shutdown` «убил» контейнеры | Docker Desktop на WSL2 backend | Это ожидаемо; запустите Desktop снова |

---

## Различия 5.1 и 7+

| Возможность | Windows PowerShell 5.1 | PowerShell 7+ (`pwsh`) |
|---|---|---|
| Платформы | Только Windows | Windows, Linux, macOS |
| `$IsWindows` / `$IsLinux` | Нет | Есть |
| Операторы `&&` `\|\|` | Нет | Есть |
| Тернарный `? :`, `??`, `?.` | Нет | Есть |
| `ForEach-Object -Parallel` | Нет | Есть |
| Кодировка `Set-Content` по умолчанию | Часто UTF-16LE | UTF-8 без BOM |
| Запуск | `powershell.exe` | `pwsh.exe` |
| Модули галереи | `Install-Module` (часто TLS 1.2 нужно включить) | `Install-Module` / `Install-PSResource` |
| Алиасы Unix | Ограничены | Больше совместимости, но всё равно объекты |

Минимальная версия примеров репозитория: **5.1** (`#Requires -Version 5.1`). Где нужен 7+, это указано отдельно.

---

[← Docker](../docker/README.md) · [↑ К оглавлению](#оглавление) · [Примеры →](../examples/README.md)
