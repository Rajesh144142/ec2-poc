#!/bin/bash

echo "=== EC2 API Base URL Checker ==="
echo ""

# Get public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null)

if [ -z "$PUBLIC_IP" ]; then
    echo "⚠️  Could not retrieve public IP from metadata service"
    echo "   Trying alternative method..."
    PUBLIC_IP=$(hostname -I | awk '{print $1}' 2>/dev/null)
fi

if [ -z "$PUBLIC_IP" ]; then
    echo "❌ Could not determine public IP"
    echo "   Please check AWS Console for your EC2 Public IP"
    exit 1
fi

echo "📍 Public IP: $PUBLIC_IP"
echo "🌐 Base URL: http://$PUBLIC_IP"
echo ""

# Check if containers are running
echo "📦 Container Status:"
if command -v docker &> /dev/null; then
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "   Docker not accessible or no containers running"
else
    echo "   Docker not installed"
fi
echo ""

# Test endpoints
echo "🧪 Testing Endpoints:"
echo ""

# Test health endpoint
echo "1. Health Check (/health):"
HEALTH_RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" http://localhost/health 2>/dev/null)
HTTP_CODE=$(echo "$HEALTH_RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$HEALTH_RESPONSE" | sed '/HTTP_CODE/d')

if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ Status: OK (200)"
    echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
else
    echo "   ❌ Status: Failed ($HTTP_CODE)"
    echo "$BODY"
fi
echo ""

# Test API status
echo "2. API Status (/api/status):"
STATUS_RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" http://localhost/api/status 2>/dev/null)
HTTP_CODE=$(echo "$STATUS_RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$STATUS_RESPONSE" | sed '/HTTP_CODE/d')

if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ Status: OK (200)"
    echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
else
    echo "   ❌ Status: Failed ($HTTP_CODE)"
    echo "$BODY"
fi
echo ""

# Test users endpoint
echo "3. Users API (/api/users):"
USERS_RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" http://localhost/api/users 2>/dev/null)
HTTP_CODE=$(echo "$USERS_RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$USERS_RESPONSE" | sed '/HTTP_CODE/d')

if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ Status: OK (200)"
    echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
else
    echo "   ❌ Status: Failed ($HTTP_CODE)"
    echo "$BODY"
fi
echo ""

# Check port 80
echo "🔌 Port 80 Status:"
if command -v netstat &> /dev/null; then
    PORT_STATUS=$(sudo netstat -tlnp 2>/dev/null | grep :80 || echo "   Not listening")
    echo "$PORT_STATUS"
elif command -v ss &> /dev/null; then
    PORT_STATUS=$(sudo ss -tlnp 2>/dev/null | grep :80 || echo "   Not listening")
    echo "$PORT_STATUS"
else
    echo "   Cannot check port status (netstat/ss not available)"
fi
echo ""

echo "✅ Check complete!"
echo ""
echo "🌐 Your API Base URL: http://$PUBLIC_IP"
echo ""
echo "📋 Available Endpoints:"
echo "   - http://$PUBLIC_IP/health"
echo "   - http://$PUBLIC_IP/api/status"
echo "   - http://$PUBLIC_IP/api/users"
echo "   - http://$PUBLIC_IP/api/data"
echo ""

