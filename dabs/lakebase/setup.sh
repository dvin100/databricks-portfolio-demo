#!/bin/bash

# 1. Ask for psql connection string
echo "=== PostgreSQL Setup Script ==="
echo ""
echo "Enter PostgreSQL connection string (can include 'psql' command or just the connection params):"
echo "Example: psql \"host=... user=... dbname=... port=... sslmode=...\""
echo "     or: host=... user=... dbname=... port=... sslmode=..."
echo ""
read -p "Connection string: " PSQL_CONN_STRING

# Strip 'psql' command if present and remove outer quotes
PSQL_CONN_STRING=$(echo "$PSQL_CONN_STRING" | sed 's/^psql[[:space:]]*//g' | sed 's/^"\(.*\)"$/\1/')

# 2. Ask for OAuth token and store it in a variable
echo ""
read -s -p "Enter OAuth token: " OAUTH_TOKEN
echo ""
echo "✓ OAuth token stored in memory"
echo ""

# Define database and table name variables
DB_NAME="lakebase_demo"
TABLE_NAME="users"

# Export PGPASSWORD to use the OAuth token automatically
export PGPASSWORD="$OAUTH_TOKEN"

echo "✓ Will grant database access to all users (PUBLIC)"
echo ""

# 3-6. Create SQL file with database creation, table creation, and data insertion
SQL_FILE="setup.sql"
cat > "$SQL_FILE" <<EOF
-- Database and table name variables
-- DB_NAME: ${DB_NAME}
-- TABLE_NAME: ${TABLE_NAME}

-- 3. Create database
CREATE DATABASE ${DB_NAME};

-- Connect to the new database
\c ${DB_NAME}

-- 4 & 5. Create table with name, dob, phone fields
CREATE TABLE ${TABLE_NAME} (
    name VARCHAR(100),
    dob DATE,
    phone VARCHAR(20)
);

-- 6. Insert 10 rows
INSERT INTO ${TABLE_NAME} (name, dob, phone) VALUES
('John Doe', '1985-03-15', '555-0101'),
('Jane Smith', '1990-07-22', '555-0102'),
('Michael Johnson', '1978-11-30', '555-0103'),
('Emily Davis', '1995-01-08', '555-0104'),
('David Wilson', '1982-05-19', '555-0105'),
('Sarah Brown', '1988-09-25', '555-0106'),
('James Taylor', '1992-12-03', '555-0107'),
('Emma Martinez', '1987-04-17', '555-0108'),
('Robert Anderson', '1993-08-11', '555-0109'),
('Lisa Garcia', '1980-06-28', '555-0110');

-- Grant privileges to all users (PUBLIC)
GRANT ALL PRIVILEGES ON DATABASE ${DB_NAME} TO PUBLIC;
GRANT ALL PRIVILEGES ON SCHEMA public TO PUBLIC;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO PUBLIC;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO PUBLIC;

-- Select all inserted data
SELECT * FROM ${TABLE_NAME};
EOF

echo "✓ SQL file created: $SQL_FILE"
echo "  - Database name: ${DB_NAME}"
echo "  - Table name: ${TABLE_NAME}"
echo ""

# Execute the SQL file
echo "Executing SQL setup..."
echo "Using connection: $PSQL_CONN_STRING"
echo ""

psql "$PSQL_CONN_STRING" -f "$SQL_FILE"

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Setup complete!"
    echo "  - Database '$DB_NAME' created"
    echo "  - Table '$TABLE_NAME' created with 10 rows"
else
    echo ""
    echo "✗ Setup failed. Please check the connection string and try again."
    exit 1
fi

# Create export variables script for local development.
./create_export_vars.sh

echo "Creating database catalog in Databricks..."
databricks database create-database-catalog lakebase_data lakebase-portfolio lakebase_demo