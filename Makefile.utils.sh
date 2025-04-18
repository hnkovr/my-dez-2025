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
