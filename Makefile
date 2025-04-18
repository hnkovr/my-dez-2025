#!/bin/bash

define log
echo -e "\033[2m$(date '+%y/%m/%d %H:%M:%S')\033[0m 🌐 \033[1m[$(basename $0)]\033[0m $1"
endef

define run
$(call log,"Running: $1")
$1
endef

#	uv pip install setuptools wheel  && \

install: ## Install Python deps
	uv venv .venv  && \
	. .venv/bin/activate  && \
	uv pip install -r requirements.txt  && \
	python -c "from dagster_dbt import load_assets_from_dbt_project; print('✅ dagster_dbt: OK')"

uninstall:
	. .venv/bin/activate  && \
	uv pip uninstall dagster dagster-webserver dagster-dbt dbt-core dbt-clickhouse pendulum

reinstall: uninstall install

run: ## Run CLI hello
	PYTHONPATH=src python src/main.py hello

ingest: ## Ingest parquet+csv to DuckDB
	PYTHONPATH=src python src/ingest_oltp.py

# DBT
dbt-init: ## Init DBT (debug)
	cd dbt && dbt debug

dbt-run: ## Run DBT models
	cd dbt && dbt run

dbt-docs: ## Serve DBT docs
	cd dbt && dbt docs generate && dbt docs serve

# METABASE
bi-up: ## Start Metabase in Docker
	docker-compose -f docker/metabase.yml up -d

bi-down: ## Stop Metabase
	docker-compose -f docker/metabase.yml down

# DAGSTER
dag-up: ## Start Dagster UI
	. .venv/bin/activate  && \
	cd dagster_project && dagster dev

#dag-install: ## Install Dagster deps
#	. .venv/bin/activate  && \
#	uv pip install dagster dagster-webserver

dag-run: ## Trigger Dagster job locally
	. .venv/bin/activate  && \
	dagster job launch --job ingest_job --workspace dagster_project/workspace.yaml

dag-odp: ## Launch Dagster-ODP (Docker)
	pwd
	ls docker/dagster-odp.yml
	docker compose -f docker/dagster-odp.yml up -d

# CLEANUP
clean: ## Remove build/data artifacts
	rm -rf .venv data/*.duckdb __pycache__

help: ## Show this help
	@awk -F':.*##' '/^[a-zA-Z_-]+:.*##/ {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
