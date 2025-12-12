require('dotenv').config();
const express = require('express');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString() 
  });
});

app.get('/api/status', (req, res) => {
  res.status(200).json({ 
    message: 'API is running',
    environment: process.env.NODE_ENV || 'development',
    port: PORT
  });
});

app.get('/api/data', (req, res) => {
  res.status(200).json({ 
    data: [
      { id: 1, name: 'Item 1' },
      { id: 2, name: 'Item 2' },
      { id: 3, name: 'Item 3' }
    ]
  });
});

app.post('/api/data', (req, res) => {
  const { name } = req.body;
  
  if (!name) {
    return res.status(400).json({ error: 'Name is required' });
  }
  
  res.status(201).json({ 
    id: Date.now(), 
    name,
    createdAt: new Date().toISOString()
  });
});

// In-memory data store
let users = [
  { id: 1, name: 'John Doe', email: 'john@example.com', createdAt: new Date().toISOString() },
  { id: 2, name: 'Jane Smith', email: 'jane@example.com', createdAt: new Date().toISOString() }
];

// GET /api/users - Get all users
app.get('/api/users', (req, res) => {
  res.status(200).json({
    success: true,
    count: users.length,
    data: users
  });
});

// GET /api/users/:id - Get a specific user
app.get('/api/users/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const user = users.find(u => u.id === id);
  
  if (!user) {
    return res.status(404).json({ 
      success: false,
      error: 'User not found' 
    });
  }
  
  res.status(200).json({
    success: true,
    data: user
  });
});

// POST /api/users - Create a new user
app.post('/api/users', (req, res) => {
  const { name, email } = req.body;
  
  if (!name || !email) {
    return res.status(400).json({ 
      success: false,
      error: 'Name and email are required' 
    });
  }
  
  const newUser = {
    id: users.length > 0 ? Math.max(...users.map(u => u.id)) + 1 : 1,
    name,
    email,
    createdAt: new Date().toISOString()
  };
  
  users.push(newUser);
  
  res.status(201).json({
    success: true,
    data: newUser
  });
});

// PUT /api/users/:id - Update a user
app.put('/api/users/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const { name, email } = req.body;
  
  const userIndex = users.findIndex(u => u.id === id);
  
  if (userIndex === -1) {
    return res.status(404).json({ 
      success: false,
      error: 'User not found' 
    });
  }
  
  if (name) users[userIndex].name = name;
  if (email) users[userIndex].email = email;
  
  res.status(200).json({
    success: true,
    data: users[userIndex]
  });
});

// DELETE /api/users/:id - Delete a user
app.delete('/api/users/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const userIndex = users.findIndex(u => u.id === id);
  
  if (userIndex === -1) {
    return res.status(404).json({ 
      success: false,
      error: 'User not found' 
    });
  }
  
  const deletedUser = users.splice(userIndex, 1)[0];
  
  res.status(200).json({
    success: true,
    message: 'User deleted successfully',
    data: deletedUser
  });
});

app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});

