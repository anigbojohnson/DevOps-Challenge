const request = require('supertest');
const app = require('../src/app');
const pool = require('../src/config/database');

describe('Todo API Integration Tests', () => {
    let todoId;

    // 1. CREATE TODO
    test('POST /api/todos - should create a todo', async () => {
        const response = await request(app)
            .post('/api/todos')
            .send({
                title: 'Learn DevOps',
                description: 'Complete the DevOps practical challenge'
            });

        expect(response.statusCode).toBe(201);
        expect(response.body.message).toBe('Todo created successfully');
        expect(response.body.data.title).toBe('Learn DevOps');

        todoId = response.body.data.id;
    });

    // 2. VALIDATE TODO INPUT
    test('POST /api/todos - should reject an empty title', async () => {
        const response = await request(app)
            .post('/api/todos')
            .send({
                title: '   '
            });

        expect(response.statusCode).toBe(400);
        expect(response.body.message).toBe('A valid title is required');
    });

    // 3. READ ALL TODOS
    test('GET /api/todos - should retrieve all todos', async () => {
        const response = await request(app)
            .get('/api/todos');

        expect(response.statusCode).toBe(200);
        expect(response.body).toHaveProperty('count');
        expect(response.body).toHaveProperty('data');
        expect(Array.isArray(response.body.data)).toBe(true);
    });

    // 4. READ TODO BY ID
    test('GET /api/todos/:id - should retrieve a todo', async () => {
        const response = await request(app)
            .get(`/api/todos/${todoId}`);

        expect(response.statusCode).toBe(200);
        expect(response.body.data.id).toBe(todoId);
    });

    // 5. TEST NONEXISTENT TODO
    test('GET /api/todos/:id - should return 404 for missing todo', async () => {
        const response = await request(app)
            .get('/api/todos/999999999');

        expect(response.statusCode).toBe(404);
        expect(response.body.message).toBe('Todo not found');
    });

    // 6. UPDATE TODO
    test('PUT /api/todos/:id - should update a todo', async () => {
        const response = await request(app)
            .put(`/api/todos/${todoId}`)
            .send({
                title: 'Learn Advanced DevOps',
                description: 'Complete CI/CD and AWS deployment'
            });

        expect(response.statusCode).toBe(200);
        expect(response.body.data.title).toBe('Learn Advanced DevOps');
    });

    // 7. UPDATE TODO COMPLETION STATUS
    test('PATCH /api/todos/:id/status - should update completion status', async () => {
        const response = await request(app)
            .patch(`/api/todos/${todoId}/status`)
            .send({
                completed: true
            });

        expect(response.statusCode).toBe(200);
        expect(response.body.data.completed).toBe(true);
    });

    // 8. VALIDATE COMPLETION STATUS
    test('PATCH /api/todos/:id/status - should reject invalid status', async () => {
        const response = await request(app)
            .patch(`/api/todos/${todoId}/status`)
            .send({
                completed: 'yes'
            });

        expect(response.statusCode).toBe(400);
        expect(response.body.message).toBe('Completed must be true or false');
    });

    // 9. DELETE TODO
    test('DELETE /api/todos/:id - should delete a todo', async () => {
        const response = await request(app)
            .delete(`/api/todos/${todoId}`);

        expect(response.statusCode).toBe(200);
        expect(response.body.message).toBe('Todo deleted successfully');
    });

    // 10. VERIFY DELETION
    test('GET /api/todos/:id - should return 404 after deletion', async () => {
        const response = await request(app)
            .get(`/api/todos/${todoId}`);

        expect(response.statusCode).toBe(404);
    });

    // 11. HEALTH CHECK
    test('GET /health - should confirm application and database health', async () => {
        const response = await request(app)
            .get('/health');

        expect(response.statusCode).toBe(200);
        expect(response.body.status).toBe('healthy');
        expect(response.body.database).toBe('connected');
    });
});

afterAll(async () => {
    await pool.end();
});