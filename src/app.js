const express = require('express');
const path = require('path');
const pool = require('./config/database');
const todoRoutes = require('./routes/todoRoutes');

const app = express();

app.use(express.json());
app.use(express.static(path.join(__dirname, '../public')));

app.use('/api/todos', todoRoutes);

app.get('/health', async (req, res) => {
    await pool.query('SELECT 1');

    res.status(200).json({
        status: 'healthy',
        database: 'connected'
    });
});

app.use((err, req, res, next) => {
    console.error(err);

    res.status(500).json({
        message: 'Internal server error'
    });
});

module.exports = app;