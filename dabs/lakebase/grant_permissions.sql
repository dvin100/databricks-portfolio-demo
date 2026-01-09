-- Grant permissions for lakebase_demo database
-- Grants access to ALL users (PUBLIC)

-- Connect to the lakebase_demo database
\c lakebase_demo

-- Grant database-level privileges to all users
GRANT ALL PRIVILEGES ON DATABASE lakebase_demo TO PUBLIC;

-- Grant schema-level privileges to all users
GRANT ALL PRIVILEGES ON SCHEMA public TO PUBLIC;

-- Grant privileges on all existing tables to all users
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO PUBLIC;

-- Grant privileges on all sequences to all users
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO PUBLIC;

-- Grant default privileges for future tables to all users
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO PUBLIC;

-- Grant default privileges for future sequences to all users
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO PUBLIC;

-- Verify the grants
\dp users
