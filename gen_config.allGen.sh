#!/bin/bash
# 📁 gen_config.allGen.sh — базовая генерация конфигурации проекта

set -e
mkdir -p src

# 🔧 .env + шаблоны
cat > .env.template <<EOF
# ClickHouse
CLICKHOUSE_HOST=localhost
CLICKHOUSE_PORT=8123
CLICKHOUSE_USER=default
CLICKHOUSE_PASSWORD=
CLICKHOUSE_DB=nyc_taxi

# Metabase
METABASE_HOST=localhost
METABASE_PORT=3000
EOF

cp .env.template .env.local
cp .env.template .env

# 🔧 config.yaml
cat > config.yaml <<EOF
project: my-dez-2025
paths:
  data: ./data
  logs: ./logs
  src: ./src
EOF

# 🐍 pyproject.toml
cat > pyproject.toml <<EOF
[project]
name = "my-dez-2025"
version = "0.1.0"
description = "Minimal DE Zoomcamp 2025 pipeline using DuckDB + ClickHouse + dbt + Metabase"
authors = [{name = "vndv", email = "you@example.com"}]
license = "MIT"
requires-python = ">=3.12"

[tool.uv]
virtualenvs.in-project = true
EOF

# 📦 requirements.txt
cat > requirements.txt <<EOF
fastcore
click
duckdb
requests
EOF

# 📄 Makefile
cat > Makefile <<EOF
include Makefile.utils.sh

.DEFAULT_GOAL := help

help:  ## Show this help
	@awk -F':.*##' '/^[a-zA-Z_-]+:.*##/ {printf "  \033[36m%-16s\033[0m %s\n", \$1, \$2}' \$(MAKEFILE_LIST)
EOF

# ⚙️ Makefile.utils.sh
cat > Makefile.utils.sh <<'EOF'
#!/bin/bash

define log
echo -e "\033[2m$(date '+%y/%m/%d %H:%M:%S')\033[0m 🌐 \033[1m[$(basename $0)]\033[0m $1"
endef

define run
$(call log,"Running: $1")
$1
endef

install: ## Install dependencies
	uv pip install -r requirements.txt

run: ## Run entry script
	python3 src/main.py
EOF

chmod +x Makefile.utils.sh

# 📘 README.md
cat > README.md <<EOF
# my-dez-2025

🚕 Minimal Data Engineering pipeline for NYC Yellow Taxi 2025 trip data
Built with **DuckDB**, **ClickHouse**, **dbt**, and **Metabase**.
All runs **locally**, with optional support for Docker and Dagster-ODP.

## Setup

\`\`\`bash
make install
make run
\`\`\`

## Project structure

- OLTP: DuckDB
- DWH: ClickHouse
- Transforms: dbt
- Dashboard: Metabase
- Orchestration: Makefile + utils.sh (optional: Dagster)

## Authors

- @vndv, 2025
EOF

# 📁 .gitignore + .gptignore
cat > .gitignore <<EOF
__pycache__/
*.db
.venv/
.env
.env.*
logs/
EOF

cp .gitignore .gptignore

# 📄 all-files.txt
find . -type f | grep -vE '.git|.gptignore|__pycache__' | sort > all-files.txt

# 🟣 Git init + push
git init
git add .
git commit -m "🧬 init: base project setup"
gh repo create my-dez-2025 --private --source=. --push || git push -u origin main

echo "✅ Project 'my-dez-2025' initialized!"
