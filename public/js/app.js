const API_URL = '/api/todos';

const todoForm = document.getElementById('todo-form');
const titleInput = document.getElementById('title');
const descriptionInput = document.getElementById('description');
const todoList = document.getElementById('todo-list');
const message = document.getElementById('message');
const taskCount = document.getElementById('task-count');

const formHeading = document.getElementById('form-heading');
const submitButton = document.getElementById('submit-button');
const cancelButton = document.getElementById('cancel-button');

let editingTodoId = null;

// Display messages
function showMessage(text, type = 'success') {
    message.textContent = text;
    message.className = `message-${type}`;

    setTimeout(() => {
        message.textContent = '';
        message.className = '';
    }, 4000);
}

// Make API requests
async function apiRequest(url, options = {}) {
    const response = await fetch(url, {
        ...options,
        headers: {
            'Content-Type': 'application/json',
            ...options.headers
        }
    });

    const result = await response.json();

    if (!response.ok) {
        throw new Error(result.message || 'Something went wrong');
    }

    return result;
}

// READ: Get all tasks
async function loadTodos() {
    todoList.innerHTML = '<p class="loading">Loading tasks...</p>';

    try {
        const result = await apiRequest(API_URL);

        displayTodos(result.data);

    } catch (error) {
        todoList.textContent = error.message;
        showMessage(error.message, 'error');
    }
}

// Display tasks
function displayTodos(todos) {
    todoList.replaceChildren();

    taskCount.textContent =
        `${todos.length} ${todos.length === 1 ? 'task' : 'tasks'}`;

    if (todos.length === 0) {
        const empty = document.createElement('p');
        empty.className = 'empty';
        empty.textContent = 'No tasks yet. Add your first task!';
        todoList.appendChild(empty);
        return;
    }

    todos.forEach(todo => {
        const item = document.createElement('article');
        item.className = 'todo-item';

        const top = document.createElement('div');
        top.className = 'todo-item-top';

        const checkbox = document.createElement('input');
        checkbox.type = 'checkbox';
        checkbox.checked = todo.completed;
        checkbox.setAttribute('aria-label', `Complete ${todo.title}`);

        checkbox.addEventListener('change', () => {
            updateTodoStatus(todo.id, checkbox.checked);
        });

        const content = document.createElement('div');
        content.className = 'todo-content';

        if (todo.completed) {
            content.classList.add('completed');
        }

        const title = document.createElement('h3');
        title.textContent = todo.title;

        const description = document.createElement('p');
        description.textContent = todo.description || 'No description provided.';

        content.append(title, description);
        top.append(checkbox, content);

        const date = document.createElement('div');
        date.className = 'todo-date';
        date.textContent = `Created: ${new Date(todo.created_at).toLocaleString()}`;

        const actions = document.createElement('div');
        actions.className = 'todo-actions';

        const editButton = document.createElement('button');
        editButton.type = 'button';
        editButton.className = 'edit-button';
        editButton.textContent = 'Edit';
        editButton.addEventListener('click', () => editTodo(todo));

        const deleteButton = document.createElement('button');
        deleteButton.type = 'button';
        deleteButton.className = 'delete-button';
        deleteButton.textContent = 'Delete';
        deleteButton.addEventListener('click', () => deleteTodo(todo.id));

        actions.append(editButton, deleteButton);
        item.append(top, date, actions);

        todoList.appendChild(item);
    });
}

// CREATE and UPDATE
todoForm.addEventListener('submit', async (event) => {
    event.preventDefault();

    const title = titleInput.value.trim();
    const description = descriptionInput.value.trim();

    if (!title) {
        showMessage('Please enter a task title.', 'error');
        return;
    }

    const isEditing = editingTodoId !== null;

    const url = isEditing
        ? `${API_URL}/${editingTodoId}`
        : API_URL;

    const method = isEditing ? 'PUT' : 'POST';

    submitButton.disabled = true;

    try {
        await apiRequest(url, {
            method,
            body: JSON.stringify({ title, description })
        });

        showMessage(
            isEditing ? 'Task updated successfully!' : 'Task created successfully!'
        );

        resetForm();
        await loadTodos();

    } catch (error) {
        showMessage(error.message, 'error');

    } finally {
        submitButton.disabled = false;
    }
});

// Load a task into the form for editing
function editTodo(todo) {
    editingTodoId = todo.id;

    titleInput.value = todo.title;
    descriptionInput.value = todo.description || '';

    formHeading.textContent = 'Edit task';
    submitButton.textContent = 'Update Task';
    cancelButton.hidden = false;

    window.scrollTo({ top: 0, behavior: 'smooth' });
}

// Cancel editing
function resetForm() {
    editingTodoId = null;

    todoForm.reset();

    formHeading.textContent = 'Add a new task';
    submitButton.textContent = 'Add Task';
    cancelButton.hidden = true;
}

cancelButton.addEventListener('click', resetForm);

// UPDATE: Completion status
async function updateTodoStatus(id, completed) {
    try {
        await apiRequest(`${API_URL}/${id}/status`, {
            method: 'PATCH',
            body: JSON.stringify({ completed })
        });

        showMessage('Task status updated successfully!');
        await loadTodos();

    } catch (error) {
        showMessage(error.message, 'error');
        await loadTodos();
    }
}

// DELETE
async function deleteTodo(id) {
    const confirmed = confirm('Are you sure you want to delete this task?');

    if (!confirmed) return;

    try {
        await apiRequest(`${API_URL}/${id}`, {
            method: 'DELETE'
        });

        showMessage('Task deleted successfully!');
        await loadTodos();

    } catch (error) {
        showMessage(error.message, 'error');
    }
}

// Load tasks when the page opens
loadTodos();