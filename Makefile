#!/bin/bash

define log
echo -e "\033[2m$(date '+%y/%m/%d %H:%M:%S')\033[0m 🌐 \033[1m[$(basename $0)]\033[0m $1"
endef

define run
$(call log,"Running: $1")
$1
endef

install: ## Install dependencies via uv
	uv venv .venv
	source .venv/bin/activate && uv pip install -r requirements.txt

run: ## Run hello CLI
	PYTHONPATH=src python src/main.py hello

ingest: ## Load parquet + csv into DuckDB
	PYTHONPATH=src python src/ingest_oltp.py

dbt-init: ## Run dbt debug and setup
	cd dbt && dbt debug

dbt-run: ## Run dbt models
	cd dbt && dbt run

dbt-docs: ## Serve docs
	cd dbt && dbt docs generate && dbt docs serve

bi-up: ## Launch Metabase (docker)
	docker-compose -f docker/metabase.yml up -d

bi-down: ## Stop Metabase
	docker-compose -f docker/metabase.yml down
