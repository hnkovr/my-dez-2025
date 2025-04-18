PROJECT_NAME := my-dez-2025
PYTHON := /usr/local/bin/python3.12
VENV := .venv
REQS := requirements.txt
ACTIVATE := source $(VENV)/bin/activate

.PHONY: all install check clean venv run

all: install

install: clean venv
	$(ACTIVATE) && uv pip install -r $(REQS)

venv:
	$(PYTHON) -m venv $(VENV)

check:
	$(ACTIVATE) && python -c "from dagster_dbt import load_assets_from_dbt_project; print('✅ dagster_dbt: OK')"

clean:
	rm -rf $(VENV)

run:
	$(ACTIVATE) && python src/main.py

