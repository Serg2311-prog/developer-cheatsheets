# Python: справочник

[Главная](../README.md) · [Bash](../bash/README.md) · **Python** · [Git](../git/README.md) · [Docker](../docker/README.md) · [PowerShell](../powershell/README.md) · [Примеры](../examples/README.md) · [Источники](../SOURCES.md)

Шпаргалка по Python 3.10+ (`match`, `list[str]`, объединение словарей `|`) и основным инструментам: pip, venv, pytest 8+. Проверено: Python 3.13.7, pytest 9.0.3. Примеры из таблиц можно вставить в REPL (`python`) и сразу проверить. Готовый проект для экспериментов лежит в [`examples/python`](../examples/python).

> [!WARNING]
> Пометка **⚠️ Опасно** означает, что код или команда могут безвозвратно удалить или перезаписать файлы либо сломать окружение. Python не спрашивает подтверждения: `Path.unlink()`, `shutil.rmtree()` и `write_text()` срабатывают сразу.

## Оглавление

- [Запуск интерпретатора](#запуск-интерпретатора)
- [Синтаксис](#синтаксис)
- [Строки](#строки)
- [Коллекции](#коллекции)
- [Функции](#функции)
- [Классы](#классы)
- [Исключения](#исключения)
- [pathlib и файлы](#pathlib-и-файлы)
- [JSON](#json)
- [pip](#pip)
- [venv](#venv)
- [Запуск модулей](#запуск-модулей)
- [pytest](#pytest)
- [Практические сценарии](#практические-сценарии)
- [Частые ошибки](#частые-ошибки)

---

## Запуск интерпретатора

| Команда | Назначение | Пример | Важные замечания |
|---|---|---|---|
| `python --version` | Версия Python | `python --version` | В Linux и macOS команда часто называется `python3`. В Windows `python3` может открыть Microsoft Store |
| `py` | Python Launcher для Windows | `py -3.12 script.py` | `py --list-paths` (`py -0p`) — все установленные версии и пути к ним |
| `python файл.py` | Запустить скрипт | `python app.py --debug` | Аргументы доступны в `sys.argv` |
| `python -c "код"` | Выполнить строку кода | `python -c "import sys; print(sys.executable)"` | Быстро узнать, какой интерпретатор реально запускается |
| `python -m модуль` | Запустить модуль как программу | `python -m pip --version` | См. [Запуск модулей](#запуск-модулей) |
| `python -i файл.py` | После скрипта остаться в REPL | `python -i app.py` | Удобно изучать переменные после выполнения |
| `python` | Интерактивный режим (REPL) | `>>> 2 ** 10` | Выход — `exit()` или `Ctrl+D` (в Windows `Ctrl+Z`, затем `Enter`). `help(str)` — справка |
| `python -X utf8` | Режим UTF-8 для ввода и вывода | `python -X utf8 script.py` | Помогает в Windows от `UnicodeEncodeError` при выводе кириллицы. То же — переменная `PYTHONUTF8=1` |

## Синтаксис

| Конструкция | Назначение | Пример | Важные замечания |
|---|---|---|---|
| Присваивание и аннотации | Переменная с подсказкой типа | `count: int = 0` | Аннотации не проверяются при выполнении. Проверять их нужно отдельным инструментом (`mypy`, `pyright`) |
| `type()` / `isinstance()` | Проверить тип | `isinstance(3, (int, float))` → `True` | `isinstance` учитывает наследование, поэтому предпочтительнее `type(x) == ...` |
| Арифметика | `/` — деление, `//` — целочисленное, `%` — остаток, `**` — степень | `7 / 2` → `3.5`, `7 // 2` → `3`, `-7 // 2` → `-4` | `//` округляет вниз, а не к нулю |
| Сравнения цепочкой | Проверить диапазон | `0 <= x < 10` | |
| `if` / `elif` / `else` | Ветвление | `if x > 0: ... elif x == 0: ... else: ...` | Блоки задаются отступом в 4 пробела. Табы и пробелы смешивать нельзя |
| Тернарный оператор | Выражение-условие | `status = "ok" if code == 0 else "fail"` | |
| Истинность | Пустые значения ложны | `if items:` | Ложны: `0`, `0.0`, `""`, `[]`, `{}`, `set()`, `None`, `False` |
| `is None` | Проверка на `None` | `if value is None:` | `is` сравнивает объекты, а `==` — значения. Для чисел и строк используйте `==` |
| `for` + `range` | Цикл по числам | `for i in range(0, 10, 2): print(i)` | `range(n)` — от 0 до `n-1` |
| `enumerate` | Индекс и значение | `for i, name in enumerate(names, start=1):` | Вместо `range(len(names))` |
| `zip` | Параллельный обход | `for k, v in zip(keys, values):` | Останавливается на самой короткой последовательности. `zip(a, b, strict=True)` выбросит ошибку при разной длине |
| `while` / `break` / `continue` | Цикл с условием | `while queue: item = queue.pop()` | У `for` и `while` есть ветка `else`: она выполняется, если цикл завершился без `break` |
| `match` / `case` | Сопоставление с образцом (3.10+) | см. пример ниже | Это не `switch` из C: `case x:` без точки **захватывает** значение в переменную `x` |
| Списковое включение | Новый список из итерируемого объекта | `[x * x for x in range(5) if x % 2 == 0]` → `[0, 4, 16]` | Есть варианты для словарей `{k: v for ...}` и множеств `{x for ...}` |
| Генераторное выражение | Ленивое вычисление | `sum(x * x for x in range(10**6))` | Не создаёт список в памяти. Обойти можно только один раз |
| Срезы | Часть последовательности | `s[1:4]`, `s[-3:]`, `s[::-1]` | Срез создаёт копию. Выход за границы среза ошибки не вызывает |
| Распаковка | Разложить по переменным | `first, *rest = [1, 2, 3]` | Обмен значений: `a, b = b, a` |
| Моржовый оператор `:=` | Присвоить внутри выражения | `if (n := len(data)) > 10: print(n)` | |
| `pass` / `...` | Пустой блок | `def todo(): ...` | |

```python
def describe(command: dict) -> str:
    match command:
        case {"action": "move", "x": int(x), "y": int(y)}:
            return f"Перемещение в ({x}, {y})"
        case {"action": "quit"}:
            return "Выход"
        case _:
            return "Неизвестная команда"

print(describe({"action": "move", "x": 1, "y": 2}))  # Перемещение в (1, 2)
```

## Строки

| Метод или приём | Назначение | Пример | Важные замечания |
|---|---|---|---|
| f-строки | Форматирование | `f"{name!r}: {price:.2f} ₽, {qty:>5}"` | `f"{x=}"` выводит `x=42` — удобно для отладки |
| `split` / `join` | Разбить / склеить | `"a,b,c".split(",")`, `", ".join(items)` | `split()` без аргумента режет по любым пробельным символам и выбрасывает пустые части |
| `strip` / `lstrip` / `rstrip` | Убрать пробелы по краям | `"  hi\n".strip()` → `"hi"` | `strip("abc")` убирает **набор символов**, а не подстроку. Для префикса есть `removeprefix()` |
| `replace` | Заменить подстроку | `"a-b".replace("-", "_")` | Строки неизменяемы: метод возвращает новую строку |
| `startswith` / `endswith` | Проверить начало или конец | `name.endswith((".jpg", ".png"))` | Можно передать кортеж вариантов |
| `in` | Содержит ли подстроку | `"err" in line.lower()` | |
| `lower` / `upper` / `casefold` | Регистр | `a.casefold() == b.casefold()` | `casefold` надёжнее для сравнения без учёта регистра |
| `isdigit` / `isalpha` | Проверить символы | `"123".isdigit()` | `"-1".isdigit()` → `False` |
| `encode` / `decode` | `str` ↔ `bytes` | `"Привет".encode("utf-8")` | Всегда указывайте кодировку явно |
| Многострочные строки | Текст в тройных кавычках | `textwrap.dedent("""...""")` | `dedent` убирает общий отступ |

## Коллекции

| Тип / метод | Назначение | Пример | Важные замечания |
|---|---|---|---|
| `list` | Изменяемый упорядоченный список | `nums = [3, 1, 2]` | Доступ по индексу — O(1), поиск `x in list` — O(n) |
| `append` / `extend` / `insert` | Добавить элемент / несколько элементов / по индексу | `nums.append(4)`, `nums.extend([5, 6])` | `append([5, 6])` добавит **один** элемент — вложенный список |
| `pop` / `remove` / `del` | Удалить по индексу / по значению / срез | `nums.pop()`, `nums.remove(3)`, `del nums[0]` | `remove` удаляет первое вхождение и выбрасывает `ValueError`, если элемента нет |
| `sort()` и `sorted()` | Отсортировать на месте / вернуть новый список | `sorted(users, key=lambda u: u["age"], reverse=True)` | `list.sort()` возвращает `None`. Не пишите `x = x.sort()` |
| `tuple` | Неизменяемая последовательность | `point = (10, 20)` | Кортеж из одного элемента: `(1,)`. Может быть ключом словаря |
| `dict` | Словарь «ключ → значение» | `user = {"name": "Анна", "age": 30}` | Сохраняет порядок вставки (3.7+) |
| `d[key]` и `d.get(key, default)` | Получить значение | `user.get("email", "нет")` | `d[key]` при отсутствии ключа выбрасывает `KeyError` |
| `items` / `keys` / `values` | Обход словаря | `for k, v in user.items():` | Нельзя добавлять и удалять ключи во время обхода |
| `setdefault` / `update` / `\|` | Значение по умолчанию / обновить / объединить | `merged = defaults \| overrides` | При конфликте `\|` берёт значение из правого словаря (3.9+) |
| `pop` | Удалить ключ и вернуть значение | `user.pop("age", None)` | Без значения по умолчанию при отсутствии ключа — `KeyError` |
| `set` | Множество уникальных элементов | `tags = {"py", "git"}` | Пустое множество — `set()`, потому что `{}` — это словарь. Проверка `in` — O(1) |
| Операции множеств | Объединение, пересечение, разность, симметрическая разность | `a \| b`, `a & b`, `a - b`, `a ^ b` | Быстрый способ убрать дубликаты: `list(dict.fromkeys(items))` — с сохранением порядка |
| `collections.Counter` | Подсчёт элементов | `Counter("abracadabra").most_common(2)` → `[('a', 5), ('b', 2)]` | Поддерживает сложение и вычитание счётчиков |
| `collections.defaultdict` | Словарь со значением по умолчанию | `groups = defaultdict(list); groups[k].append(v)` | Даже чтение отсутствующего ключа создаёт его |
| `collections.deque` | Очередь с быстрыми операциями с обоих концов | `deque(maxlen=3)` | `appendleft` и `popleft` — O(1), а у списка `pop(0)` — O(n) |
| `any` / `all` / `min` / `max` / `sum` | Свёртки | `any(x < 0 for x in nums)` | `max(users, key=len)`; для пустой коллекции нужен `default=` |
| `copy` / `deepcopy` | Поверхностная / глубокая копия | `import copy; b = copy.deepcopy(a)` | `b = a` не копирует, а создаёт вторую ссылку на тот же объект |

## Функции

| Конструкция | Назначение | Пример | Важные замечания |
|---|---|---|---|
| `def` / `return` | Объявить функцию | `def area(w: float, h: float) -> float: return w * h` | Без `return` функция возвращает `None` |
| Аргументы по умолчанию | Необязательные параметры | `def connect(host, port=5432):` | ⚠️ Изменяемое значение по умолчанию (`items=[]`) создаётся один раз и общее для всех вызовов. Пишите `items=None` |
| Именованные аргументы | Явная передача по имени | `connect("db", port=6432)` | Повышают читаемость при большом числе параметров |
| `*args` / `**kwargs` | Произвольное число позиционных / именованных аргументов | `def log(*args, **kwargs): print(args, kwargs)` | Распаковка при вызове: `f(*lst, **dct)` |
| `*` в сигнатуре | Только именованные аргументы после `*` | `def search(query, *, limit=10):` | Нельзя случайно перепутать порядок |
| `/` в сигнатуре | Только позиционные аргументы до `/` | `def clamp(x, /, lo, hi):` | |
| Docstring | Документация функции | `"""Возвращает площадь."""` | Видна в `help(func)` и в подсказках IDE |
| `lambda` | Короткая анонимная функция | `sorted(pairs, key=lambda p: p[1])` | Только одно выражение. Сложную логику оформляйте через `def` |
| `yield` | Функция-генератор | см. пример ниже | Вычисляет значения по одному, экономит память |
| Декоратор | Обёртка над функцией | `@functools.lru_cache(maxsize=None)` | В своих декораторах используйте `@functools.wraps(func)` |
| `global` / `nonlocal` | Изменить переменную внешней области | `nonlocal counter` | Лучше избегать: передавайте значения явно |
| `functools.partial` | Зафиксировать часть аргументов | `to_int = partial(int, base=2); to_int("101")` → `5` | |

```python
import functools
import time

def read_lines(path):
    """Генератор: не загружает файл в память целиком."""
    with open(path, encoding="utf-8") as f:
        for line in f:
            yield line.rstrip("\n")

def timed(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        try:
            return func(*args, **kwargs)
        finally:
            print(f"{func.__name__}: {time.perf_counter() - start:.3f} с")
    return wrapper

@timed
def slow_sum(n: int) -> int:
    return sum(range(n))

slow_sum(10_000_000)   # slow_sum: 0.2 с (время зависит от машины)
```

## Классы

| Конструкция | Назначение | Пример | Важные замечания |
|---|---|---|---|
| `class` + `__init__` | Класс и конструктор | `class User: def __init__(self, name): self.name = name` | `self` — сам экземпляр. Передаётся автоматически |
| `__repr__` / `__str__` | Представление для разработчика / для пользователя | `def __repr__(self): return f"User({self.name!r})"` | `print()` использует `__str__`, а если его нет — `__repr__` |
| `@dataclass` | Класс данных без шаблонного кода | см. пример ниже | Автоматически создаёт `__init__`, `__repr__` и `__eq__` |
| `field(default_factory=...)` | Изменяемое значение по умолчанию в dataclass | `tags: list[str] = field(default_factory=list)` | `tags: list = []` вызовет `ValueError` |
| `@dataclass(frozen=True)` | Неизменяемый объект | `@dataclass(frozen=True) class Point: x: int; y: int` | Можно использовать как ключ словаря |
| `@property` | Вычисляемый атрибут | `@property def full_name(self): ...` | Доступ без скобок: `user.full_name`. Для записи нужен `@full_name.setter` |
| `@classmethod` | Альтернативный конструктор | `@classmethod def from_dict(cls, d): return cls(**d)` | Получает класс (`cls`), поэтому корректно работает в наследниках |
| `@staticmethod` | Функция в пространстве имён класса | `@staticmethod def validate(s): ...` | Не получает ни `self`, ни `cls` |
| Наследование и `super()` | Расширить поведение родителя | `class Admin(User): def __init__(self, name): super().__init__(name)` | Не забывайте вызвать `super().__init__()` |
| `abc.ABC` + `@abstractmethod` | Интерфейс: экземпляр нельзя создать без реализации методов | `class Storage(ABC): @abstractmethod def save(self, x): ...` | |
| `enum.Enum` | Перечисление | `class Color(Enum): RED = "red"` | `Color("red") is Color.RED` → `True` |
| Магические методы | Поведение операторов и встроенных функций | `__len__`, `__iter__`, `__eq__`, `__lt__`, `__contains__` | Если определили `__eq__`, нужен и `__hash__` — иначе объект станет нехешируемым |

```python
from dataclasses import dataclass, field

@dataclass
class Order:
    id: int
    items: list[str] = field(default_factory=list)
    paid: bool = False

    @property
    def size(self) -> int:
        return len(self.items)

    @classmethod
    def from_dict(cls, data: dict) -> "Order":
        return cls(**data)

order = Order.from_dict({"id": 1, "items": ["книга", "ручка"]})
print(order, order.size)   # Order(id=1, items=['книга', 'ручка'], paid=False) 2
```

## Исключения

| Конструкция | Назначение | Пример | Важные замечания |
|---|---|---|---|
| `try` / `except` | Перехватить ошибку | `try: n = int(s) except ValueError: n = 0` | Ловите конкретные исключения. Голый `except:` перехватит даже `Ctrl+C` |
| `except (A, B) as e` | Несколько типов и доступ к объекту ошибки | `except (KeyError, IndexError) as e: print(e)` | |
| `else` | Выполнить, если ошибки не было | `try: ... except ...: ... else: commit()` | Держите в `try` минимум кода |
| `finally` | Выполнить в любом случае | `finally: conn.close()` | Для ресурсов лучше использовать `with` |
| `raise` | Выбросить исключение | `raise ValueError("возраст < 0")` | Голый `raise` внутри `except` повторно выбрасывает текущее исключение с исходным traceback |
| `raise ... from e` | Сохранить причину | `raise ConfigError("плохой конфиг") from e` | В traceback будут видны обе ошибки |
| Своё исключение | Ошибки предметной области | `class AppError(Exception): pass` | Делайте общий базовый класс приложения, чтобы ловить все ошибки одним `except` |
| `with` | Менеджер контекста: гарантированное освобождение ресурса | `with open(p, encoding="utf-8") as f:` | Файл закроется даже при исключении |
| `contextlib.suppress` | Сознательно игнорировать ошибку | `with suppress(FileNotFoundError): p.unlink()` | Только для ожидаемых и безвредных ошибок |
| `@contextmanager` | Свой менеджер контекста | см. пример ниже | Код до `yield` — вход, после — выход |
| `assert` | Проверка для отладки и тестов | `assert x > 0, "x должен быть > 0"` | При запуске с `python -O` проверки удаляются. Входные данные так не проверяют |
| `logging.exception` | Записать ошибку с traceback | `except Exception: logger.exception("Сбой импорта")` | Вызывать только внутри `except` |

Частые встроенные исключения: `ValueError` (неверное значение), `TypeError` (неверный тип), `KeyError`, `IndexError`, `AttributeError`, `FileNotFoundError` и `PermissionError` (подклассы `OSError`), `ZeroDivisionError`, `ModuleNotFoundError`, `json.JSONDecodeError` (подкласс `ValueError`).

```python
from contextlib import contextmanager
import time

@contextmanager
def timer(label: str):
    start = time.perf_counter()
    try:
        yield
    finally:
        print(f"{label}: {time.perf_counter() - start:.3f} с")

with timer("загрузка"):
    data = list(range(1_000_000))
```

## pathlib и файлы

`pathlib.Path` — современный объектный способ работать с путями. Он одинаково работает в Windows и Linux.

| Метод | Назначение | Пример | Важные замечания |
|---|---|---|---|
| `Path("a") / "b"` | Собрать путь | `cfg = Path("config") / "app.json"` | Не склеивайте пути строками через `"/"` или `"\\"` |
| `Path.cwd()` / `Path.home()` | Текущий / домашний каталог | `Path.home() / ".ssh"` | |
| `Path(__file__).resolve().parent` | Каталог текущего скрипта | `BASE = Path(__file__).resolve().parent` | Не зависит от того, откуда запущен скрипт, в отличие от относительных путей |
| `exists` / `is_file` / `is_dir` | Проверки | `if cfg.is_file():` | Между проверкой и действием файл могут удалить. Надёжнее ловить `FileNotFoundError` |
| `name` / `stem` / `suffix` / `parent` | Части пути | `Path("a/b/c.tar.gz").suffix` → `".gz"` | `suffixes` → `['.tar', '.gz']` |
| `with_suffix` / `with_name` | Путь с другим расширением / именем | `p.with_suffix(".bak")` | Возвращает новый путь, файл не трогает |
| `mkdir(parents=True, exist_ok=True)` | Создать каталог с родителями | `Path("out/reports").mkdir(parents=True, exist_ok=True)` | Аналог `mkdir -p` |
| `read_text` / `write_text` | Прочитать / записать файл целиком | `p.write_text("текст", encoding="utf-8")` | ⚠️ **Опасно:** `write_text` перезаписывает файл без предупреждения. **Всегда** указывайте `encoding="utf-8"`: в Windows кодировка по умолчанию может быть `cp1251` |
| `read_bytes` / `write_bytes` | Бинарные данные | `data = img.read_bytes()` | ⚠️ `write_bytes` тоже перезаписывает файл |
| `open` | Потоковое чтение и запись | `with p.open("a", encoding="utf-8") as f: f.write("строка\n")` | Режимы: `r`, `w` (⚠️ обнуляет файл), `a` — дописать, `x` — создать (ошибка, если файл уже есть), `b` — бинарный |
| `iterdir` | Содержимое каталога | `[x.name for x in Path(".").iterdir()]` | Порядок не гарантирован. Нужен порядок — `sorted(...)` |
| `glob` / `rglob` | Поиск по шаблону / рекурсивный | `list(Path("src").rglob("*.py"))` | `glob("**/*.py")` эквивалентен `rglob("*.py")` |
| `stat().st_size` | Размер и время изменения | `p.stat().st_mtime` | |
| `relative_to` | Относительный путь | `p.relative_to(BASE)` | `ValueError`, если `p` не лежит внутри `BASE` |
| `expanduser` / `resolve` | Раскрыть `~` / получить абсолютный путь | `Path("~/data").expanduser()` | |
| `rename` / `replace` | Переименовать или переместить | `tmp.replace(target)` | ⚠️ **Опасно:** `replace` молча перезаписывает цель. `rename` в Windows при существующей цели выбрасывает ошибку, а в Linux — перезаписывает |
| `unlink` | Удалить файл | `p.unlink(missing_ok=True)` | ⚠️ **Опасно:** удаляет без корзины |
| `rmdir` | Удалить **пустой** каталог | `Path("empty").rmdir()` | Непустой каталог не удалит |
| `shutil.rmtree` | Удалить каталог со всем содержимым | `shutil.rmtree(build_dir)` | ⚠️ **Опасно:** аналог `rm -rf`. Проверьте `Path(build_dir).resolve()` перед вызовом: опечатка в пути удалит другой каталог |
| `shutil.copy2` / `copytree` | Копировать файл / дерево | `shutil.copytree("src", "backup", dirs_exist_ok=True)` | ⚠️ `copy2` и `copytree(dirs_exist_ok=True)` перезаписывают совпадающие файлы |
| `tempfile.TemporaryDirectory` | Временный каталог с автоудалением | `with TemporaryDirectory() as d: ...` | Подходит для тестов и промежуточных файлов |

Безопасная запись: сначала во временный файл, потом атомарная замена. Так при сбое старая версия файла останется целой.

```python
from pathlib import Path

def atomic_write(path: Path, text: str) -> None:
    tmp = path.with_name(path.name + ".tmp")
    tmp.write_text(text, encoding="utf-8")
    tmp.replace(path)
```

## JSON

| Функция | Назначение | Пример | Важные замечания |
|---|---|---|---|
| `json.dumps` | Объект → строка JSON | `json.dumps(data, ensure_ascii=False, indent=2)` | Без `ensure_ascii=False` кириллица превратится в `\u041f...` |
| `json.loads` | Строка JSON → объект | `json.loads('{"a": 1}')["a"]` → `1` | При ошибке — `json.JSONDecodeError` с номером строки и колонки |
| `json.dump` | Записать в открытый файл | `with open(p, "w", encoding="utf-8") as f: json.dump(data, f, ensure_ascii=False, indent=2)` | ⚠️ Режим `"w"` обнуляет файл ещё до записи. При ошибке сериализации останется пустой или обрезанный файл. Используйте атомарную запись |
| `json.load` | Прочитать из файла | `with open(p, encoding="utf-8") as f: cfg = json.load(f)` | |
| `sort_keys=True` | Стабильный порядок ключей | `json.dumps(d, sort_keys=True)` | Удобно для диффов в Git |
| `default=` | Сериализовать нестандартные типы | `json.dumps({"t": datetime.now()}, default=str)` | Иначе `TypeError: Object of type datetime is not JSON serializable` |
| `python -m json.tool` | Отформатировать или проверить JSON из командной строки | `python -m json.tool data.json` | Также читает stdin: `curl -s URL \| python -m json.tool`. Флаг `--no-ensure-ascii` сохраняет кириллицу |

Соответствие типов:

| Python | JSON | Замечание |
|---|---|---|
| `dict` | object | Ключи всегда становятся строками: `{1: "a"}` → `{"1": "a"}` |
| `list`, `tuple` | array | При обратном чтении `tuple` превращается в `list` |
| `str` | string | |
| `int`, `float` | number | `float("nan")` выводится как `NaN`, а это не валидный JSON. Запретить можно через `allow_nan=False` |
| `True` / `False` / `None` | `true` / `false` / `null` | |
| `set`, `datetime`, `Path`, `Decimal` | — | Нужен `default=` или ручное преобразование |

## pip

Всегда вызывайте pip через тот интерпретатор, в который ставите пакет: `python -m pip ...`. Так пакет точно попадёт в нужное окружение.

| Команда | Назначение | Пример | Важные замечания |
|---|---|---|---|
| `python -m pip install` | Установить пакет | `python -m pip install requests` | Ставьте пакеты в активированное [venv](#venv), а не в системный Python |
| `install "пакет==версия"` | Конкретная версия или диапазон | `python -m pip install "django>=5,<6"` | Кавычки обязательны: иначе `>` будет понят оболочкой как перенаправление в файл |
| `install -r` | Установить по списку | `python -m pip install -r requirements.txt` | |
| `install -U` | Обновить | `python -m pip install -U pip` | |
| `install -e .` | Установить свой проект в режиме разработки | `python -m pip install -e ".[dev]"` | Изменения кода видны без переустановки. Нужен `pyproject.toml` |
| `uninstall` | Удалить пакет | `python -m pip uninstall -y requests` | Зависимости пакета не удаляются |
| `list` / `list --outdated` | Установленные / устаревшие пакеты | `python -m pip list --outdated` | |
| `show` | Информация о пакете | `python -m pip show requests` | Версия, путь установки, зависимости |
| `freeze` | Зафиксировать версии | `python -m pip freeze > requirements.txt` | ⚠️ `>` перезапишет существующий файл. Попадут **все** пакеты окружения, включая транзитивные |
| `check` | Проверить совместимость зависимостей | `python -m pip check` | |
| `install --user` | Установить в профиль пользователя | `python -m pip install --user httpie` | Для отдельных CLI-утилит удобнее `pipx install httpie` |
| `sudo pip install` | Установить в системный Python | — | ⚠️ **Опасно:** может сломать системные утилиты Linux, которые зависят от системного Python. Не делайте так |
| `--break-system-packages` | Обойти защиту PEP 668 | — | ⚠️ **Опасно:** ошибка `externally-managed-environment` — это защита системного Python. Правильное решение — venv или `pipx` |

## venv

Виртуальное окружение — это изолированный набор пакетов для одного проекта.

| Команда | Назначение | Пример | Важные замечания |
|---|---|---|---|
| `python -m venv .venv` | Создать окружение | `python -m venv .venv` | Добавьте `.venv/` в `.gitignore`. Окружение привязано к пути: при переносе проекта его создают заново |
| Активация в Linux / macOS / WSL | | `source .venv/bin/activate` | В приглашении появится `(.venv)` |
| Активация в Git Bash | | `source .venv/Scripts/activate` | В Windows используется каталог `Scripts`, а не `bin` |
| Активация в PowerShell | | `.venv\Scripts\Activate.ps1` | При ошибке «выполнение сценариев отключено»: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` |
| Активация в cmd | | `.venv\Scripts\activate.bat` | |
| `deactivate` | Выйти из окружения | `deactivate` | |
| Проверка | Какое окружение активно | `python -c "import sys; print(sys.prefix)"` | Или `which python` (Bash), `Get-Command python` (PowerShell) |
| Без активации | Вызвать Python окружения напрямую | `.venv/bin/python -m pytest` | Удобно в скриптах и CI. В Windows: `.venv\Scripts\python.exe` |
| `--upgrade-deps` | Сразу обновить pip в новом окружении | `python -m venv --upgrade-deps .venv` | |
| Пересоздать окружение | Начать с чистого листа | `rm -rf .venv && python -m venv .venv` | ⚠️ **Опасно:** удаляет все установленные пакеты. Сначала `python -m pip freeze > requirements.txt`, если списка зависимостей нет |

## Запуск модулей

| Способ | Что происходит | Пример | Важные замечания |
|---|---|---|---|
| `python script.py` | Запуск файла | `python tools/report.py` | В `sys.path[0]` попадает **каталог скрипта**, поэтому импорт соседних пакетов проекта может не работать |
| `python -m пакет.модуль` | Запуск модуля по имени пакета | `python -m tools.report` | В `sys.path[0]` попадает **текущий каталог**. Работают абсолютные и относительные импорты |
| `python -m пакет` | Запуск пакета | `python -m notes_app list` | Выполняется файл `пакет/__main__.py` |
| `if __name__ == "__main__":` | Код только при прямом запуске | см. пример ниже | При импорте модуля этот блок не выполняется |
| `python -m venv` / `pip` / `pytest` | Инструменты внутри выбранного интерпретатора | `python -m pytest` | Гарантирует, что используется именно этот Python |
| `python -m http.server` | Раздать каталог по HTTP | `python -m http.server 8000 --bind 127.0.0.1` | ⚠️ Без `--bind 127.0.0.1` каталог виден всей сети. Только для разработки |
| `python -m json.tool` | Форматирование JSON | `python -m json.tool data.json` | |
| `python -m pdb` | Отладчик | `python -m pdb app.py` | В коде можно вызвать `breakpoint()`. Команды: `n` — следующая строка, `s` — войти в функцию, `c` — продолжить, `p x` — вывести переменную, `q` — выход |
| `python -m cProfile` | Профилировщик | `python -m cProfile -s cumtime app.py` | Показывает, где тратится время |
| `python -m timeit` | Замер скорости фрагмента | `python -m timeit "sum(range(1000))"` | |
| `python -m py_compile` | Проверить синтаксис без запуска | `python -m py_compile app.py` | |
| `python -m site` | Пути импорта и `site-packages` | `python -m site` | Помогает разобраться с `ModuleNotFoundError` |
| `python -m zipfile` | Работа с zip без сторонних утилит | `python -m zipfile -l archive.zip` | `-c` — создать архив, `-e` — распаковать (⚠️ перезапишет совпадающие файлы) |

```python
# notes_app/__main__.py — точка входа для `python -m notes_app`
from notes_app.cli import main

if __name__ == "__main__":
    raise SystemExit(main())   # код возврата main() станет кодом завершения процесса
```

Живой пример лежит в [`examples/python/notes_app`](../examples/python/notes_app):

```bash
cd examples/python
python -m notes_app --file notes.json add "Купить молоко" --tag дом
python -m notes_app --file notes.json list --tag дом
```

## pytest

| Команда / приём | Назначение | Пример | Важные замечания |
|---|---|---|---|
| Установка | | `python -m pip install pytest` | Ставьте в venv проекта |
| `python -m pytest` | Запустить все тесты | `python -m pytest` | В отличие от `pytest`, добавляет текущий каталог в `sys.path`, поэтому импорты проекта работают |
| Именование | Как pytest находит тесты | файлы `test_*.py` или `*_test.py`, функции `test_*`, классы `Test*` | В классе `Test*` не должно быть `__init__`, иначе он будет пропущен |
| `assert` | Проверка | `assert add(2, 2) == 4` | При падении pytest покажет значения обеих частей сравнения |
| `-v` / `-q` | Подробный / краткий вывод | `python -m pytest -v` | |
| `-x` / `--maxfail=N` | Остановиться после первой / N-й ошибки | `python -m pytest -x` | |
| `-k "выражение"` | Фильтр по имени теста | `python -m pytest -k "storage and not corrupted"` | |
| Путь к тесту | Запустить один файл или один тест | `python -m pytest tests/test_cli.py::test_add_and_list` | |
| `--lf` / `--ff` | Только упавшие в прошлый раз / сначала упавшие | `python -m pytest --lf` | Результаты хранятся в `.pytest_cache` |
| `-s` | Показать `print()` во время тестов | `python -m pytest -s` | По умолчанию вывод перехватывается |
| `--co` | Только показать найденные тесты, не запуская | `python -m pytest --co -q` | Код 5 означает, что тесты не найдены |
| `--durations=5` | 5 самых медленных тестов | `python -m pytest --durations=5` | |
| `@pytest.fixture` | Подготовка данных и ресурсов | см. пример ниже | Код после `yield` в фикстуре — очистка |
| `tmp_path` | Временный каталог для теста | `def test_x(tmp_path): (tmp_path / "a.txt").write_text("x")` | Каждый тест получает отдельный каталог |
| `monkeypatch` | Временно подменить переменные, атрибуты, каталог | `monkeypatch.setenv("API_URL", "http://test")` | После теста всё возвращается автоматически. Есть также `monkeypatch.chdir(tmp_path)` |
| `capsys` | Перехват stdout и stderr | `out = capsys.readouterr().out` | |
| `@pytest.mark.parametrize` | Один тест на много наборов данных | `@pytest.mark.parametrize("a,b,res", [(1, 2, 3), (0, 0, 0)])` | Каждый набор — отдельный тест в отчёте |
| `pytest.raises` | Проверить исключение | `with pytest.raises(ValueError, match="пуст"):` | `match` — регулярное выражение по тексту ошибки |
| `pytest.approx` | Сравнение дробных чисел | `assert 0.1 + 0.2 == pytest.approx(0.3)` | |
| `skip` / `skipif` / `xfail` | Пропуск и ожидаемое падение | `@pytest.mark.skipif(sys.platform == "win32", reason="только Unix")` | |
| `conftest.py` | Общие фикстуры для каталога | `tests/conftest.py` | Импортировать его не нужно: pytest подхватывает файл сам |
| Настройка в `pyproject.toml` | Параметры по умолчанию | `[tool.pytest.ini_options]` → `testpaths = ["tests"]` | См. [`examples/python/pyproject.toml`](../examples/python/pyproject.toml) |

```python
import pytest
from notes_app import NotesStorage

@pytest.fixture
def storage(tmp_path):
    return NotesStorage(tmp_path / "notes.json")

@pytest.mark.parametrize("tag", ["дом", "ДОМ"])
def test_search_ignores_case(storage, tag):
    storage.add("Купить молоко", ["дом"])
    assert len(storage.search(tag=tag)) == 1
```

Коды завершения pytest: `0` — все тесты прошли, `1` — есть упавшие, `2` — прерван пользователем, `4` — ошибка в аргументах командной строки, `5` — тесты не найдены.

## Практические сценарии

**1. Новый проект с нуля (Linux / macOS / WSL).**

```bash
mkdir my-project && cd my-project
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -U pip pytest
mkdir -p src tests
echo ".venv/" >> .gitignore
python -m pip freeze > requirements.txt
python -m pytest     # код 5: тестов пока нет — это нормально
```

То же в PowerShell: `py -m venv .venv`, затем `.venv\Scripts\Activate.ps1`.

**2. Прочитать конфиг с понятной ошибкой.**

```python
import json
from pathlib import Path

DEFAULTS = {"port": 8000, "debug": False}

def load_config(path: Path) -> dict:
    try:
        user_cfg = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        return DEFAULTS.copy()
    except json.JSONDecodeError as e:
        raise SystemExit(f"Ошибка в {path}, строка {e.lineno}: {e.msg}") from e
    return DEFAULTS | user_cfg
```

**3. Обработать все файлы в каталоге.**

```python
from collections import Counter
from pathlib import Path

stats = Counter(p.suffix or "<без расширения>" for p in Path(".").rglob("*") if p.is_file())
for suffix, count in stats.most_common(5):
    print(f"{suffix:>20} {count}")
```

**4. Проверить, какой Python и pip используются.** Это первый шаг при любом `ModuleNotFoundError`.

```bash
python -c "import sys; print(sys.executable)"
python -m pip --version     # путь в выводе должен вести в то же окружение
```

**5. Отладить место ошибки.** Вставьте `breakpoint()` перед подозрительной строкой и запустите программу как обычно. Откроется `pdb`, где `p переменная` выводит значение, а `c` продолжает выполнение.

**6. Полный цикл на примере `examples/python`.**

```bash
cd examples/python
python -m venv .venv && source .venv/bin/activate   # Git Bash: source .venv/Scripts/activate
python -m pip install -r requirements-dev.txt
python -m pytest -v
python -m notes_app add "Первая заметка" --tag тест
python -m notes_app tags
```

## Частые ошибки

| Ошибка | Что происходит | Как правильно |
|---|---|---|
| `def f(items=[])` | Список создаётся один раз и накапливает данные между вызовами | `def f(items=None): items = [] if items is None else items` |
| Удаление элементов списка во время обхода | Элементы пропускаются | `items = [x for x in items if keep(x)]` |
| `x = x.sort()` | `x` становится `None` | `x.sort()` или `x = sorted(x)` |
| `grid = [[0] * 3] * 3` | Три ссылки на **один и тот же** внутренний список | `grid = [[0] * 3 for _ in range(3)]` |
| `0.1 + 0.2 == 0.3` → `False` | Погрешность чисел с плавающей точкой | `math.isclose(a, b)`, `pytest.approx`, `decimal.Decimal` для денег |
| `open(p)` без `encoding` | В Windows `UnicodeDecodeError` или «кракозябры» из-за `cp1251` | `open(p, encoding="utf-8")`, `read_text(encoding="utf-8")` |
| Свой файл `json.py`, `random.py`, `test.py` | Импортируется он вместо стандартного модуля | Не называйте файлы так же, как модули стандартной библиотеки |
| `list = [1, 2]`, `id = 5` | Встроенная функция перекрыта переменной | Выбирайте другие имена: `items`, `user_id` |
| `ModuleNotFoundError` после `pip install` | Пакет установлен в другой интерпретатор | `python -m pip install ...` в активированном venv, проверка через `sys.executable` |
| `attempted relative import with no known parent package` | Модуль с `from . import x` запущен как файл | Запускать как модуль: `python -m package.module` |
| `except:` или `except Exception: pass` | Ошибки молча проглатываются, отладка становится мучением | Ловить конкретные исключения и логировать: `logger.exception(...)` |
| Лямбды в цикле: `[lambda: i for i in range(3)]` | Все функции возвращают 2: значение `i` берётся в момент вызова | `lambda i=i: i` |
| Ключи `int` в JSON | После `dumps` и `loads` ключ `1` стал строкой `"1"` | Преобразовывать при чтении: `{int(k): v for k, v in d.items()}` |
| `is` для сравнения чисел и строк | Работает случайно для небольших чисел, а потом ломается | `==` для значений, `is` — только для `None`, `True`, `False` |
| `python3` в Windows открывает Microsoft Store | Срабатывает псевдоним App Execution Alias | Использовать `py`, отключить псевдонимы или установить Python с python.org |
| `Activate.ps1 cannot be loaded` | Политика выполнения PowerShell запрещает скрипты | `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` |

---

[← Bash](../bash/README.md) · [↑ К оглавлению](#оглавление) · [Git →](../git/README.md)
