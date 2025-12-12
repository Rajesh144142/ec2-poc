# EC2 POC - Learning Guide

## Infrastructure Overview

### EC2 Instance - t2.micro
- **Instance Type:** t2.micro (Free Tier eligible)
- **Specifications:**
  - 1 vCPU (virtual CPU)
  - 1 GB RAM
  - Burstable performance (CPU credits)
- **Why t2.micro?**
  - Cost-effective for POC/learning
  - Sufficient for small Node.js API
  - Free tier eligible (750 hours/month free)

**Important:** EC2 instance types (t2.micro, t3.micro, etc.) do NOT include ALB. ALB is a separate AWS service you configure independently. Instance type only determines compute resources (CPU, RAM).

### Operating System
- **Amazon Linux 2023**
- Lightweight, optimized for AWS
- Includes essential tools pre-installed
- Default user: `ec2-user`

### VPC (Virtual Private Cloud)
- **What is VPC?**
  - Isolated network environment in AWS
  - Like a private data center in the cloud
- **Why we use it?**
  - Default VPC provides:
    - Public subnet (for internet access)
    - Private subnet (optional, for internal resources)
    - Internet Gateway (connects to internet)
    - Route tables (network routing)
- **Standard Setup:**
  - AWS creates default VPC automatically
  - Includes public subnet with internet gateway
  - Security Groups act as firewall

## Why Docker Containers?

### Benefits:
1. **Consistency:** Same environment (dev/staging/prod)
2. **Isolation:** App runs in its own container
3. **Portability:** Works anywhere Docker runs
4. **Resource Efficiency:** Lightweight compared to VMs
5. **Easy Deployment:** Build once, run anywhere

### How it works:
- Container packages: app code + dependencies + runtime
- Runs on host OS (no separate OS needed)
- Shares host kernel, isolated processes

## Load Balancing: Nginx vs ALB

### Are we using ALB?
**No, we are NOT using ALB in this POC.** We're using Nginx as a reverse proxy.

### What is ALB (Application Load Balancer)?
- **Separate AWS service** (not part of EC2 instance)
- **Independent service** you create and configure separately
- Distributes traffic across multiple targets (EC2 instances, containers)
- Layer 7 (HTTP/HTTPS) load balancing
- Automatic scaling and health checks
- SSL/TLS termination
- Path-based and host-based routing
- **Cost:** ~$16/month + data transfer charges

**Key Point:** ALB is NOT included with any EC2 instance type (t2.micro, t3.micro, etc.). It's a separate service you add to your architecture when needed.

### When to use ALB?
1. **Multiple EC2 instances** across availability zones
2. **Auto-scaling groups** (instances added/removed automatically)
3. **High availability** requirements
4. **AWS-native integration** (ECS, EKS, Lambda)
5. **Production workloads** with high traffic

### Why we use Nginx instead?
1. **Single EC2 instance** (t2.micro POC)
2. **Cost-effective** (no ALB charges ~$16/month)
3. **Simple setup** for learning
4. **Sufficient** for single instance
5. **Full control** over configuration

### Architecture Comparison:

**Current POC (Nginx):**
```
Internet → EC2 Instance → Nginx (Port 80) → Node.js API (Port 3000)
```

**With ALB (Production):**
```
Internet → ALB → Multiple EC2 Instances (Auto Scaling Group)
                ├── EC2 Instance 1 → Nginx → API
                ├── EC2 Instance 2 → Nginx → API
                └── EC2 Instance 3 → Nginx → API
```

### When to upgrade to ALB?
- Need multiple EC2 instances
- Require auto-scaling
- Need high availability (multi-AZ)
- Production traffic requirements
- Want AWS managed service

### Instance Types vs ALB - Clarification:
- **t2.micro, t3.micro, t3.small, etc.** = Just compute resources (CPU, RAM)
- **ALB** = Separate service, works with ANY instance type
- **No instance type includes ALB** - you add it separately
- **You can use ALB with t2.micro, t3.micro, or any instance type**
- **ALB cost is separate** from EC2 instance cost

## Why Nginx?

### What is Nginx?
- Web server and reverse proxy
- High performance, low resource usage

### Why we use it:
1. **Reverse Proxy:** Routes requests to Node.js API
2. **Load Balancing:** Can distribute traffic (if multiple API instances)
3. **SSL/TLS:** Easy to add HTTPS later
4. **Static Files:** Can serve static content efficiently
5. **Production Standard:** Industry standard architecture

### Architecture:
```
Internet → Nginx (Port 80) → Node.js API (Port 3000, internal)
```

## Project Structure

```
ec2-poc/
├── src/
│   └── server.js          # Node.js API
├── nginx/
│   └── nginx.conf         # Nginx configuration
├── Dockerfile             # API container definition
├── docker-compose.yml     # Multi-container setup
└── package.json           # Node.js dependencies
```

## Creating Dockerfile

**Purpose:** Defines how to build API container

```dockerfile
FROM node:18-alpine          # Base image (Node.js 18, Alpine Linux)
WORKDIR /app                 # Set working directory
COPY package*.json ./        # Copy dependency files
RUN npm ci --only=production # Install production dependencies
COPY . .                     # Copy application code
EXPOSE 3000                  # Expose port 3000
USER node                    # Run as non-root user (security)
CMD ["node", "src/server.js"] # Start command
```

**Why Alpine?** Smaller image size (~5MB base vs ~150MB standard)

## Creating Nginx Configuration

**File:** `nginx/nginx.conf`

```nginx
events {
    worker_connections 1024;  # Max concurrent connections
}

http {
    upstream api {
        server api:3000;       # Points to API container
    }

    server {
        listen 80;             # Listen on port 80 (HTTP)
        
        location / {
            proxy_pass http://api;  # Forward requests to API
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
}
```

**Key Points:**
- `upstream api`: Defines backend server (API container)
- `proxy_pass`: Forwards requests to API
- Headers preserve client information

## Creating docker-compose.yml

**Purpose:** Orchestrates multiple containers

```yaml
services:
  api:
    build: .                  # Build from Dockerfile
    container_name: ec2-poc-api
    environment:
      - NODE_ENV=production
      - PORT=3000
    networks:
      - app-network

  nginx:
    image: nginx:alpine       # Use pre-built Nginx image
    container_name: ec2-poc-nginx
    ports:
      - "80:80"               # Map host port 80 to container port 80
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro  # Mount config
    depends_on:
      - api                   # Start API first
    networks:
      - app-network

networks:
  app-network:
    driver: bridge            # Network for containers to communicate
```

**Key Points:**
- `services`: Define containers
- `networks`: Containers can communicate via service names
- `depends_on`: Startup order
- `volumes`: Mount config files

## Connection Steps

### 1. Convert .pem to .ppk (PuTTY)
- Open PuTTYgen
- Load your `.pem` key file
- Save as `.ppk` format

### 2. Connect via PuTTY
- Host: `ec2-user@YOUR_EC2_IP`
- Port: `22`
- Connection → SSH → Auth → Browse (select `.ppk` file)
- Click Open

## Deployment Steps

### 1. Install Git
```bash
sudo yum install git -y
```

### 2. Clone Repository
```bash
git clone https://github.com/Rajesh144142/ec2-poc.git
cd ec2-poc
```

### 3. Install Docker
```bash
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
newgrp docker
```

### 4. Install Docker Compose
```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 5. Build and Deploy
```bash
docker build -t ec2-poc-api .
docker-compose up -d
```

### 6. Verify
```bash
docker ps
curl http://localhost/health
```

### 7. Configure Security Group
- EC2 Console → Security Groups
- Add inbound rule: Port 80, Source: 0.0.0.0/0

### 8. Access API
- `http://YOUR_EC2_IP/health`
- `http://YOUR_EC2_IP/api/status`
- `http://YOUR_EC2_IP/api/data`

## Useful Commands

```bash
docker ps                    # List running containers
docker logs ec2-poc-nginx    # View Nginx logs
docker logs ec2-poc-api      # View API logs
docker stats                 # Resource usage
docker-compose down          # Stop containers
docker-compose restart       # Restart containers
```
