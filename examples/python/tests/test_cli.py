from notes_app.cli import main


def test_add_and_list(tmp_path, capsys):
    notes_file = str(tmp_path / "notes.json")

    assert main(["--file", notes_file, "add", "Позвонить маме", "--tag", "семья"]) == 0
    assert main(["--file", notes_file, "list"]) == 0

    out = capsys.readouterr().out
    assert "Добавлено: 1. Позвонить маме [семья]" in out
    assert "1. Позвонить маме [семья]" in out


def test_list_empty(tmp_path, capsys):
    assert main(["--file", str(tmp_path / "notes.json"), "list"]) == 0
    assert "Заметок не найдено" in capsys.readouterr().out


def test_error_goes_to_stderr_with_exit_code_1(tmp_path, capsys):
    broken = tmp_path / "notes.json"
    broken.write_text("{сломано", encoding="utf-8")

    assert main(["--file", str(broken), "list"]) == 1
    captured = capsys.readouterr()
    assert captured.out == ""
    assert "Ошибка:" in captured.err


def test_default_file_is_created_in_current_directory(monkeypatch, tmp_path):
    monkeypatch.chdir(tmp_path)

    assert main(["add", "Файл по умолчанию"]) == 0
    assert (tmp_path / "notes.json").exists()
