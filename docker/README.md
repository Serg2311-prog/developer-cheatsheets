# Docker: справочник

[Главная](../README.md) · [Bash](../bash/README.md) · [Python](../python/README.md) · [Git](../git/README.md) · **Docker** · [Примеры](../examples/README.md) · [Источники](../SOURCES.md)

Шпаргалка по Docker Engine 23+ и Docker Compose v2 (команда `docker compose` с пробелом). Проверено: Docker CLI 29.3, Compose v5.1.1; `docker compose config` не требует запущенного daemon. Сборка и запуск учебного образа проверяются в GitHub Actions. Учебный проект с `Dockerfile` и `compose.yaml` лежит в [`examples/docker`](../examples/docker).

> [!WARNING]
> Пометка **⚠️ Опасно** означает, что команда удаляет контейнеры, образы или **тома с данными** (базы данных, загрузки пользователей). Данные внутри контейнера без тома исчезают вместе с контейнером. Команды `prune`, `rm -v`, `down -v` подтверждения либо не спрашивают, либо спрашивают один раз на всё сразу.

## Оглавление

- [Основные понятия](#основные-понятия)
- [Проверка установки](#проверка-установки)
- [Images](#images)
- [Containers](#containers)
- [Флаги docker run](#флаги-docker-run)
- [Build и Dockerfile](#build-и-dockerfile)
- [exec](#exec)
- [logs](#logs)
- [Volumes](#volumes)
- [Networks](#networks)
- [Docker Compose](#docker-compose)
- [Диагностика](#диагностика)
- [Очистка](#очистка)
- [Docker в Windows](#docker-в-windows)
- [Практические сценарии](#практические-сценарии)
- [Частые ошибки](#частые-ошибки)

---

## Основные понятия

| Понятие | Что это |
|---|---|
| **Образ (image)** | Неизменяемый шаблон: файловая система и настройки запуска. Состоит из слоёв, которые кэшируются и переиспользуются |
| **Контейнер (container)** | Запущенный (или остановленный) экземпляр образа с собственным записываемым слоем. Удалили контейнер — удалили всё, что было записано внутри него |
| **Реестр (registry)** | Хранилище образов: Docker Hub, GitHub Container Registry, корпоративный реестр |
| **Тег** | Имя версии образа: `python:3.13-slim`. Если тег не указан, подразумевается `latest`, а это не «последняя стабильная», а просто тег по умолчанию |
| **Том (volume)** | Хранилище данных, которым управляет Docker. Переживает удаление контейнера |
| **Bind mount** | Каталог хоста, подключённый в контейнер. Удобно для разработки |
| **Сеть (network)** | Виртуальная сеть контейнеров. В пользовательской сети контейнеры находят друг друга по имени |
| **Compose** | Описание многоконтейнерного приложения в `compose.yaml` и управление им одной командой |

## Проверка установки

| Команда | Назначение | Пример | Важные замечания |
|---|---|---|---|
| `docker version` | Версии клиента и сервера (daemon) | `docker version` | Если в выводе нет блока `Server`, daemon не запущен (в Windows и macOS — не запущен Docker Desktop) |
| `docker info` | Подробности о daemon | `docker info` | Драйвер хранения, количество контейнеров, корневой каталог данных |
| `docker compose version` | Версия Compose | `docker compose version` | Старая утилита `docker-compose` (через дефис) устарела |
| `docker context ls` | К какому Docker Engine подключён клиент | `docker context ls` | Активный контекст отмечен `*`. Помогает, если команды «уходят» не туда |
| `docker run --rm hello-world` | Проверка, что всё работает | `docker run --rm hello-world` | Скачивает крошечный образ и выводит приветствие |
| `docker login` | Авторизоваться в реестре | `docker login ghcr.io` | Для CI используйте токены и `--password-stdin` |

## Images

| Команда | Назначение | Пример | Важные замечания |
|---|---|---|---|
| `docker pull` | Скачать образ | `docker pull python:3.13-slim` | Фиксируйте версию тегом, а для полной воспроизводимости — дайджестом `@sha256:...` |
| `docker images` / `docker image ls` | Список локальных образов | `docker image ls --filter dangling=true` | Образы без имени (`<none>`) — «висячие», остаются после пересборки |
| `docker image inspect` | Подробности: слои, переменные окружения, команда запуска | `docker image inspect --format '{{.Config.Cmd}}' python:3.13-slim` | |
| `docker image history` | Из каких слоёв и инструкций состоит образ | `docker image history cheatsheet-web:dev` | Ищите, какой слой «раздувает» образ |
| `docker tag` | Дать образу ещё одно имя | `docker tag app:dev ghcr.io/user/app:1.0.0` | Новый образ не создаётся, только ссылка |
| `docker push` | Отправить образ в реестр | `docker push ghcr.io/user/app:1.0.0` | Нужен `docker login`. Проверьте, что в образ не попали секреты |
| `docker rmi` / `docker image rm` | Удалить образ | `docker image rm app:old` | ⚠️ **Опасно:** если образ больше нигде не хранится (собран локально и не запушен), придётся собирать заново. Образ, который используют контейнеры, не удалится без `-f` |
| `docker save` / `docker load` | Выгрузить образ в tar / загрузить из tar | `docker save -o app.tar app:1.0` | Перенос образов без реестра (например, на изолированный сервер). ⚠️ `-o` перезапишет файл |

## Containers

| Команда | Назначение | Пример | Важные замечания |
|---|---|---|---|
| `docker run` | Создать и запустить контейнер | `docker run -d --name web -p 8080:80 nginx:1.27` | Каждый `run` создаёт **новый** контейнер. Флаги — в [следующем разделе](#флаги-docker-run) |
| `docker ps` | Запущенные контейнеры | `docker ps` | |
| `docker ps -a` | Все контейнеры, включая остановленные | `docker ps -a --filter status=exited` | Колонка `STATUS` показывает код выхода: `Exited (1)` |
| `docker ps --format` | Свой формат вывода | `docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"` | |
| `docker stop` | Корректно остановить (SIGTERM, через 10 с — SIGKILL) | `docker stop web` | `-t 30` даёт 30 секунд на завершение |
| `docker start` / `restart` | Запустить остановленный / перезапустить | `docker start -a web` | `start` использует параметры, заданные при `run`. Чтобы их поменять, контейнер пересоздают |
| `docker kill` | Немедленно убить (SIGKILL) | `docker kill web` | ⚠️ **Опасно:** процесс не успевает сохранить данные. Используйте, только если `stop` не помогает |
| `docker rm` | Удалить остановленный контейнер | `docker rm web` | ⚠️ **Опасно:** всё, что записано внутри контейнера, а не в томе, будет потеряно |
| `docker rm -f` | Остановить и удалить | `docker rm -f web` | ⚠️ **Опасно:** то же самое, плюс принудительная остановка |
| `docker rm -v` | Удалить контейнер вместе с его анонимными томами | `docker rm -v web` | ⚠️ **Опасно:** данные анонимных томов удаляются. Именованные тома не затрагиваются |
| `docker cp` | Копировать между контейнером и хостом | `docker cp web:/etc/nginx/nginx.conf ./nginx.conf` | ⚠️ Перезаписывает файл назначения. Работает и с остановленным контейнером |
| `docker stats` | CPU, память, сеть в реальном времени | `docker stats --no-stream` | |
| `docker top` | Процессы внутри контейнера | `docker top web` | |
| `docker port` | Проброшенные порты | `docker port web` | |
| `docker rename` | Переименовать | `docker rename web web-old` | |
| `docker wait` | Дождаться остановки и вывести код выхода | `docker wait migrate` | Удобно в скриптах |
| `docker update` | Изменить политику перезапуска и лимиты на лету | `docker update --restart unless-stopped web` | Порты, тома и переменные так не меняются, только пересозданием |

## Флаги docker run

| Флаг | Назначение | Пример | Важные замечания |
|---|---|---|---|
| `-d` | Запуск в фоне | `docker run -d nginx:1.27` | Выводит ID контейнера. Вывод приложения смотрите через `docker logs` |
| `-it` | Интерактивный режим с терминалом | `docker run -it --rm ubuntu:24.04 bash` | `-i` держит stdin открытым, `-t` выделяет терминал |
| `--rm` | Удалить контейнер после остановки | `docker run --rm alpine echo hi` | ⚠️ Вместе с контейнером исчезнут его логи и анонимные тома. Не используйте для того, что нужно будет исследовать после падения |
| `--name` | Имя контейнера | `--name api` | Имя должно быть уникальным. Повторный `run` с тем же именем выдаст ошибку `Conflict` |
| `-p ХОСТ:КОНТЕЙНЕР` | Проброс порта | `-p 8080:80`, `-p 127.0.0.1:5432:5432` | Без IP порт открыт на **всех** интерфейсах хоста, в том числе для внешней сети. Для локальной разработки указывайте `127.0.0.1:` |
| `-e` / `--env-file` | Переменные окружения | `-e DEBUG=1 --env-file .env` | Значения видны в `docker inspect`. Для секретов в продакшене есть Docker secrets и внешние хранилища |
| `-v том:/путь` | Подключить именованный том | `-v pgdata:/var/lib/postgresql/data` | Если тома нет, он создаётся |
| `-v /хост:/путь` | Bind mount каталога хоста | `-v "$(pwd)":/app` | ⚠️ Контейнер получает доступ на запись к каталогу хоста и может удалить файлы. Для чтения добавьте `:ro` |
| `--mount` | Подробный синтаксис монтирования | `--mount type=bind,src="$(pwd)",dst=/app,readonly` | В отличие от `-v`, не создаёт каталог хоста молча, а выдаёт ошибку |
| `-w` | Рабочий каталог | `-w /app` | |
| `-u` | Пользователь | `-u "$(id -u):$(id -g)"` | Файлы, созданные в bind mount, будут принадлежать вам, а не root |
| `--network` | Подключить к сети | `--network backend` | |
| `--restart` | Политика перезапуска | `--restart unless-stopped` | `no`, `on-failure[:N]`, `always`, `unless-stopped` |
| `--entrypoint` | Заменить ENTRYPOINT образа | `--entrypoint sh` | Помогает «заглянуть» в образ, который сразу падает |
| `--memory` / `--cpus` | Лимиты ресурсов | `--memory 512m --cpus 1.5` | При превышении памяти контейнер убивается (код 137, `OOMKilled`) |
| `--init` | Добавить init-процесс в качестве PID 1 | `--init` | Корректно пересылает сигналы и собирает процессы-зомби |
| `--platform` | Архитектура образа | `--platform linux/amd64` | Нужно на Apple Silicon для образов только под amd64 |

## Build и Dockerfile

| Команда | Назначение | Пример | Важные замечания |
|---|---|---|---|
| `docker build -t` | Собрать образ из каталога | `docker build -t cheatsheet-web:dev examples/docker` | Последний аргумент — **контекст сборки**: всё его содержимое отправляется сборщику. Исключайте лишнее через `.dockerignore` |
| `-f` | Другой Dockerfile | `docker build -f Dockerfile.prod -t app:prod .` | |
| `--build-arg` | Передать `ARG` | `docker build --build-arg PY_VERSION=3.12 .` | ⚠️ Не передавайте так секреты: они сохраняются в истории образа. Для секретов есть `--secret` |
| `--target` | Собрать до определённой стадии | `docker build --target test .` | Для многоэтапных Dockerfile |
| `--no-cache` | Собрать без кэша | `docker build --no-cache -t app .` | Если подозреваете, что кэш «залип» (например, `apt-get update` из старого слоя) |
| `--pull` | Скачать свежую версию базового образа | `docker build --pull -t app .` | |
| `--progress=plain` | Полный вывод сборки | `docker build --progress=plain .` | Видно вывод каждой команды `RUN`, удобно при отладке |
| `--platform` | Сборка под другую архитектуру | `docker buildx build --platform linux/amd64,linux/arm64 .` | Мультиплатформенные образы собираются через `buildx` |

| Инструкция | Назначение | Пример | Важные замечания |
|---|---|---|---|
| `FROM` | Базовый образ | `FROM python:3.13-slim` | Фиксируйте версию. `AS имя` задаёт имя стадии для многоэтапной сборки |
| `WORKDIR` | Рабочий каталог | `WORKDIR /app` | Создаётся автоматически. Не пишите `RUN cd ...`: эффект не сохранится в следующем слое |
| `COPY` | Скопировать файлы из контекста | `COPY requirements.txt .` | Сначала копируйте файлы зависимостей, потом код: так слой с зависимостями кэшируется |
| `ADD` | Как `COPY`, но умеет распаковывать архивы и скачивать по URL | `ADD app.tar.gz /opt/` | Используйте `COPY`, если не нужны эти возможности |
| `RUN` | Выполнить команду при сборке | `RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*` | `update` и `install` объединяйте в одну инструкцию, иначе кэш даст устаревший список пакетов |
| `ENV` | Переменная окружения в образе | `ENV PYTHONUNBUFFERED=1` | Доступна и при сборке, и при запуске |
| `ARG` | Переменная только для сборки | `ARG PY_VERSION=3.13` | `ARG` до `FROM` можно использовать в самой строке `FROM` |
| `EXPOSE` | Документировать порт | `EXPOSE 8000` | Порт **не** публикуется. Публикуется он только через `-p` или `ports:` |
| `USER` | Пользователь для дальнейших инструкций и запуска | `USER appuser` | Не запускайте приложения от root |
| `CMD` | Команда по умолчанию | `CMD ["python", "app.py"]` | Используйте JSON-форму: shell-форма (`CMD python app.py`) запускает процесс через `sh`, и сигналы до него не доходят |
| `ENTRYPOINT` | Неизменяемая часть команды | `ENTRYPOINT ["python", "-m", "app"]` | Аргументы из `docker run образ ...` и `CMD` дописываются в конец |
| `HEALTHCHECK` | Проверка работоспособности | `HEALTHCHECK CMD curl -f http://localhost/ \|\| exit 1` | Статус виден в `docker ps`: `healthy` или `unhealthy` |
| `VOLUME` | Объявить точку монтирования | `VOLUME /data` | При каждом `run` без `-v` создаётся новый анонимный том, и они копятся |

Готовый пример с непривилегированным пользователем, `HEALTHCHECK` и правильным порядком слоёв — [`examples/docker/Dockerfile`](../examples/docker/Dockerfile).

Многоэтапная сборка: инструменты сборки остаются в первой стадии, итоговый образ получается маленьким.

```dockerfile
FROM python:3.13-slim AS build
WORKDIR /src
COPY requirements.txt .
RUN pip wheel --wheel-dir /wheels -r requirements.txt

FROM python:3.13-slim
WORKDIR /app
COPY --from=build /wheels /wheels
RUN pip install --no-cache-dir /wheels/* && rm -rf /wheels
COPY . .
USER nobody
CMD ["python", "main.py"]
```

## exec

| Команда | Назначение | Пример | Важные замечания |
|---|---|---|---|
| `docker exec -it ... sh` | Открыть оболочку в запущенном контейнере | `docker exec -it web sh` | В slim- и alpine-образах может не быть `bash`, используйте `sh` |
| `docker exec` | Выполнить одну команду | `docker exec web cat /etc/os-release` | Контейнер должен быть запущен |
| `-u` | От другого пользователя | `docker exec -u root -it web sh` | Для отладки, когда приложение работает не от root |
| `-e` / `-w` | Переменная окружения / рабочий каталог | `docker exec -e LOG_LEVEL=debug -w /app web env` | |
| `docker compose exec` | То же для сервиса Compose | `docker compose exec db psql -U postgres` | Указывается имя **сервиса**, а не контейнера |
| `docker debug` | Отладочная оболочка с инструментами даже для минимальных образов | `docker debug web` | Доступна в Docker Desktop. Для distroless-образов, где нет даже `sh` |

Изменения, сделанные через `exec` (установленные пакеты, правки файлов), пропадут при пересоздании контейнера. Постоянные изменения вносите в Dockerfile.

## logs

| Команда | Назначение | Пример | Важные замечания |
|---|---|---|---|
| `docker logs` | Вывод контейнера (stdout и stderr) | `docker logs web` | Видно только то, что приложение пишет в stdout/stderr, а не в файлы внутри контейнера |
| `-f` | Следить в реальном времени | `docker logs -f web` | Выход — `Ctrl+C`, контейнер при этом продолжит работать |
| `--tail N` | Последние N строк | `docker logs --tail 100 -f web` | |
| `--since` / `--until` | Ограничить по времени | `docker logs --since 10m web` | Принимает `10m`, `1h` или дату `2026-11-09T10:00:00` |
| `-t` | Добавить временные метки | `docker logs -t web` | |
| `docker compose logs` | Логи всех или выбранных сервисов | `docker compose logs -f --tail 50 web` | |

Python буферизует вывод, когда stdout — не терминал, и логи в контейнере могут появляться с задержкой. Лечится через `ENV PYTHONUNBUFFERED=1` или `print(..., flush=True)`.

## Volumes

| Команда | Назначение | Пример | Важные замечания |
|---|---|---|---|
| `docker volume create` | Создать том | `docker volume create pgdata` | Обычно создаётся автоматически при `run` или `compose up` |
| `docker volume ls` | Список томов | `docker volume ls --filter dangling=true` | `dangling=true` — тома, не подключённые ни к одному контейнеру |
| `docker volume inspect` | Где лежит том и как создан | `docker volume inspect pgdata` | В Docker Desktop путь `Mountpoint` находится внутри виртуальной машины |
| `docker volume rm` | Удалить том | `docker volume rm pgdata` | ⚠️ **Опасно:** данные (например, база) удаляются безвозвратно. Том, подключённый к контейнеру, не удалится |
| `docker volume prune` | Удалить неиспользуемые анонимные тома | `docker volume prune` | ⚠️ **Опасно:** с Docker 23 по умолчанию удаляются только анонимные тома. С `-a` — **все** неиспользуемые, включая именованные с данными |
| Резервная копия тома | Архивировать данные тома | см. пример ниже | Для баз данных надёжнее родные утилиты: `pg_dump`, `mysqldump` |

| | Именованный том | Bind mount |
|---|---|---|
| Синтаксис | `-v pgdata:/var/lib/postgresql/data` | `-v "$(pwd)/src":/app/src` |
| Где данные | В области хранения Docker | В указанном каталоге хоста |
| Когда использовать | Базы данных и всё, что должно пережить контейнер | Исходный код при разработке, конфиги |
| Права и производительность | Предсказуемо на всех ОС | Возможны проблемы с правами в Linux и медленная работа с файлами Windows |

```bash
# резервная копия тома pgdata в ./pgdata-backup.tar.gz
docker run --rm -v pgdata:/data:ro -v "$(pwd)":/backup alpine \
  tar -czf /backup/pgdata-backup.tar.gz -C /data .

# восстановление в НОВЫЙ том (⚠️ в существующем томе одноимённые файлы будут перезаписаны)
docker run --rm -v pgdata-restored:/data -v "$(pwd)":/backup alpine \
  tar -xzf /backup/pgdata-backup.tar.gz -C /data
```

## Networks

| Команда | Назначение | Пример | Важные замечания |
|---|---|---|---|
| `docker network ls` | Список сетей | `docker network ls` | Встроенные сети: `bridge` (по умолчанию), `host`, `none` |
| `docker network create` | Создать пользовательскую сеть | `docker network create backend` | В пользовательской сети работает DNS: контейнеры доступны по имени. В сети `bridge` по умолчанию — нет |
| `docker network inspect` | Подключённые контейнеры и их IP | `docker network inspect backend` | |
| `docker network connect` / `disconnect` | Подключить или отключить работающий контейнер | `docker network connect backend web` | Контейнер может быть в нескольких сетях |
| `docker network rm` | Удалить сеть | `docker network rm backend` | Сеть с подключёнными контейнерами не удалится |
| `docker network prune` | Удалить неиспользуемые сети | `docker network prune` | Данные не затрагивает |
| `--network host` | Использовать сеть хоста напрямую | `docker run --network host nginx` | В Linux порты не нужно пробрасывать. В Docker Desktop работает иначе |
| `host.docker.internal` | Адрес хоста изнутри контейнера | `curl http://host.docker.internal:8000` | Работает в Docker Desktop. В Linux добавьте `--add-host=host.docker.internal:host-gateway` |

```bash
docker network create demo
docker run -d --name api --network demo nginx:1.27
docker run --rm --network demo curlimages/curl:8.11.1 -s http://api   # обращение по имени контейнера
docker rm -f api && docker network rm demo
```

Внутри контейнера `localhost` — это **сам контейнер**, а не хост и не соседний контейнер. Другой контейнер доступен по имени (или по имени сервиса в Compose) и по **внутреннему** порту, а не по опубликованному.

## Docker Compose

Compose описывает сервисы, сети и тома в одном файле `compose.yaml`. Команды выполняются из каталога с этим файлом или с флагом `-f`. Учебный стек: [`examples/docker/compose.yaml`](../examples/docker/compose.yaml).

| Команда | Назначение | Пример | Важные замечания |
|---|---|---|---|
| `docker compose up -d` | Создать и запустить всё в фоне | `docker compose up -d` | Без `-d` логи всех сервисов идут в терминал, а `Ctrl+C` останавливает стек |
| `up --build` | Пересобрать образы перед запуском | `docker compose up -d --build` | Без `--build` изменения в Dockerfile и коде (если он копируется в образ) не подхватятся |
| `up -d сервис` | Запустить или пересоздать один сервис | `docker compose up -d web` | Зависимости из `depends_on` тоже запустятся |
| `docker compose ps` | Состояние сервисов | `docker compose ps -a` | |
| `docker compose logs` | Логи | `docker compose logs -f --tail 100 web` | |
| `docker compose exec` | Команда в работающем сервисе | `docker compose exec web sh` | |
| `docker compose run --rm` | Одноразовый контейнер сервиса | `docker compose run --rm web python -m pytest` | Порты из `ports:` по умолчанию **не** публикуются. Для этого нужен `--service-ports` |
| `docker compose build` | Только собрать образы | `docker compose build --no-cache web` | |
| `docker compose pull` | Скачать свежие версии образов | `docker compose pull` | |
| `docker compose config` | Итоговая конфигурация с подставленными переменными | `docker compose config` | Проверка синтаксиса: `docker compose config --quiet`. Daemon для этого не нужен |
| `docker compose stop` / `start` / `restart` | Остановить / запустить / перезапустить без удаления | `docker compose restart web` | `restart` не применяет изменения из `compose.yaml`. Для этого нужен `up -d` |
| `docker compose down` | Остановить и удалить контейнеры и сети | `docker compose down` | Тома и образы **сохраняются** |
| `docker compose down -v` | То же плюс тома | `docker compose down -v` | ⚠️ **Опасно:** удаляет тома, объявленные в `volumes:`. Это данные баз и загрузок. Используйте только для полного сброса |
| `docker compose down --rmi` | То же плюс образы сервисов | `docker compose down --rmi all` | `all` — все образы сервисов, `local` — только собранные образы без собственного имени в `image:`. Тома не трогает |
| `--profile` | Включить сервисы из профиля | `docker compose --profile tools up -d` | Сервисы с `profiles:` по умолчанию не запускаются |
| `-p` / `name:` | Имя проекта | `docker compose -p demo up -d` | От имени проекта зависят имена контейнеров, сетей и томов. Сменили имя — получили «пустые» тома |
| `docker compose watch` | Синхронизировать изменения кода в контейнер | `docker compose watch` | Нужен раздел `develop.watch` в `compose.yaml` |

Основные ключи `compose.yaml`:

```yaml
name: myapp                       # имя проекта (иначе берётся имя каталога)

services:
  web:
    build: .                      # собрать из Dockerfile в текущем каталоге
    image: myapp-web:dev          # имя для собранного образа
    ports:
      - "127.0.0.1:8000:8000"     # только локально; кавычки нужны: без них YAML может прочитать "22:22" как число
    environment:
      DATABASE_URL: postgresql://app:secret@db:5432/app   # db — имя сервиса
    env_file: .env                # переменные из файла
    depends_on:
      db:
        condition: service_healthy  # ждать не просто запуска, а прохождения healthcheck
    volumes:
      - ./src:/app/src            # bind mount для разработки
    restart: unless-stopped

  db:
    image: postgres:17
    environment:
      POSTGRES_USER: app
      POSTGRES_PASSWORD: secret   # для примера; реальные секреты держите в .env вне Git
      POSTGRES_DB: app
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U app"]
      interval: 5s
      retries: 10

volumes:
  pgdata:                         # именованный том — переживает `down`, но не `down -v`
```

Переменные `${VAR}` в `compose.yaml` подставляются из окружения и из файла `.env` рядом с `compose.yaml`. Значение по умолчанию: `${PORT:-8000}`. Ключ `version:` устарел, и Compose v2 выводит предупреждение, если он есть.

## Диагностика

| Команда | Назначение | Пример | Важные замечания |
|---|---|---|---|
| `docker ps -a` | Упал ли контейнер и с каким кодом | `docker ps -a --filter name=web` | Первым делом при «контейнер не запускается» |
| `docker logs` | Почему упал | `docker logs --tail 50 web` | Логи остаются, пока контейнер не удалён |
| `docker inspect` | Полная конфигурация и состояние | `docker inspect web` | Вывод большой. Используйте `--format` |
| `--format` | Достать конкретное поле | `docker inspect -f '{{.State.ExitCode}} {{.State.OOMKilled}}' web` | `{{json .Mounts}}` выводит раздел в JSON |
| Статус healthcheck | Почему `unhealthy` | `docker inspect -f '{{json .State.Health}}' web` | Последние проверки с их выводом |
| IP-адрес контейнера | | `docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}' web` | |
| `docker events` | Поток событий daemon | `docker events --since 10m --filter container=web` | Видно циклы `start` → `die` при постоянных перезапусках |
| `docker stats` | Потребление ресурсов | `docker stats --no-stream` | `MEM USAGE` около лимита — кандидат на OOM |
| `docker system df` | Сколько места занимают образы, контейнеры, тома, кэш | `docker system df -v` | Начинайте с этого перед очисткой |
| `docker run -it --entrypoint sh` | Зайти в образ, который сразу падает | `docker run --rm -it --entrypoint sh app:dev` | Позволяет вручную запустить команду и увидеть ошибку |
| `docker diff` | Какие файлы изменились внутри контейнера | `docker diff web` | `A` — добавлен, `C` — изменён, `D` — удалён |
| `docker compose ps` / `logs` | То же для стека | `docker compose logs --tail 50` | |

Коды завершения контейнера:

| Код | Значение | Что проверить |
|---|---|---|
| `0` | Успешное завершение | Для сервера это значит, что процесс просто закончился. Проверьте `CMD` |
| `1` | Ошибка приложения | `docker logs` |
| `125` | Ошибка самого `docker run` | Неверный флаг, конфликт имени, занятый порт |
| `126` | Команда найдена, но не запускается | Нет права на выполнение: `RUN chmod +x entrypoint.sh` |
| `127` | Команда или интерпретатор не найдены | Опечатка в `CMD`/`ENTRYPOINT`, нет утилиты в образе, CRLF в shebang скрипта (ищется `bash\r`) |
| `137` | Убит SIGKILL (128 + 9) | `OOMKilled` в `docker inspect`, `docker kill` или `stop` по таймауту |
| `139` | Segmentation fault (128 + 11) | Несовместимая архитектура или нативная библиотека |
| `143` | Завершён SIGTERM (128 + 15) | Нормальная реакция на `docker stop` |

## Очистка

> [!CAUTION]
> Перед любой очисткой выполните `docker system df` и `docker volume ls`. Тома с базами данных удаляются так же легко, как временный мусор, а восстановить их нельзя.

| Команда | Что удаляет | Пример | Важные замечания |
|---|---|---|---|
| `docker container prune` | Все остановленные контейнеры | `docker container prune` | ⚠️ **Опасно:** вместе с контейнерами пропадают их логи и записанные внутри данные |
| `docker image prune` | «Висячие» образы (`<none>`) | `docker image prune` | Обычно безопасно: это старые версии после пересборки |
| `docker image prune -a` | Все образы, не используемые контейнерами | `docker image prune -a --filter "until=168h"` | ⚠️ **Опасно:** локально собранные образы придётся собирать заново, остальные — скачивать |
| `docker builder prune` | Кэш сборки | `docker builder prune --filter until=72h` | Следующие сборки будут медленнее. `-a` очищает весь кэш |
| `docker network prune` | Неиспользуемые сети | `docker network prune` | Данные не затрагивает |
| `docker volume prune` | Неиспользуемые анонимные тома | `docker volume prune` | ⚠️ **Опасно:** удаляет данные. С `-a` — ещё и именованные тома, например базу остановленного проекта |
| `docker system prune` | Остановленные контейнеры, неиспользуемые сети, висячие образы, кэш сборки | `docker system prune` | ⚠️ **Опасно:** удаляет все остановленные контейнеры сразу |
| `docker system prune -a --volumes` | Почти всё неиспользуемое, включая образы и анонимные тома | `docker system prune -a --volumes` | ⚠️ **Очень опасно:** «ядерный» вариант. Не запускайте на машине, где есть ценные данные в Docker |
| `-f` | Не спрашивать подтверждения | `docker image prune -f` | ⚠️ Убирает последнюю линию защиты. Используйте только в CI на одноразовых машинах |

Безопасный порядок регулярной очистки на машине разработчика:

```bash
docker system df                     # оценить масштаб
docker container ls -a               # убедиться, что среди остановленных нет нужных
docker container prune
docker image prune
docker builder prune --filter until=168h
docker system df                     # проверить результат; тома не трогаем
```

## Docker в Windows

| Тема | Что знать | Пример | Важные замечания |
|---|---|---|---|
| Docker Desktop | Docker Engine работает в лёгкой виртуальной машине WSL 2 | Settings → General → *Use the WSL 2 based engine* | Если Docker Desktop не запущен, команды выдают `failed to connect to the docker API` или `error during connect` |
| Интеграция с WSL | `docker` доступен внутри дистрибутивов WSL | Settings → Resources → WSL Integration | Проекты с bind mount держите в файловой системе WSL (`~/project`), а не в `/mnt/c`: так в разы быстрее |
| Пути в PowerShell | Текущий каталог в bind mount | `docker run --rm -v "${PWD}:/app" alpine ls /app` | В cmd: `-v "%cd%:/app"` |
| Пути в Git Bash | Git Bash подменяет пути вида `/app` | `MSYS_NO_PATHCONV=1 docker run --rm -v "$(pwd -W)":/app alpine ls /app` | `pwd -W` выводит путь в формате Windows (`C:/Users/...`). Подробнее — в [разделе Bash](../bash/README.md#git-bash-в-windows) |
| Интерактивный режим в Git Bash | `the input device is not a TTY` | `winpty docker exec -it web sh` | Или используйте Windows Terminal или PowerShell |
| CRLF в скриптах | Скрипт `entrypoint.sh`, сохранённый в Windows, падает с `exec ./entrypoint.sh: no such file or directory` | `.gitattributes`: `*.sh text eol=lf` | Ошибка сбивает с толку: файл есть, а «не найден» интерпретатор `bash\r` |
| Место на диске | Виртуальный диск WSL сам по себе не уменьшается после очистки | Docker Desktop → Troubleshoot → *Clean / Purge data* | ⚠️ **Опасно:** *Purge data* удаляет все образы, контейнеры и тома |

## Практические сценарии

**1. Быстро поднять базу данных для разработки.**

```bash
docker run -d --name dev-postgres \
  -e POSTGRES_PASSWORD=devpass \
  -p 127.0.0.1:5432:5432 \
  -v dev-pgdata:/var/lib/postgresql/data \
  postgres:17
docker logs -f dev-postgres            # дождаться "database system is ready to accept connections"
docker exec -it dev-postgres psql -U postgres
```

Данные сохранятся в томе `dev-pgdata` даже после `docker rm -f dev-postgres`.

**2. Собрать и запустить учебный сервис из `examples/docker`.** Нужен запущенный Docker daemon (Docker Desktop или engine в Linux). Если daemon недоступен, сервис всё равно можно запустить через `python app.py` — см. [`examples/README.md`](../examples/README.md).

```bash
cd examples/docker
docker compose up -d --build
docker compose ps                      # web должен стать (healthy)
curl http://localhost:8000/            # {"message": "Привет из контейнера!", "visits": 1, ...}
docker compose --profile tools run --rm checker   # запрос к web по имени сервиса изнутри сети
docker compose down                    # счётчик посещений сохранится в томе
```

**3. Контейнер сразу падает — алгоритм поиска причины.**

```bash
docker ps -a --filter name=web                         # код выхода
docker logs --tail 50 web                              # сообщение об ошибке
docker inspect -f '{{.State.ExitCode}} OOM={{.State.OOMKilled}}' web
docker run --rm -it --entrypoint sh образ:тег          # зайти внутрь и запустить команду вручную
```

**4. Выполнить одноразовую команду в окружении проекта** (тесты, миграции) без установки инструментов на хост:

```bash
docker run --rm -v "$(pwd)":/work -w /work python:3.13-slim python -m json.tool data.json
docker compose run --rm web python -m pytest
```

**5. Обновить сервис до новой версии образа.**

```bash
docker compose pull web
docker compose up -d web               # пересоздаст только web, тома останутся
docker image prune                     # убрать старые «висячие» образы
```

**6. Освободить место, не потеряв данные.** Смотрите [безопасный порядок очистки](#очистка).

## Частые ошибки

| Ошибка | Что происходит | Как правильно |
|---|---|---|
| Данные базы пропали после `docker rm` | Данные писались в слой контейнера, а не в том | Монтировать том: `-v pgdata:/var/lib/postgresql/data` |
| `docker compose down -v` «для чистоты» | ⚠️ Удалены тома с данными | Обычный `down`. `-v` — только для осознанного полного сброса |
| `bind: address already in use` / `port is already allocated` | Порт хоста занят другим процессом или контейнером | `docker ps` и `ss -ltnp`/`netstat -ano`; поменять порт хоста: `-p 8081:80` |
| Приложение недоступно с хоста, хотя контейнер работает | Сервер слушает `127.0.0.1` **внутри** контейнера | Слушать `0.0.0.0` внутри контейнера и опубликовать порт через `-p` |
| Контейнер не видит другой по `localhost` | `localhost` — это сам контейнер | Обращаться по имени сервиса или контейнера в общей сети: `http://db:5432` |
| Контейнеры не находят друг друга по имени | Они в сети `bridge` по умолчанию, где нет DNS | Создать сеть (`docker network create`) или использовать Compose |
| Изменения кода не видны после `up` | Образ не пересобран | `docker compose up -d --build` |
| `COPY . .` в начале Dockerfile | Любая правка кода сбрасывает кэш установки зависимостей | Сначала `COPY requirements.txt` и `RUN pip install`, потом `COPY . .` |
| Огромный контекст сборки, в образ попали `.git`, `.env`, `node_modules` | Медленная сборка, утечка секретов | `.dockerignore` |
| Секреты в `ENV`/`ARG` Dockerfile | Видны в `docker history` и `docker inspect` всем, у кого есть образ | Передавать при запуске или использовать `--secret` при сборке |
| `docker stop` ждёт 10 секунд | Процесс с PID 1 не обрабатывает SIGTERM, или `CMD` в shell-форме | JSON-форма `CMD [...]`, обработчик SIGTERM в приложении или `--init` |
| Тег `latest` в продакшене | На разных машинах оказываются разные версии | Явные версии: `postgres:17.2`, `python:3.13-slim` |
| `permission denied ... docker.sock` в Linux | Пользователь не в группе `docker` | `sudo usermod -aG docker $USER` и перелогиниться. ⚠️ Группа `docker` фактически даёт права root |
| Файлы в bind mount принадлежат root | Контейнер работает от root | `-u "$(id -u):$(id -g)"` или `USER` в Dockerfile |
| `no matching manifest for linux/arm64` | Образ не собран под вашу архитектуру | `--platform linux/amd64` (через эмуляцию, медленнее) или другой образ |

---

[← Git](../git/README.md) · [↑ К оглавлению](#оглавление) · [Примеры →](../examples/README.md)
