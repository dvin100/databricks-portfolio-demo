/**
 * Lakebase database connection pooling using centralized Databricks authentication
 * Similar to connection-pool.ts but for the lakebase_demo database
 */
import type postgres from 'postgres';
import { getDatabricksToken, getDatabaseUsername } from '@chat-template/auth';
import { buildConnectionUrl, getDatabaseConfigFromEnv } from './connection-core';

// Connection pool management for lakebase
let lakebaseSqlConnection: postgres.Sql | null = null;
let lakebaseCurrentToken: string | null = null;

/**
 * Check if lakebase database is available
 */
export function isLakebaseAvailable(): boolean {
  const isAvailable = !!(process.env.PGHOST);
  console.log('[Lakebase] Database available:', isAvailable);
  return isAvailable;
}

/**
 * Get a pooled connection to the lakebase_demo database
 */
async function getLakebaseConnection(): Promise<postgres.Sql> {
  const { default: postgres } = await import('postgres');
  
  // Get the current token to check if it's changed
  const freshToken = await getDatabricksToken();

  // If we have a connection but the token has changed, we need to recreate the connection
  // This ensures we're always using a valid token
  if (lakebaseSqlConnection && lakebaseCurrentToken !== freshToken) {
    console.log('[Lakebase Pool] Token changed, closing existing connection pool');
    await lakebaseSqlConnection.end();
    lakebaseSqlConnection = null;
    lakebaseCurrentToken = null;
  }

  // Create a new connection if needed
  if (!lakebaseSqlConnection) {
    const config = getDatabaseConfigFromEnv();
    if (!config) {
      throw new Error('PGHOST must be set for lakebase connection');
    }

    const username = await getDatabaseUsername();
    
    // Override database name to lakebase_demo
    const lakebaseConfig = {
      ...config,
      database: 'lakebase_demo',
    };
    
    const connectionUrl = buildConnectionUrl(lakebaseConfig, {
      username,
      password: freshToken,
    });

    lakebaseSqlConnection = postgres(connectionUrl, {
      max: 10, // connection pool size
      idle_timeout: 20, // close idle connections after 20 seconds
      connect_timeout: 10,
      // Important: Set max_lifetime to ensure connections don't outlive the token
      // OAuth tokens typically expire in 1 hour, we'll refresh connections more frequently
      max_lifetime: 60 * 10, // 10 minutes max connection lifetime
    });

    lakebaseCurrentToken = freshToken;
    console.log('[Lakebase Pool] Created new connection pool with fresh OAuth token');
  }

  return lakebaseSqlConnection;
}

/**
 * Get a connection to the lakebase_demo database
 * Returns the postgres.Sql instance for direct queries
 */
export async function getLakebaseDb(): Promise<postgres.Sql> {
  if (!isLakebaseAvailable()) {
    throw new Error(
      'Lakebase database configuration required. Please set PGHOST environment variable.',
    );
  }

  const sql = await getLakebaseConnection();
  return sql;
}

/**
 * Close the lakebase connection pool
 * Useful for cleanup during testing or graceful shutdown
 */
export async function closeLakebasePool(): Promise<void> {
  if (lakebaseSqlConnection) {
    console.log('[Lakebase Pool] Closing connection pool');
    await lakebaseSqlConnection.end();
    lakebaseSqlConnection = null;
    lakebaseCurrentToken = null;
  }
}
