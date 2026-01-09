-- Database and table name variables
-- DB_NAME: lakebase_demo
-- TABLE_NAME: users

-- 3. Create database
CREATE DATABASE lakebase_demo;

-- Connect to the new database
\c lakebase_demo

-- 4 & 5. Create table with name, dob, phone fields
CREATE TABLE users (
    name VARCHAR(100),
    dob DATE,
    phone VARCHAR(20)
);

-- 6. Insert 10 rows
INSERT INTO users (name, dob, phone) VALUES
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
GRANT ALL PRIVILEGES ON DATABASE lakebase_demo TO PUBLIC;
GRANT ALL PRIVILEGES ON SCHEMA public TO PUBLIC;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO PUBLIC;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO PUBLIC;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO PUBLIC;

-- Select all inserted data
SELECT * FROM users;
