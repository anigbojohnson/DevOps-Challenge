const fs = require('fs');
const { Pool } = require('pg');
require('dotenv').config({ quiet: true });

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    connectionTimeoutMillis: 10000,

    ssl: process.env.NODE_ENV === 'production' || process.env.NODE_ENV === 'development'
        ? {
            ca: fs.readFileSync(process.env.DB_SSL_CA, 'utf8'),
            rejectUnauthorized: true
        }
        : false
});

module.exports = pool;