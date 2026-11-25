
const { spawnSync } = require('child_process');
const fs = require('fs');
const buildDatabaseUrl = require('../config/database-url');

const caPath = process.env.DB_SSL_CA || '/app/global-bundle.pem';

if (!fs.existsSync(caPath)) {
    throw new Error(`RDS CA certificate not found: ${caPath}`);
}

// Build the database URL using the shared configuration.
const databaseUrl = new URL(buildDatabaseUrl());

// Configure PostgreSQL SSL verification.
databaseUrl.searchParams.set('sslmode', 'verify-full');
databaseUrl.searchParams.set('sslrootcert', caPath);

// Make DATABASE_URL available to the migration process.
process.env.DATABASE_URL = databaseUrl.toString();

const result = spawnSync(
    'npm',
    ['run', 'migrate:up'],
    {
        stdio: 'inherit',
        env: process.env
    }
);

if (result.error) {
    throw result.error;
}

process.exit(result.status ?? 1);
