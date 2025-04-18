# ./docker/postgresql.Makefile
.PHONY: pg-install-local pg-start-docker pg-stop-docker pg-logs-docker pg-init-local pg-run-local pg-stop-local

include ../.env

_:
	brew install direnv
	echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
	echo 'layout dotenv' > .envrc
	direnv allow

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
	echo "$(POSTGRES_PASSWORD)" > /tmp/pg_pwd_tmp && \
	initdb -D $(PGDATA) -U $(POSTGRES_USER) --pwfile=/tmp/pg_pwd_tmp && \
	rm /tmp/pg_pwd_tmp

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

.PHONY: pg-create-admin-db

pg-create-admin-db:
	@echo "👤 Creating role $(PGUSER) and database $(PGDB)..."
	@echo "🔍 PGHOST=$(PGHOST) PGPORT=$(PGPORT) PGUSER=$(PGUSER) PGPASSWORD=$(PGPASSWORD) PGDB=$(PGDB)"
	psql -U postgres -h $(PGHOST) -p $(PGPORT) -d postgres -v ON_ERROR_STOP=1 <<-EOSQL
	  DO \$\$
	  BEGIN
	    IF NOT EXISTS (
	      SELECT FROM pg_catalog.pg_roles WHERE rolname = '$(PGUSER)'
	    ) THEN
	      CREATE ROLE $(PGUSER) WITH LOGIN PASSWORD '$(PGPASSWORD)';
	      ALTER ROLE $(PGUSER) CREATEDB;
	      RAISE NOTICE '✅ Role $(PGUSER) created.';
	    ELSE
	      RAISE NOTICE 'ℹ️  Role $(PGUSER) already exists.';
	    END IF;
	  END
	  \$\$;

	  DO \$\$
	  BEGIN
	    IF NOT EXISTS (
	      SELECT FROM pg_database WHERE datname = '$(PGDB)'
	    ) THEN
	      CREATE DATABASE $(PGDB) OWNER $(PGUSER);
	      RAISE NOTICE '✅ Database $(PGDB) created.';
	    ELSE
	      RAISE NOTICE 'ℹ️  Database $(PGDB) already exists.';
	    END IF;
	  END
	  \$\$;
	EOSQL
