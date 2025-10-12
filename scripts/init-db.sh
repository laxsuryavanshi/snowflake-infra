#!/bin/bash
set -e

USERNAME_ARG=""
DBNAME_ARG=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --username)
      USERNAME_ARG="$2"
      shift 2
      ;;
    --dbname)
      DBNAME_ARG="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [--username USER] [--dbname DATABASE]"
      echo "  --username USER     PostgreSQL username (default: \$POSTGRES_USER or 'postgres')"
      echo "  --dbname DATABASE   PostgreSQL database name (default: \$POSTGRES_DB or 'postgres')"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

POSTGRES_USER="${USERNAME_ARG:-${POSTGRES_USER:-postgres}}"
POSTGRES_DB="${DBNAME_ARG:-${POSTGRES_DB:-postgres}}"

# Array of database names to create
DATABASES=("openfga" "idms")

# Create databases if they don't exist
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
$(for db in "${DATABASES[@]}"; do
  echo "    -- Create $db database"
  echo "    SELECT 'CREATE DATABASE $db' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$db')\\gexec"
  echo ""
done)

    -- Grant privileges to the postgres user
$(for db in "${DATABASES[@]}"; do
  echo "    GRANT ALL PRIVILEGES ON DATABASE $db TO postgres;"
done)
EOSQL
