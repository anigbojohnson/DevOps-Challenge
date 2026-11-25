
const fs = require('fs');
const { Pool } = require('pg');
require('dotenv').config({ quiet: true });

const buildDatabaseUrl = require('./database-url');

// Use DATABASE_URL if available; otherwise build it from ECS credentials.
const databaseUrl = process.env.DATABASE_URL || buildDatabaseUrl();

// Make the URL available to other modules in this process.
process.env.DATABASE_URL = databaseUrl;

const useSSL =
    process.env.NODE_ENV === 'production' ||
    process.env.NODE_ENV === 'dev' ||
    Boolean(process.env.RDS_MASTER_SECRET);

const pool = new Pool({
    connectionString: databaseUrl,
    connectionTimeoutMillis: 10000,

    ssl: useSSL
        ? {
            ca: fs.readFileSync(
                process.env.DB_SSL_CA || '/app/global-bundle.pem',
                'utf8'
            ),
            rejectUnauthorized: true
        }
        : false
});

module.exports = pool;
