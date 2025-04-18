include Makefile.utils.sh

.DEFAULT_GOAL := help

setup:
	su - user
	brew install tree
	@make install

tree:
	tree -a -L 2

help:  ## Show this help
	@awk -F':.*##' '/^[a-zA-Z_-]+:.*##/ {printf "  \033[36m%-16s\033[0m %s\n", $1, $2}' $(MAKEFILE_LIST)

install: install

