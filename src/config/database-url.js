
function buildDatabaseUrl() {
    // Use an existing DATABASE_URL for local development.
    if (!process.env.RDS_MASTER_SECRET) {
        if (process.env.DATABASE_URL) {
            return process.env.DATABASE_URL;
        }

        throw new Error(
            'RDS_MASTER_SECRET or DATABASE_URL must be provided'
        );
    }

    // Parse credentials injected by ECS from AWS Secrets Manager.
    const credentials = JSON.parse(process.env.RDS_MASTER_SECRET);

    const host = process.env.DB_HOST || credentials.host;
    const port = process.env.DB_PORT || credentials.port || '5432';
    const database = process.env.DB_NAME || credentials.dbname;

    if (!host || !database || !credentials.username || !credentials.password) {
        throw new Error('Database connection configuration is incomplete');
    }

    const databaseUrl = new URL('postgresql://localhost');

    databaseUrl.username = credentials.username;
    databaseUrl.password = credentials.password;
    databaseUrl.hostname = host;
    databaseUrl.port = port;
    databaseUrl.pathname = `/${database}`;

    return databaseUrl.toString();
}

module.exports = buildDatabaseUrl;
