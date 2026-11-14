const fs = require('fs');
const { Pool } = require('pg');
require('dotenv').config({ quiet: true });

const pool = new Pool({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    database: process.env.DB_NAME,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,

    ssl: process.env.NODE_ENV === 'production'
        ? {
            ca: fs.readFileSync(process.env.DB_SSL_CA, 'utf8'),
            rejectUnauthorized: true
        }
        : false
});

module.exports = pool;