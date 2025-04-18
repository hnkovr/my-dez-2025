from dagster_dbt import load_assets_from_dbt_project

import os
from pathlib import Path
print(os.getcwd())
print(f"# {os.getcwd() = }")
print(f"# {Path.cwd = }")

dbt_assets = load_assets_from_dbt_project(
    ##project_dir="./dbt/my_dez_2025",
    # project_dir="../../dbt/my_dez_2025",
    project_dir="/Users/github/@dataengy/my-dez-2025/dbt",

    # profiles_dir="~/.dbt",
    # profiles_dir="../dbt",
    profiles_dir="/Users/github/@dataengy/my-dez-2025/dbt",
)
