# API Documentation

Complete API reference for the EC2 POC API.

**Base URL:** `http://YOUR_EC2_IP`

All endpoints are accessible through Nginx reverse proxy on port 80.

---

## Health & Status Endpoints

### GET /health

Health check endpoint for monitoring and load balancers.

**Request:**
```http
GET /health HTTP/1.1
Host: YOUR_EC2_IP
```

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2025-12-12T14:30:00.000Z"
}
```

**Status Code:** `200 OK`

---

### GET /api/status

Get API status and environment information.

**Request:**
```http
GET /api/status HTTP/1.1
Host: YOUR_EC2_IP
```

**Response:**
```json
{
  "message": "API is running",
  "environment": "production",
  "port": 3000
}
```

**Status Code:** `200 OK`

---

## Sample Data Endpoints

### GET /api/data

Get sample data items.

**Request:**
```http
GET /api/data HTTP/1.1
Host: YOUR_EC2_IP
```

**Response:**
```json
{
  "data": [
    { "id": 1, "name": "Item 1" },
    { "id": 2, "name": "Item 2" },
    { "id": 3, "name": "Item 3" }
  ]
}
```

**Status Code:** `200 OK`

---

### POST /api/data

Create a new data item.

**Request:**
```http
POST /api/data HTTP/1.1
Host: YOUR_EC2_IP
Content-Type: application/json

{
  "name": "New Item"
}
```

**Request Body:**
- `name` (string, required) - Name of the item

**Response:**
```json
{
  "id": 1702386000000,
  "name": "New Item",
  "createdAt": "2025-12-12T14:30:00.000Z"
}
```

**Status Code:** `201 Created`

**Error Response (400 Bad Request):**
```json
{
  "error": "Name is required"
}
```

---

## Users API (CRUD Operations)

### GET /api/users

Get all users.

**Request:**
```http
GET /api/users HTTP/1.1
Host: YOUR_EC2_IP
```

**Response:**
```json
{
  "success": true,
  "count": 2,
  "data": [
    {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "createdAt": "2025-12-12T14:00:00.000Z"
    },
    {
      "id": 2,
      "name": "Jane Smith",
      "email": "jane@example.com",
      "createdAt": "2025-12-12T14:00:00.000Z"
    }
  ]
}
```

**Status Code:** `200 OK`

---

### GET /api/users/:id

Get a specific user by ID.

**Request:**
```http
GET /api/users/1 HTTP/1.1
Host: YOUR_EC2_IP
```

**Path Parameters:**
- `id` (integer, required) - User ID

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "createdAt": "2025-12-12T14:00:00.000Z"
  }
}
```

**Status Code:** `200 OK`

**Error Response (404 Not Found):**
```json
{
  "success": false,
  "error": "User not found"
}
```

---

### POST /api/users

Create a new user.

**Request:**
```http
POST /api/users HTTP/1.1
Host: YOUR_EC2_IP
Content-Type: application/json

{
  "name": "Alice Johnson",
  "email": "alice@example.com"
}
```

**Request Body:**
- `name` (string, required) - User's full name
- `email` (string, required) - User's email address

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 3,
    "name": "Alice Johnson",
    "email": "alice@example.com",
    "createdAt": "2025-12-12T14:30:00.000Z"
  }
}
```

**Status Code:** `201 Created`

**Error Response (400 Bad Request):**
```json
{
  "success": false,
  "error": "Name and email are required"
}
```

---

### PUT /api/users/:id

Update an existing user.

**Request:**
```http
PUT /api/users/1 HTTP/1.1
Host: YOUR_EC2_IP
Content-Type: application/json

{
  "name": "John Updated",
  "email": "john.updated@example.com"
}
```

**Path Parameters:**
- `id` (integer, required) - User ID

**Request Body:**
- `name` (string, optional) - Updated name
- `email` (string, optional) - Updated email

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "John Updated",
    "email": "john.updated@example.com",
    "createdAt": "2025-12-12T14:00:00.000Z"
  }
}
```

**Status Code:** `200 OK`

**Error Response (404 Not Found):**
```json
{
  "success": false,
  "error": "User not found"
}
```

---

### DELETE /api/users/:id

Delete a user by ID.

**Request:**
```http
DELETE /api/users/1 HTTP/1.1
Host: YOUR_EC2_IP
```

**Path Parameters:**
- `id` (integer, required) - User ID

**Response:**
```json
{
  "success": true,
  "message": "User deleted successfully",
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "createdAt": "2025-12-12T14:00:00.000Z"
  }
}
```

**Status Code:** `200 OK`

**Error Response (404 Not Found):**
```json
{
  "success": false,
  "error": "User not found"
}
```

---

## Error Responses

All endpoints may return the following error responses:

### 404 Not Found
```json
{
  "error": "Route not found"
}
```

### 400 Bad Request
```json
{
  "error": "Error message describing what went wrong"
}
```

---

## Rate Limiting

The API is protected by rate limiting:
- **Limit:** 10 requests per second per IP address
- **Burst:** Up to 20 additional requests allowed
- **Exceeded Limit Response:** `429 Too Many Requests` or `503 Service Unavailable`

---

## Example Usage

### Using cURL

```bash
# Health check
curl http://YOUR_EC2_IP/health

# Get all users
curl http://YOUR_EC2_IP/api/users

# Get user by ID
curl http://YOUR_EC2_IP/api/users/1

# Create user
curl -X POST http://YOUR_EC2_IP/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Alice","email":"alice@example.com"}'

# Update user
curl -X PUT http://YOUR_EC2_IP/api/users/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"Alice Updated","email":"alice.updated@example.com"}'

# Delete user
curl -X DELETE http://YOUR_EC2_IP/api/users/1
```

### Using PowerShell

```powershell
# Health check
Invoke-RestMethod -Uri "http://YOUR_EC2_IP/health"

# Get all users
Invoke-RestMethod -Uri "http://YOUR_EC2_IP/api/users"

# Create user
$body = @{
    name = "Alice"
    email = "alice@example.com"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://YOUR_EC2_IP/api/users" `
  -Method Post `
  -Body $body `
  -ContentType "application/json"
```

---

## Notes

- **Data Persistence:** Currently uses in-memory storage. Data is lost on server restart.
- **Authentication:** No authentication required (for POC purposes).
- **CORS:** Not configured (for POC purposes).
- **HTTPS:** Currently HTTP only. HTTPS should be configured for production.

