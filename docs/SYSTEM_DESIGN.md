# System Design & Architecture

Complete system architecture documentation explaining how requests flow through the system.

---

## 🏗️ System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         INTERNET                                 │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             │ HTTP Request
                             │ (Port 80)
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    AWS EC2 Instance                              │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              Security Group (Firewall)                    │  │
│  │  - Allows: Port 80 (HTTP) from 0.0.0.0/0                 │  │
│  │  - Allows: Port 22 (SSH) from authorized IPs               │  │
│  └────────────────────┬───────────────────────────────────────┘  │
│                       │                                           │
│                       ▼                                           │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              Docker Network (app-network)                 │  │
│  │                                                            │  │
│  │  ┌────────────────────────────────────────────────────┐   │  │
│  │  │  Nginx Container (ec2-poc-nginx)                  │   │  │
│  │  │  - Port: 80 (exposed to host)                      │   │  │
│  │  │  - Role: Reverse Proxy, Rate Limiting, Security    │   │  │
│  │  └──────────────┬─────────────────────────────────────┘   │  │
│  │                 │                                         │  │
│  │                 │ HTTP Proxy (Port 3000)                  │  │
│  │                 ▼                                         │  │
│  │  ┌────────────────────────────────────────────────────┐   │  │
│  │  │  API Container (ec2-poc-api)                        │   │  │
│  │  │  - Port: 3000 (internal, not exposed)              │   │  │
│  │  │  - Process Manager: PM2                            │   │  │
│  │  │  - Runtime: Node.js 18                             │   │  │
│  │  │  - Framework: Express.js                           │   │  │
│  │  └────────────────────────────────────────────────────┘   │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📊 Request Flow: Step-by-Step

### Layer 1: Internet → EC2 Instance

**What Happens:**
1. User/client makes HTTP request: `http://YOUR_EC2_IP/health`
2. Request travels over internet to EC2 instance
3. AWS Security Group acts as firewall

**Security Group Rules:**
- ✅ **Port 80 (HTTP)**: Allowed from `0.0.0.0/0` (anywhere)
- ✅ **Port 22 (SSH)**: Allowed from authorized IPs
- ❌ **Port 3000**: Not exposed (internal only)

**Result:** Request reaches EC2 instance on port 80

---

### Layer 2: EC2 Host → Docker Network

**What Happens:**
1. EC2 host receives request on port 80
2. Docker daemon routes to Nginx container
3. Request enters `app-network` (Docker bridge network)

**Docker Network Configuration:**
```yaml
networks:
  app-network:
    driver: bridge  # Containers can communicate by name
```

**Container Communication:**
- Containers communicate using service names (`api`, `nginx`)
- Docker DNS resolves `api` to API container's IP
- No need for hardcoded IPs

**Result:** Request reaches Nginx container

---

### Layer 3: Nginx Container (Reverse Proxy Layer)

**What Happens:**
1. Nginx receives request on port 80
2. **Rate Limiting Check:**
   - Checks if IP exceeded 10 requests/second
   - Allows burst of 20 additional requests
   - Rejects if over limit (returns 429/503)

3. **Security Headers Added:**
   - `X-Frame-Options: SAMEORIGIN`
   - `X-Content-Type-Options: nosniff`
   - `X-XSS-Protection: 1; mode=block`

4. **Request Forwarding:**
   - Proxies request to `http://api:3000`
   - Adds proxy headers:
     - `X-Real-IP`: Client's real IP
     - `X-Forwarded-For`: Proxy chain
     - `Host`: Original host header

**Nginx Configuration:**
```nginx
upstream api {
    server api:3000;  # Points to API container
}

location / {
    limit_req zone=api_limit burst=20 nodelay;
    proxy_pass http://api;  # Forward to API
}
```

**Result:** Request forwarded to API container with security headers

---

### Layer 4: API Container (Application Layer)

**What Happens:**
1. **PM2 Process Manager:**
   - Receives request
   - Routes to Node.js process
   - Manages process lifecycle (auto-restart on crash)

2. **Express.js Framework:**
   - Parses HTTP request
   - Extracts route, method, headers, body
   - Matches route pattern

3. **Route Handler Execution:**
   ```javascript
   app.get('/health', (req, res) => {
     // Handler logic executes
     res.status(200).json({ status: 'healthy' });
   });
   ```

4. **Response Generation:**
   - Handler processes request
   - Creates JSON response
   - Sets HTTP status code
   - Sends response back

**API Container Details:**
- **Runtime:** Node.js 18 (Alpine Linux)
- **Process Manager:** PM2 (auto-restart, monitoring)
- **Framework:** Express.js
- **Port:** 3000 (internal, not exposed to internet)
- **Data Storage:** In-memory (for POC)

**Result:** Response generated and sent back

---

### Layer 5: Response Flow (Reverse Path)

**What Happens:**
1. API container sends response to Nginx
2. Nginx forwards response to client
3. Response travels back through:
   - Docker network
   - EC2 host
   - Security Group
   - Internet
4. Client receives response

**Response Headers:**
- Security headers (added by Nginx)
- Content-Type: application/json
- Status code (200, 404, etc.)

---

## 🔄 Complete Request Flow Example

### Example: `GET /api/users`

```
1. Client Request
   └─> http://YOUR_EC2_IP/api/users
       │
       ▼
2. Internet
   └─> Request travels to EC2 IP
       │
       ▼
3. Security Group (Port 80)
   └─> ✅ Allowed (HTTP traffic permitted)
       │
       ▼
4. Docker Network
   └─> Request routed to Nginx container
       │
       ▼
5. Nginx Container
   ├─> Rate Limit Check: ✅ Passed
   ├─> Security Headers: Added
   └─> Proxy: Forward to api:3000
       │
       ▼
6. API Container
   ├─> PM2: Routes to Node.js process
   ├─> Express: Matches route /api/users
   ├─> Handler: Executes GET /api/users logic
   └─> Response: JSON with users array
       │
       ▼
7. Response Path (Reverse)
   └─> Nginx → Docker Network → EC2 → Internet → Client
       │
       ▼
8. Client Receives
   └─> {
         "success": true,
         "count": 2,
         "data": [...]
       }
```

---

## 🏛️ System Layers Breakdown

### Layer 1: Network Layer (Internet)
- **Component:** Internet/Network
- **Role:** Transport requests/responses
- **Protocol:** HTTP/HTTPS
- **Port:** 80 (HTTP)

### Layer 2: Security Layer (AWS Security Group)
- **Component:** EC2 Security Group
- **Role:** Firewall, access control
- **Rules:**
  - Allow HTTP (port 80) from anywhere
  - Allow SSH (port 22) from authorized IPs
  - Block direct access to port 3000

### Layer 3: Container Orchestration (Docker)
- **Component:** Docker Engine, Docker Network
- **Role:** Container management, networking
- **Network:** Bridge network (`app-network`)
- **Containers:** Nginx, API

### Layer 4: Reverse Proxy Layer (Nginx)
- **Component:** Nginx Container
- **Role:**
  - Rate limiting (10 req/sec per IP)
  - Security headers
  - Request forwarding
  - Load balancing (if multiple API instances)
- **Port:** 80 (exposed)
- **Configuration:** `nginx/nginx.conf`

### Layer 5: Application Layer (Node.js API)
- **Component:** API Container
- **Role:**
  - Business logic
  - Route handling
  - Data processing
  - Response generation
- **Port:** 3000 (internal)
- **Framework:** Express.js
- **Process Manager:** PM2

### Layer 6: Data Layer (In-Memory)
- **Component:** JavaScript variables/arrays
- **Role:** Data storage (temporary)
- **Note:** Data lost on restart (POC only)
- **Production:** Should use database (RDS, MongoDB, etc.)

---

## 🔐 Security Layers

### 1. Network Security
- **Security Group:** Controls inbound/outbound traffic
- **Private Network:** API not directly exposed
- **Port Restrictions:** Only necessary ports open

### 2. Application Security (Nginx)
- **Rate Limiting:** Prevents DDoS/abuse
- **Security Headers:** XSS, clickjacking protection
- **Request Filtering:** Validates requests before forwarding

### 3. Container Security
- **Non-root User:** API runs as `node` user (not root)
- **Isolated Network:** Containers in separate network
- **Resource Limits:** Can be added via Docker

---

## 📦 Container Architecture

### Nginx Container
```
Image: nginx:alpine
Container: ec2-poc-nginx
Ports: 80:80 (host:container)
Network: app-network
Volumes: nginx.conf (read-only)
Dependencies: api (starts after API)
```

### API Container
```
Image: ec2-poc-api (custom build)
Container: ec2-poc-api
Ports: 3000 (internal only)
Network: app-network
Process: PM2 → Node.js → Express
Environment: NODE_ENV=production, PORT=3000
```

---

## 🔄 Process Flow Details

### Request Processing Pipeline

```
1. HTTP Request Arrives
   │
   ├─> Parse HTTP headers
   ├─> Extract method, path, query params
   └─> Read request body (if POST/PUT)
       │
       ▼
2. Route Matching
   │
   ├─> Express router matches pattern
   ├─> Middleware execution (if any)
   └─> Route handler selection
       │
       ▼
3. Business Logic
   │
   ├─> Execute handler function
   ├─> Process data
   ├─> Validate input
   └─> Generate response data
       │
       ▼
4. Response Generation
   │
   ├─> Set status code
   ├─> Set headers
   ├─> Serialize JSON
   └─> Send response
```

---

## 🚀 Deployment Flow

### CI/CD Pipeline Flow

```
1. Developer pushes code to GitHub
   │
   ▼
2. GitHub Actions triggers
   │
   ├─> Checkout code
   ├─> Setup Node.js
   ├─> Install dependencies
   ├─> Run tests
   └─> Build Docker image
       │
       ▼
3. Test Docker Image
   │
   ├─> Start container
   ├─> Wait for readiness
   └─> Health check
       │
       ▼
4. Deploy to EC2 (if tests pass)
   │
   ├─> SSH to EC2
   ├─> Pull latest code
   ├─> Build Docker image
   ├─> Stop old containers
   └─> Start new containers
       │
       ▼
5. Health Check
   │
   └─> Verify API responds
```

---

## 📈 Scalability Considerations

### Current Architecture (Single Instance)
- **EC2 Instances:** 1
- **API Containers:** 1
- **Nginx Containers:** 1
- **Database:** None (in-memory)

### Production Architecture (Scalable)
```
Internet
   │
   ├─> Application Load Balancer (ALB)
   │   │
   │   ├─> EC2 Instance 1
   │   │   ├─> Nginx
   │   │   └─> API Container
   │   │
   │   └─> EC2 Instance 2
   │       ├─> Nginx
   │       └─> API Container
   │
   └─> RDS Database (shared)
```

---

## 🔍 Monitoring & Logging

### Log Flow
```
API Container
   │
   ├─> PM2 Logs → ./logs/out.log
   ├─> Error Logs → ./logs/err.log
   └─> Docker Logs → docker logs ec2-poc-api

Nginx Container
   │
   └─> Access Logs → /var/log/nginx/access.log
   └─> Error Logs → /var/log/nginx/error.log
```

### Health Monitoring
- **Health Endpoint:** `/health`
- **Status Endpoint:** `/api/status`
- **PM2 Monitoring:** Process health, memory usage
- **Docker Health:** Container status

---

## 🎯 Key Design Decisions

### Why Nginx?
- **Reverse Proxy:** Hides internal API structure
- **Rate Limiting:** Protects against abuse
- **Security Headers:** Adds security layer
- **Future:** Easy to add SSL/TLS, load balancing

### Why Docker?
- **Consistency:** Same environment (dev/staging/prod)
- **Isolation:** Containers don't interfere
- **Portability:** Works anywhere Docker runs
- **Easy Deployment:** Build once, run anywhere

### Why PM2?
- **Process Management:** Auto-restart on crash
- **Monitoring:** Process health tracking
- **Zero Downtime:** Can reload without downtime
- **Production Ready:** Industry standard

### Why Express.js?
- **Lightweight:** Minimal overhead
- **Flexible:** Easy to add middleware
- **Popular:** Large ecosystem
- **Simple:** Easy to understand and maintain

---

## 📝 Summary

**Request Journey:**
```
Internet → Security Group → Docker Network → Nginx → API → Response
```

**Key Points:**
1. **Security:** Multiple layers (Security Group, Nginx, Container isolation)
2. **Scalability:** Can scale horizontally (add more EC2 instances)
3. **Reliability:** PM2 auto-restarts, Docker restart policies
4. **Performance:** Nginx handles static content, rate limiting
5. **Maintainability:** Clear separation of concerns

This architecture provides a solid foundation for a POC that can scale to production with minimal changes.

