const todoService = require('../services/todoService');

// CREATE
const createTodo = async (req, res) => {
    const { title, description } = req.body;

    if (!title || typeof title !== 'string' || !title.trim()) {
        return res.status(400).json({
            message: 'A valid title is required'
        });
    }

    const todo = await todoService.createTodo(
        title.trim(),
        description
    );

    res.status(201).json({
        message: 'Todo created successfully',
        data: todo
    });
};

// READ ALL
const getAllTodos = async (req, res) => {
    const todos = await todoService.getAllTodos();

    res.status(200).json({
        count: todos.length,
        data: todos
    });
};

// READ ONE
const getTodoById = async (req, res) => {
    const todo = await todoService.getTodoById(req.params.id);

    if (!todo) {
        return res.status(404).json({
            message: 'Todo not found'
        });
    }

    res.status(200).json({ data: todo });
};

// UPDATE
const updateTodo = async (req, res) => {
    const { title, description } = req.body;

    if (!title || typeof title !== 'string' || !title.trim()) {
        return res.status(400).json({
            message: 'A valid title is required'
        });
    }

    const todo = await todoService.updateTodo(
        req.params.id,
        title.trim(),
        description
    );

    if (!todo) {
        return res.status(404).json({
            message: 'Todo not found'
        });
    }

    res.status(200).json({
        message: 'Todo updated successfully',
        data: todo
    });
};

// UPDATE STATUS
const updateTodoStatus = async (req, res) => {
    const { completed } = req.body;

    if (typeof completed !== 'boolean') {
        return res.status(400).json({
            message: 'Completed must be true or false'
        });
    }

    const todo = await todoService.updateTodoStatus(
        req.params.id,
        completed
    );

    if (!todo) {
        return res.status(404).json({
            message: 'Todo not found'
        });
    }

    res.status(200).json({
        message: 'Todo status updated',
        data: todo
    });
};

// DELETE
const deleteTodo = async (req, res) => {
    const todo = await todoService.deleteTodo(req.params.id);

    if (!todo) {
        return res.status(404).json({
            message: 'Todo not found'
        });
    }

    res.status(200).json({
        message: 'Todo deleted successfully',
        data: todo
    });
};

// Health check
const healthCheck = async (req, res) => {
  res.status(200).json({
    status: 'healthy',
    message: 'Todo application is running'
  });
};

module.exports = {
    createTodo,
    getAllTodos,
    getTodoById,
    updateTodo,
    updateTodoStatus,
    deleteTodo,
    healthCheck
};