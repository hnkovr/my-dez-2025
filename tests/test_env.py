from pathlib import Path
import os

def test_env_file_exists(project_root):
    assert (project_root / ".env").exists()

def test_env_variables_loaded(monkeypatch, project_root):
    env_path = project_root / ".env"
    content = env_path.read_text()
    for var in ["CLICKHOUSE_HOST", "METABASE_HOST"]:
        assert var in content
