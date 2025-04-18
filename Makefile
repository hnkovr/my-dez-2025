#include Makefile.utils.sh

.DEFAULT_GOAL := help

define log
echo -e "\033[2m$(date '+%y/%m/%d %H:%M:%S')\033[0m 🌐 \033[1m[$(basename $0)]\033[0m $1"
endef

define run
$(call log,"Running: $1")
$1
endef

setup:
#	su - user
#	brew install tree
	@make install

tree:
	tree -a -L 2

help:  ## Show this help
	@awk -F':.*##' '/^[a-zA-Z_-]+:.*##/ {printf "  \033[36m%-16s\033[0m %s\n", $1, $2}' $(MAKEFILE_LIST)

install: ## Create venv & install requirements
	uv venv .venv
	source .venv/bin/activate && uv pip install -r requirements.txt

activate: ## Activate virtualenv
	. .venv/bin/activate

run: ## Run entry script
	python3 src/main.py

test:
	. .venv/bin/activate
	pytest tests/

