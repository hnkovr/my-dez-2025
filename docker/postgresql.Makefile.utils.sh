#!/bin/bash
# ./docker/postgresql.Makefile.utils.sh
# Utility functions for PostgreSQL Makefile
clear
cat $0

# Source environment variables if they're not already available
if [ -z "$POSTGRES_USER" ]; then
  if [ -f "../.env" ]; then
    source "../.env"
  fi
fi

# Function to start PostgreSQL service safely
start_postgres_service() {
  echo "🚀 Attempting to start PostgreSQL service..."

  # Try brew services first, but don't fail if it doesn't work
  brew services start postgresql || brew services start postgresql@14 || true

  # Check if PostgreSQL is running by trying to connect
  if psql -U postgres -c "SELECT 1" postgres &>/dev/null; then
    echo "✅ PostgreSQL is running with postgres user"
  elif psql -U $(whoami) -c "SELECT 1" postgres &>/dev/null; then
    echo "✅ PostgreSQL is running with $(whoami) user"
  else
    echo "⚠️ Could not connect to PostgreSQL with standard users"
    echo "ℹ️ Will try to start manually using pg_ctl"

    # Find PostgreSQL data directory from Homebrew
    PG_DIR=$(brew --prefix)/var/postgresql
    if [ ! -d "$PG_DIR" ]; then
      PG_DIR=$(brew --prefix)/var/postgresql@14
    fi

    if [ -d "$PG_DIR" ]; then
      echo "🔍 Found PostgreSQL data directory: $PG_DIR"
      pg_ctl -D "$PG_DIR" start || echo "⚠️ Failed to start PostgreSQL manually"
    else
      echo "❌ Could not find PostgreSQL data directory"
    fi
  fi
}

# Function to create admin user and database
create_admin_db() {
  # Determine which PostgreSQL user can connect
  local ADMIN_USER=""

  # Try connecting with postgres user first
  if psql -U postgres -c "SELECT 1" postgres &>/dev/null; then
    ADMIN_USER="postgres"
  # Then try the current user
  elif psql -U $(whoami) -c "SELECT 1" postgres &>/dev/null; then
    ADMIN_USER=$(whoami)
  else
    echo "❌ Could not connect to PostgreSQL. Make sure it's running."
    return 1
  fi

  echo "🔑 Connected to PostgreSQL with user: $ADMIN_USER"

  # Create user and database
  psql -U "$ADMIN_USER" -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -d postgres -v ON_ERROR_STOP=1 <<-EOSQL
    DO \$\$
    BEGIN
      IF NOT EXISTS (
        SELECT FROM pg_catalog.pg_roles WHERE rolname = '$POSTGRES_USER'
      ) THEN
        CREATE ROLE $POSTGRES_USER WITH LOGIN PASSWORD '$POSTGRES_PASSWORD';
        ALTER ROLE $POSTGRES_USER CREATEDB;
        RAISE NOTICE '✅ Role $POSTGRES_USER created.';
      ELSE
        RAISE NOTICE 'ℹ️ Role $POSTGRES_USER already exists.';
      END IF;
    END
    \$\$;

    DO \$\$
    BEGIN
      IF NOT EXISTS (
        SELECT FROM pg_database WHERE datname = '$POSTGRES_DBNAME'
      ) THEN
        CREATE DATABASE $POSTGRES_DBNAME OWNER $POSTGRES_USER;
        RAISE NOTICE '✅ Database $POSTGRES_DBNAME created.';
      ELSE
        RAISE NOTICE 'ℹ️ Database $POSTGRES_DBNAME already exists.';
      END IF;
    END
    \$\$;
EOSQL

  if [ $? -eq 0 ]; then
    echo "✅ Database setup completed successfully"
  else
    echo "❌ Database setup failed"
    return 1
  fi
}

# Main function to handle command line arguments
main() {
  if [ "$1" = "start_postgres_service" ]; then
    start_postgres_service
  elif [ "$1" = "create_admin_db" ]; then
    create_admin_db
  else
    echo "Usage: $0 {start_postgres_service|create_admin_db}"
    exit 1
  fi
}

# Execute main with all arguments
main "$@"