const pool = require('../config/database');

// CREATE
const createTodo = async (title, description) => {
    const result = await pool.query(
        `INSERT INTO todos (title, description)
         VALUES ($1, $2)
         RETURNING *`,
        [title, description || null]
    );

    return result.rows[0];
};

// READ ALL
const getAllTodos = async () => {
    const result = await pool.query(
        'SELECT * FROM todos ORDER BY created_at DESC'
    );

    return result.rows;
};

// READ ONE
const getTodoById = async (id) => {
    const result = await pool.query(
        'SELECT * FROM todos WHERE id = $1',
        [id]
    );

    return result.rows[0];
};

// UPDATE
const updateTodo = async (id, title, description) => {
    const result = await pool.query(
        `UPDATE todos
         SET title = $1,
             description = $2,
             updated_at = CURRENT_TIMESTAMP
         WHERE id = $3
         RETURNING *`,
        [title, description || null, id]
    );

    return result.rows[0];
};

// UPDATE COMPLETION STATUS
const updateTodoStatus = async (id, completed) => {
    const result = await pool.query(
        `UPDATE todos
         SET completed = $1,
             updated_at = CURRENT_TIMESTAMP
         WHERE id = $2
         RETURNING *`,
        [completed, id]
    );

    return result.rows[0];
};

// DELETE
const deleteTodo = async (id) => {
    const result = await pool.query(
        'DELETE FROM todos WHERE id = $1 RETURNING *',
        [id]
    );

    return result.rows[0];
};

module.exports = {
    createTodo,
    getAllTodos,
    getTodoById,
    updateTodo,
    updateTodoStatus,
    deleteTodo
};