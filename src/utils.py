from pathlib import Path

def ensure_dir(path: str | Path):
    Path(path).mkdir(parents=True, exist_ok=True)

def read_lines(path: str | Path) -> list[str]:
    return Path(path).read_text().splitlines()
