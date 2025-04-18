# ./docker/postgresql.Makefile
.PHONY: pg-install-local pg-start-docker pg-stop-docker pg-logs-docker pg-init-local pg-run-local pg-stop-local

include ../.env

pg-install-local:
	@echo "🔧 Installing PostgreSQL via Homebrew..."
	brew install postgresql || echo "✅ Already installed"
	brew services start postgresql

pg-init-local:
	@echo "🗂️  Initializing local PostgreSQL database in $(PGDATA)..."
	@cat postgresql.Makefile
	cd .. && \
	rm -rf $(PGDATA) && \
	mkdir -p $(PGDATA) && \
	initdb -D $(PGDATA) -U $(POSTGRES_USER) --pwfile=<(echo $(POSTGRES_PASSWORD))

pg-run-local:
	@echo "🚀 Starting PostgreSQL from $(PGDATA)..."
	cd .. && \
	pg_ctl -D $(PGDATA) -o "-p $(POSTGRES_PORT)" -l $(PGDATA)/logfile start

pg-stop-local:
	cd .. && \
	pg_ctl -D $(PGDATA) stop

pg-start-docker:
	cd .. && \
	docker compose -f docker/postgresql.yml up -d

pg-stop-docker:
	cd .. && \
	docker compose -f docker/postgresql.yml down

pg-logs-docker:
	cd .. && \
	docker compose -f docker/postgresql.yml logs -f
