"""Минимальный HTTP-сервис для Docker-примера: считает посещения и хранит счётчик в томе.

Локально без Docker:
    DATA_DIR=./data python app.py
    curl http://localhost:8000/
"""

import json
import os
import signal
import socket
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from threading import Lock

DATA_DIR = Path(os.environ.get("DATA_DIR", "/data"))
PORT = int(os.environ.get("PORT", "8000"))
COUNTER_FILE = DATA_DIR / "visits.txt"
_lock = Lock()


def increment_visits() -> int:
    with _lock:
        DATA_DIR.mkdir(parents=True, exist_ok=True)
        visits = int(COUNTER_FILE.read_text(encoding="utf-8")) if COUNTER_FILE.exists() else 0
        visits += 1
        COUNTER_FILE.write_text(str(visits), encoding="utf-8")
        return visits


class Handler(BaseHTTPRequestHandler):
    def _send_json(self, status: int, body: dict) -> None:
        payload = json.dumps(body, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def do_GET(self) -> None:
        if self.path == "/health":
            self._send_json(200, {"status": "ok"})
        elif self.path == "/":
            self._send_json(200, {"message": "Привет из контейнера!", "visits": increment_visits(), "host": socket.gethostname()})
        else:
            self._send_json(404, {"error": "not found"})

    def log_message(self, format: str, *args) -> None:
        print(f"{self.address_string()} {format % args}", flush=True)


def main() -> None:
    # В контейнере процесс с PID 1 не получает SIGTERM без явного обработчика,
    # и `docker stop` ждал бы 10 секунд до SIGKILL.
    signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))
    server = ThreadingHTTPServer(("0.0.0.0", PORT), Handler)
    print(f"Слушаю порт {PORT}, данные в {DATA_DIR}", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()
        print("Сервер остановлен", flush=True)


if __name__ == "__main__":
    main()
