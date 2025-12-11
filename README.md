# EC2 POC API

Simple Node.js API with Nginx reverse proxy, ready for Docker deployment on EC2.

## Local Development

1. Install dependencies:
```bash
npm install
```

2. Run the server:
```bash
npm start
```

## Docker Deployment

### Build and Run Locally

```bash
docker build -t ec2-poc-api .
docker run -p 3000:3000 ec2-poc-api
```

Or using docker-compose (includes Nginx):
```bash
docker-compose up -d
```

This will start both the API and Nginx. Access the API through port 80.

### EC2 Deployment Steps

1. **Connect to your EC2 instance:**
```bash
ssh -i your-key.pem ec2-user@your-ec2-ip
```

2. **Install Docker on EC2:**
```bash
sudo yum update -y
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
```

3. **Install Docker Compose (if not installed):**
```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
```

4. **Clone and deploy:**
```bash
git clone <your-repo-url>
cd EC2_POC
docker-compose up -d
```

5. **Verify containers are running:**
```bash
docker ps
```

6. **Configure Security Group:**
   - Open port 80 (HTTP) in EC2 Security Group
   - Allow inbound traffic from your IP or 0.0.0.0/0
   - Access your API at: `http://YOUR_EC2_IP`

## API Endpoints

All endpoints are accessible through Nginx on port 80:

- `GET http://YOUR_EC2_IP/health` - Health check endpoint
- `GET http://YOUR_EC2_IP/api/status` - API status information
- `GET http://YOUR_EC2_IP/api/data` - Get sample data
- `POST http://YOUR_EC2_IP/api/data` - Create new data (requires `name` in body)

## Architecture

- **Nginx** (port 80) - Reverse proxy and load balancer
- **Node.js API** (port 3000) - Application server (internal, not exposed)

## Environment Variables

- `PORT` - Server port (default: 3000)
- `NODE_ENV` - Environment (default: development)

## Useful Commands

**View logs:**
```bash
docker-compose logs -f
```

**Stop services:**
```bash
docker-compose down
```

**Restart services:**
```bash
docker-compose restart
```

**Rebuild and restart:**
```bash
docker-compose up -d --build
```

## CI/CD (Automated Deployment)

This project includes GitHub Actions workflows for automated testing and deployment.

### Quick Setup

1. **Configure GitHub Secrets:**
   - Go to repository → Settings → Secrets and variables → Actions
   - Add: `EC2_HOST`, `EC2_USER`, `EC2_SSH_KEY`
   - See [`.github/SETUP.md`](.github/SETUP.md) for detailed instructions

2. **Push to main branch:**
   - The workflow automatically runs on every push to `main` or `master`
   - It will test, build, and deploy to your EC2 instance

### Workflows

- **`.github/workflows/deploy.yml`**: Full CI/CD pipeline
  - Tests code on every push/PR
  - Deploys to EC2 on push to main/master
  - Includes health checks and rollback on failure

- **`.github/workflows/ci.yml`**: CI only (for pull requests)
  - Tests and builds without deploying

### Manual Deployment

You can also deploy manually using the script:
```bash
./deploy.sh
```

For detailed CI/CD documentation, see:
- [`.github/SETUP.md`](.github/SETUP.md) - Setup instructions
- [`CI_CD_GUIDE.md`](CI_CD_GUIDE.md) - Comprehensive guide

