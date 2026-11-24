const { spawnSync } = require('child_process');

const credentials = JSON.parse(process.env.RDS_MASTER_SECRET);

const databaseUrl = new URL('postgresql://localhost');

databaseUrl.username = credentials.username;
databaseUrl.password = credentials.password;
databaseUrl.hostname = process.env.DB_HOST;
databaseUrl.port = process.env.DB_PORT || '5432';
databaseUrl.pathname = `/${process.env.DB_NAME}`;

process.env.DATABASE_URL = databaseUrl.toString();

const result = spawnSync(
    'npm',
    ['run', 'migrate:up'],
    {
        stdio: 'inherit',
        env: process.env
    }
);

process.exit(result.status ?? 1);