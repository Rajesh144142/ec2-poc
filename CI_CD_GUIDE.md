# CI/CD Guide - Automated Deployment

## What is CI/CD?

### CI (Continuous Integration)
- **Automatically build and test** code on every commit
- Catch bugs early
- Ensure code quality
- Run automated tests

### CD (Continuous Deployment/Delivery)
- **Automatically deploy** code to servers
- Reduce manual errors
- Faster releases
- Consistent deployments

### Benefits:
1. **Automation:** No manual deployment steps
2. **Speed:** Deploy in minutes, not hours
3. **Reliability:** Consistent deployment process
4. **Rollback:** Easy to revert to previous version
5. **Testing:** Automated tests before deployment

---

## Architecture Overview

```
Developer
   │
   ├─ Git Push (GitHub)
   │
   ├─ CI/CD Pipeline Triggers
   │
   ├─ Build Stage
   │   ├─ Install dependencies
   │   ├─ Run tests
   │   └─ Build Docker image
   │
   ├─ Deploy Stage
   │   ├─ SSH to EC2
   │   ├─ Pull latest code
   │   ├─ Build Docker image
   │   └─ Restart containers
   │
   └─ EC2 Instance (Production)
```

---

## Option 1: GitHub Actions (Recommended - Free)

### Why GitHub Actions?
- **Free** for public repositories
- **Free** 2000 minutes/month for private repos
- Easy to set up
- Integrated with GitHub
- No AWS costs

### Prerequisites:
- GitHub repository
- EC2 instance running
- SSH access to EC2

---

## GitHub Actions Setup

### Step 1: Create GitHub Secrets

**In GitHub Repository:**
1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**

**Add these secrets:**

```
EC2_HOST: 44.223.6.71 (your EC2 public IP)
EC2_USER: ec2-user
EC2_SSH_KEY: (your private key content - .pem file)
```

**How to get SSH key content:**
```bash
# On your local machine
cat ~/.ssh/your-key.pem
# Copy entire content including -----BEGIN and -----END
```

### Step 2: Create GitHub Actions Workflow

**Create file:** `.github/workflows/deploy.yml`

```yaml
name: Deploy to EC2

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Setup SSH
      run: |
        mkdir -p ~/.ssh
        echo "${{ secrets.EC2_SSH_KEY }}" > ~/.ssh/deploy_key
        chmod 600 ~/.ssh/deploy_key
        ssh-keyscan -H ${{ secrets.EC2_HOST }} >> ~/.ssh/known_hosts
    
    - name: Deploy to EC2
      run: |
        ssh -i ~/.ssh/deploy_key -o StrictHostKeyChecking=no ${{ secrets.EC2_USER }}@${{ secrets.EC2_HOST }} << 'EOF'
          cd ~/ec2-poc
          git pull origin main
          docker build -t ec2-poc-api .
          docker-compose down
          docker-compose up -d --build
          docker system prune -f
        EOF
```

### Step 3: Alternative - Using SSH Action

**More secure approach:**

```yaml
name: Deploy to EC2

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Deploy to EC2
      uses: appleboy/ssh-action@v0.1.5
      with:
        host: ${{ secrets.EC2_HOST }}
        username: ${{ secrets.EC2_USER }}
        key: ${{ secrets.EC2_SSH_KEY }}
        script: |
          cd ~/ec2-poc
          git pull origin main
          docker build -t ec2-poc-api .
          docker-compose down
          docker-compose up -d --build
          docker system prune -f
```

### Step 4: Enhanced Workflow with Testing

```yaml
name: CI/CD Pipeline

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run tests
      run: npm test
      continue-on-error: true
    
    - name: Build Docker image
      run: docker build -t ec2-poc-api .

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Deploy to EC2
      uses: appleboy/ssh-action@v0.1.5
      with:
        host: ${{ secrets.EC2_HOST }}
        username: ${{ secrets.EC2_USER }}
        key: ${{ secrets.EC2_SSH_KEY }}
        script: |
          cd ~/ec2-poc
          git pull origin main
          docker build -t ec2-poc-api .
          docker-compose down
          docker-compose up -d --build
          docker system prune -f
          docker-compose logs --tail=50
```

---

## Option 2: AWS CodePipeline (AWS Native)

### Why AWS CodePipeline?
- AWS-native integration
- Free tier: 1 pipeline/month
- Integrated with other AWS services
- Visual pipeline editor

### Prerequisites:
- AWS account
- IAM roles configured
- CodeCommit, GitHub, or S3 as source

---

## AWS CodePipeline Setup

### Step 1: Create IAM Roles

**For CodePipeline:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:*",
        "s3:*",
        "iam:PassRole"
      ],
      "Resource": "*"
    }
  ]
}
```

**For CodeBuild:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
```

### Step 2: Create CodeBuild Project

**buildspec.yml:**
```yaml
version: 0.2

phases:
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - npm ci
  build:
    commands:
      - echo Build started on `date`
      - docker build -t ec2-poc-api .
  post_build:
    commands:
      - echo Build completed on `date`

artifacts:
  files:
    - '**/*'
```

### Step 3: Create CodePipeline

**Pipeline Structure:**
1. **Source:** GitHub (connect repository)
2. **Build:** CodeBuild (build Docker image)
3. **Deploy:** Custom action (SSH to EC2)

**Deploy Script (in CodeBuild):**
```bash
#!/bin/bash
ssh -i deploy-key.pem ec2-user@$EC2_HOST << 'EOF'
  cd ~/ec2-poc
  git pull origin main
  docker build -t ec2-poc-api .
  docker-compose down
  docker-compose up -d --build
EOF
```

---

## Deployment Strategies

### 1. Rolling Deployment (Current)
- Stop old containers
- Start new containers
- **Downtime:** Few seconds
- **Rollback:** Manual

### 2. Blue-Green Deployment
- Run two environments (blue/green)
- Deploy to inactive environment
- Switch traffic
- **Downtime:** None
- **Rollback:** Instant switch

**Implementation:**
```yaml
# docker-compose.blue.yml
services:
  api-blue:
    # ... configuration

# docker-compose.green.yml
services:
  api-green:
    # ... configuration
```

### 3. Canary Deployment
- Deploy to small percentage
- Monitor for issues
- Gradually increase
- **Risk:** Low
- **Rollback:** Easy

---

## Best Practices

### 1. Environment Variables
- Store secrets in GitHub Secrets
- Use different environments (dev/staging/prod)
- Never commit secrets to code

### 2. Testing
- Run tests before deployment
- Fail pipeline on test failure
- Include linting and security scans

### 3. Notifications
- Send notifications on success/failure
- Use Slack, email, or AWS SNS
- Include deployment logs

### 4. Rollback Strategy
- Keep previous Docker images
- Tag releases (v1.0.0, v1.0.1)
- Quick rollback script

### 5. Security
- Use SSH keys, not passwords
- Rotate keys regularly
- Limit access to secrets
- Use least privilege IAM roles

---

## Enhanced GitHub Actions Workflow

### Complete Workflow with All Features:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches:
      - main
  workflow_dispatch:

env:
  NODE_VERSION: '18'
  DOCKER_IMAGE: ec2-poc-api

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: ${{ env.NODE_VERSION }}
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run linter
      run: npm run lint
      continue-on-error: true
    
    - name: Run tests
      run: npm test
      continue-on-error: true
    
    - name: Build Docker image
      run: docker build -t ${{ env.DOCKER_IMAGE }} .

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Deploy to EC2
      uses: appleboy/ssh-action@v0.1.5
      with:
        host: ${{ secrets.EC2_HOST }}
        username: ${{ secrets.EC2_USER }}
        key: ${{ secrets.EC2_SSH_KEY }}
        port: 22
        script: |
          set -e
          cd ~/ec2-poc
          
          echo "Pulling latest code..."
          git pull origin main
          
          echo "Building Docker image..."
          docker build -t ${{ env.DOCKER_IMAGE }} .
          
          echo "Stopping old containers..."
          docker-compose down
          
          echo "Starting new containers..."
          docker-compose up -d --build
          
          echo "Cleaning up..."
          docker system prune -f
          
          echo "Checking container status..."
          docker ps
          
          echo "Testing health endpoint..."
          sleep 5
          curl -f http://localhost/health || exit 1
          
          echo "Deployment successful!"
    
    - name: Notify on success
      if: success()
      run: |
        echo "✅ Deployment successful!"
        # Add Slack/email notification here
    
    - name: Notify on failure
      if: failure()
      run: |
        echo "❌ Deployment failed!"
        # Add Slack/email notification here
```

---

## Troubleshooting

### Common Issues:

### 1. SSH Connection Failed
**Problem:** Cannot connect to EC2
**Solution:**
- Check Security Group allows port 22
- Verify SSH key is correct
- Check EC2 instance is running

### 2. Permission Denied
**Problem:** Cannot execute commands on EC2
**Solution:**
- Verify user has sudo access
- Check file permissions
- Ensure Docker group membership

### 3. Docker Build Fails
**Problem:** Build errors in pipeline
**Solution:**
- Test build locally first
- Check Dockerfile syntax
- Verify all files are committed

### 4. Container Not Starting
**Problem:** Containers fail after deployment
**Solution:**
- Check docker-compose.yml syntax
- Verify environment variables
- Check container logs: `docker logs ec2-poc-api`

---

## Monitoring Deployments

### View GitHub Actions Logs:
1. Go to **Actions** tab in GitHub
2. Click on workflow run
3. View logs for each step

### Monitor EC2:
```bash
# SSH to EC2
ssh ec2-user@YOUR_EC2_IP

# Check containers
docker ps

# View logs
docker-compose logs -f

# Check deployment
curl http://localhost/health
```

---

## Cost Comparison

| Service | Cost | Free Tier |
|---------|------|-----------|
| GitHub Actions | $0 | ✅ 2000 min/month (private) |
| AWS CodePipeline | ~$1/pipeline | ✅ 1 pipeline/month |
| AWS CodeBuild | ~$0.005/min | ✅ 100 min/month |

**Recommendation:** Start with GitHub Actions (free, easier)

---

## Next Steps

1. **Set up GitHub Secrets** (EC2_HOST, EC2_USER, EC2_SSH_KEY)
2. **Create `.github/workflows/deploy.yml`**
3. **Test workflow** with a small change
4. **Monitor first deployment**
5. **Add notifications** (optional)
6. **Implement testing** (optional)

---

## Quick Start Checklist

- [ ] GitHub repository created
- [ ] EC2 instance running
- [ ] SSH access to EC2 working
- [ ] GitHub Secrets configured
- [ ] Workflow file created (`.github/workflows/deploy.yml`)
- [ ] Test deployment with git push

Ready to set up CI/CD?

