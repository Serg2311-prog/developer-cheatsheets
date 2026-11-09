# Образ для учебного сервиса app.py.
# Сборка:  docker build -t cheatsheet-web:dev examples/docker
# Запуск:  docker run --rm -p 8000:8000 cheatsheet-web:dev

FROM python:3.13-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DATA_DIR=/data \
    PORT=8000

WORKDIR /app

# Отдельный непривилегированный пользователь и каталог для данных.
RUN useradd --create-home --uid 10001 appuser \
    && mkdir -p /data \
    && chown appuser:appuser /data

# Файлы, которые меняются чаще, копируем позже: так лучше работает кэш слоёв.
COPY app.py .

USER appuser
EXPOSE 8000

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
    CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=2)"]

CMD ["python", "app.py"]
