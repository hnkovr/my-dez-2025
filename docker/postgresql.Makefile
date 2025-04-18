# ./docker/postgresql.Makefile
.PHONY: pg-install-local pg-start-docker pg-stop-docker pg-logs-docker pg-init-local pg-run-local pg-stop-local pg-create-admin-db _

include ../.env

_:
	brew install direnv
	echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
	echo 'layout dotenv' > .envrc
	direnv allow

pg-install-local:
	@echo "🔧 Installing PostgreSQL via Homebrew..."
	brew install postgresql || echo "✅ Already installed"
	@bash ./postgresql.Makefile.utils.sh start_postgres_service

pg-init-local:
	@echo "🗂️  Initializing local PostgreSQL database in $(PGDATA)..."
	cd .. && \
	rm -rf $(PGDATA) && \
	mkdir -p $(PGDATA) && \
	echo "$(POSTGRES_PASSWORD)" > /tmp/pg_pwd_tmp && \
	initdb -D $(PGDATA) -U $(POSTGRES_USER) --pwfile=/tmp/pg_pwd_tmp && \
	rm /tmp/pg_pwd_tmp

pg-run-local:
	@echo "🚀 Starting PostgreSQL from $(PGDATA)..."
	cd .. && \
	pg_ctl -D $(PGDATA) -o "-p $(POSTGRES_PORT)" -l $(PGDATA)/logfile start

pg-stop-local:
	@echo "🛑 Stopping PostgreSQL..."
	cd .. && \
	pg_ctl -D $(PGDATA) stop || echo "PostgreSQL was not running"

pg-start-docker:
	@echo "🐳 Starting PostgreSQL in Docker..."
	cd .. && \
	docker compose -f docker/postgresql.yml up -d

pg-stop-docker:
	@echo "🛑 Stopping PostgreSQL in Docker..."
	cd .. && \
	docker compose -f docker/postgresql.yml down

pg-logs-docker:
	@echo "📋 Viewing PostgreSQL Docker logs..."
	cd .. && \
	docker compose -f docker/postgresql.yml logs -f

pg-create-admin-db:
	@echo "👤 Creating role $(POSTGRES_USER) and database $(POSTGRES_DBNAME)..."
	@echo "🔍 Host=$(POSTGRES_HOST) Port=$(POSTGRES_PORT) User=$(POSTGRES_USER) DB=$(POSTGRES_DBNAME)"
	@bash ./postgresql.Makefile.utils.sh create_admin_db