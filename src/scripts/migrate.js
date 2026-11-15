const fs = require('fs');
const path = require('path');
const pool = require('../config/database');

async function migrate() {
    const schemaPath = path.join(__dirname, '../config/schema.sql');
    const schema = fs.readFileSync(schemaPath, 'utf8');

    try {
        console.log('Starting database migration...');

        await pool.query(schema);

        console.log('Database migration completed successfully.');
    } catch (error) {
        console.error('Database migration failed:', error);
        process.exitCode = 1;
    } finally {
        await pool.end();
    }
}

migrate();