# How to Check Base URL from EC2 Server

## Understanding Your Setup

Your API is accessible through **Nginx on port 80**, which proxies requests to your Node.js API on port 3000.

**Base URL Format:** `http://YOUR_EC2_PUBLIC_IP`

---

## Method 1: Find EC2 Public IP from AWS Console

1. Go to **AWS Console** → **EC2 Dashboard**
2. Click **Instances** (running)
3. Find your instance
4. Look at **Public IPv4 address** column
5. Your base URL: `http://YOUR_PUBLIC_IP`

**Example:** If IP is `44.223.6.71`, base URL is `http://44.223.6.71`

---

## Method 2: Find IP from EC2 Server (SSH into EC2)

### Option A: Using AWS Metadata Service (Recommended)

```bash
# Get public IP
curl http://169.254.169.254/latest/meta-data/public-ipv4

# Get private IP
curl http://169.254.169.254/latest/meta-data/local-ipv4

# Get instance ID
curl http://169.254.169.254/latest/meta-data/instance-id
```

**Example Output:**
```bash
$ curl http://169.254.169.254/latest/meta-data/public-ipv4
44.223.6.71
```

### Option B: Using hostname command

```bash
# Get public IP
hostname -I | awk '{print $1}'

# Or get public hostname
curl -s http://169.254.169.254/latest/meta-data/public-hostname
```

### Option C: Using ifconfig

```bash
# Install net-tools if needed
sudo yum install net-tools -y

# Check IP addresses
ifconfig
# Look for eth0 or ens5 interface
```

---

## Method 3: Test Base URL from EC2 Server

### Test Health Endpoint (from inside EC2)

```bash
# Test localhost (from EC2 server)
curl http://localhost/health

# Test using public IP (from EC2 server)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
curl http://$PUBLIC_IP/health

# Test all endpoints
curl http://localhost/api/status
curl http://localhost/api/users
curl http://localhost/api/data
```

### Test with Full Response Details

```bash
# Verbose output with headers
curl -v http://localhost/health

# Pretty JSON output
curl http://localhost/api/users | python3 -m json.tool

# Or with jq (if installed)
curl http://localhost/api/users | jq
```

---

## Method 4: Test from Your Local Machine

### Using curl (Linux/Mac/Git Bash)

```bash
# Replace with your actual EC2 IP
EC2_IP="44.223.6.71"

# Test health endpoint
curl http://$EC2_IP/health

# Test API status
curl http://$EC2_IP/api/status

# Test users endpoint
curl http://$EC2_IP/api/users

# Test with POST request
curl -X POST http://$EC2_IP/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com"}'
```

### Using PowerShell (Windows)

```powershell
# Set your EC2 IP
$EC2_IP = "44.223.6.71"

# Test health endpoint
Invoke-RestMethod -Uri "http://$EC2_IP/health"

# Test API status
Invoke-RestMethod -Uri "http://$EC2_IP/api/status"

# Test users endpoint
Invoke-RestMethod -Uri "http://$EC2_IP/api/users"

# Test with POST request
$body = @{
    name = "Test User"
    email = "test@example.com"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://$EC2_IP/api/users" -Method Post -Body $body -ContentType "application/json"
```

### Using Browser

Simply open in your browser:
```
http://YOUR_EC2_IP/health
http://YOUR_EC2_IP/api/status
http://YOUR_EC2_IP/api/users
```

---

## Method 5: Quick Check Script (Run on EC2)

Create a script to check everything:

```bash
#!/bin/bash
# Save as: check-api.sh

echo "=== EC2 API Base URL Checker ==="
echo ""

# Get public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "📍 Public IP: $PUBLIC_IP"
echo "🌐 Base URL: http://$PUBLIC_IP"
echo ""

# Check if containers are running
echo "📦 Container Status:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

# Test endpoints
echo "🧪 Testing Endpoints:"
echo ""

echo "1. Health Check:"
curl -s http://localhost/health | python3 -m json.tool 2>/dev/null || curl -s http://localhost/health
echo ""

echo "2. API Status:"
curl -s http://localhost/api/status | python3 -m json.tool 2>/dev/null || curl -s http://localhost/api/status
echo ""

echo "3. Users API:"
curl -s http://localhost/api/users | python3 -m json.tool 2>/dev/null || curl -s http://localhost/api/users
echo ""

echo "✅ All checks complete!"
echo "🌐 Access your API at: http://$PUBLIC_IP"
```

**Usage:**
```bash
# Make executable
chmod +x check-api.sh

# Run it
./check-api.sh
```

---

## Method 6: Check Container Logs

If endpoints aren't working, check logs:

```bash
# Check Nginx logs
docker logs ec2-poc-nginx

# Check API logs
docker logs ec2-poc-api

# Follow logs in real-time
docker logs -f ec2-poc-api

# Check last 50 lines
docker logs --tail=50 ec2-poc-api
```

---

## Method 7: Verify Port Accessibility

### Check if port 80 is listening

```bash
# Check if Nginx is listening on port 80
sudo netstat -tlnp | grep :80

# Or using ss command
sudo ss -tlnp | grep :80

# Check Docker port mapping
docker ps | grep nginx
```

### Test port from outside

```bash
# From your local machine
telnet YOUR_EC2_IP 80

# Or using nc (netcat)
nc -zv YOUR_EC2_IP 80

# Or using PowerShell (Windows)
Test-NetConnection -ComputerName YOUR_EC2_IP -Port 80
```

---

## Common Issues & Solutions

### Issue 1: Connection Refused

**Problem:** Can't connect to EC2 IP

**Solutions:**
1. Check Security Group allows port 80 inbound
2. Verify containers are running: `docker ps`
3. Check Nginx is listening: `sudo netstat -tlnp | grep :80`

### Issue 2: 502 Bad Gateway

**Problem:** Nginx can't reach API container

**Solutions:**
1. Check API container is running: `docker ps`
2. Check API logs: `docker logs ec2-poc-api`
3. Restart containers: `docker-compose restart`

### Issue 3: 404 Not Found

**Problem:** Endpoint doesn't exist

**Solutions:**
1. Verify endpoint path (case-sensitive)
2. Check API routes in `src/server.js`
3. Test directly on API: `curl http://localhost:3000/health` (if exposed)

### Issue 4: Can't Find Public IP

**Problem:** No public IP shown

**Solutions:**
1. Instance might be in private subnet
2. Check Elastic IP is attached
3. Use AWS Console to verify instance details

---

## Available API Endpoints

Based on your `server.js`, these endpoints are available:

**Base URL:** `http://YOUR_EC2_IP`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| GET | `/api/status` | API status info |
| GET | `/api/data` | Get sample data |
| POST | `/api/data` | Create data (requires `name`) |
| GET | `/api/users` | Get all users |
| GET | `/api/users/:id` | Get user by ID |
| POST | `/api/users` | Create user (requires `name`, `email`) |
| PUT | `/api/users/:id` | Update user |
| DELETE | `/api/users/:id` | Delete user |

---

## Quick Reference Commands

```bash
# Get public IP
curl http://169.254.169.254/latest/meta-data/public-ipv4

# Test health endpoint
curl http://localhost/health

# Check containers
docker ps

# View logs
docker logs ec2-poc-api
docker logs ec2-poc-nginx

# Restart services
docker-compose restart

# Check port 80
sudo netstat -tlnp | grep :80
```

---

## Summary

**Your Base URL is:** `http://YOUR_EC2_PUBLIC_IP`

**To find it:**
1. AWS Console → EC2 → Instances → Public IPv4 address
2. Or SSH into EC2: `curl http://169.254.169.254/latest/meta-data/public-ipv4`

**To test it:**
- From EC2: `curl http://localhost/health`
- From local: `curl http://YOUR_EC2_IP/health`
- In browser: `http://YOUR_EC2_IP/health`

