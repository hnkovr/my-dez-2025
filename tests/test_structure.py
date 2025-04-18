def test_common_files_exist(project_root):
    files = [
        ".env", "config.yaml", "Makefile",
        "README.md", "pyproject.toml", "requirements.txt",
        ".gptignore", ".gitignore"
    ]
    for f in files:
        assert (project_root / f).exists()

def test_common_dirs_exist(project_root):
    for d in ["src", "tests", "common"]:
        assert (project_root / d).is_dir()
