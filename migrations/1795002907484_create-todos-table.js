/**
 * @type {import('node-pg-migrate').ColumnDefinitions | undefined}
 */
export const shorthands = undefined;

/**
 * @param pgm {import('node-pg-migrate').MigrationBuilder}
 * @param run {() => void | undefined}
 * @returns {Promise<void> | void}
 */
export const up = (pgm) => {
     pgm.createTable('todos', {
        id: {
            type: 'BIGSERIAL',
            primaryKey: true
        },
        title: {
            type: 'VARCHAR(255)',
            notNull: true
        },
        description: {
            type: 'TEXT'
        },
        completed: {
            type: 'BOOLEAN',
            default: false
        },
        created_at: {
            type: 'TIMESTAMPTZ',
            default: pgm.func('CURRENT_TIMESTAMP')
        },
        updated_at: {
            type: 'TIMESTAMPTZ',
            default: pgm.func('CURRENT_TIMESTAMP')
        }
    });
};

/**
 * @param pgm {import('node-pg-migrate').MigrationBuilder}
 * @param run {() => void | undefined}
 * @returns {Promise<void> | void}
 */
export const down = (pgm) => {
     pgm.dropTable('todos');
};
