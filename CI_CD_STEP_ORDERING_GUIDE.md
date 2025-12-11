# CI/CD Step Ordering Guide

## Understanding Step Dependencies

In CI/CD pipelines, steps must follow a **logical dependency order**. Each step depends on the output or completion of previous steps.

---

## Core Principles

### 1. **Prerequisites First**
Always set up prerequisites before using them:
- ✅ Checkout code → Install dependencies → Run tests
- ❌ Run tests → Install dependencies (tests will fail - no dependencies!)

### 2. **Build Before Deploy**
Always build/test before deploying:
- ✅ Test → Build → Deploy
- ❌ Deploy → Test (deploying untested code!)

### 3. **Setup Before Execution**
Configure tools before using them:
- ✅ Setup Node.js → Install dependencies
- ❌ Install dependencies → Setup Node.js (npm won't exist!)

---

## Step Ordering Rules

### Rule 1: **Checkout Code First**
```yaml
- name: Checkout code
  uses: actions/checkout@v4
```
**Why:** You need code before doing anything with it.

**Must come before:**
- Installing dependencies
- Running tests
- Building images
- Any file operations

---

### Rule 2: **Setup Tools Before Using Them**
```yaml
- name: Setup Node.js
  uses: actions/setup-node@v4
  with:
    node-version: '18'

- name: Install dependencies
  run: npm ci
```
**Why:** `npm` command requires Node.js to be installed first.

**Order:**
1. Setup Node.js ✅
2. Install dependencies ✅
3. Run tests ✅

---

### Rule 3: **Install Dependencies Before Running Code**
```yaml
- name: Install dependencies
  run: npm ci

- name: Run tests
  run: npm test
```
**Why:** Tests need `node_modules` to exist.

**Order:**
1. Checkout code ✅
2. Setup Node.js ✅
3. Install dependencies ✅
4. Run tests ✅

---

### Rule 4: **Test Before Build**
```yaml
- name: Run tests
  run: npm test

- name: Build Docker image
  run: docker build -t ${{ env.DOCKER_IMAGE }} .
```
**Why:** Don't build broken code.

**Order:**
1. Install dependencies ✅
2. Run tests ✅
3. Build Docker image ✅

---

### Rule 5: **Build Before Deploy**
```yaml
jobs:
  test:
    steps:
      - name: Build Docker image
        run: docker build -t ${{ env.DOCKER_IMAGE }} .

  deploy:
    needs: test  # ← This ensures test completes first
    steps:
      - name: Deploy to EC2
        ...
```
**Why:** Deploy job should only run if test job succeeds.

**Order:**
1. Test job completes ✅
2. Deploy job starts ✅

---

### Rule 6: **Stop Old Before Starting New**
```yaml
- name: Stop old containers
  run: docker-compose down

- name: Start new containers
  run: docker-compose up -d
```
**Why:** Avoid port conflicts and ensure clean state.

**Order:**
1. Pull latest code ✅
2. Build new image ✅
3. Stop old containers ✅
4. Start new containers ✅

---

## Real Example from Your Workflow

Let's analyze your current workflow:

### Test Job Order (Lines 24-53)
```24:53:.github/workflows/deploy.yml
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: ${{ env.NODE_VERSION }}
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run linter (if available)
      run: npm run lint || echo "No lint script found, skipping..."
      continue-on-error: true
    
    - name: Run tests (if available)
      run: npm test || echo "No tests found, skipping..."
      continue-on-error: true
    
    - name: Build Docker image
      run: docker build -t ${{ env.DOCKER_IMAGE }}:${{ github.sha }} -t ${{ env.DOCKER_IMAGE }}:latest .
    
    - name: Test Docker image
      run: |
        docker run -d --name test-container -p 3000:3000 ${{ env.DOCKER_IMAGE }}:latest
        sleep 5
        curl -f http://localhost:3000/health || exit 1
        docker stop test-container
        docker rm test-container
```

**Why this order is correct:**
1. ✅ **Checkout** (line 24) - Get code first
2. ✅ **Setup Node.js** (line 27) - Install Node.js runtime
3. ✅ **Install dependencies** (line 33) - Now npm can install packages
4. ✅ **Run linter** (line 36) - Code quality check (needs dependencies)
5. ✅ **Run tests** (line 40) - Test code (needs dependencies)
6. ✅ **Build Docker image** (line 44) - Create container (needs code)
7. ✅ **Test Docker image** (line 47) - Verify container works (needs image)

---

### Deploy Job Order (Lines 75-150)

```75:150:.github/workflows/deploy.yml
        script: |
          set -e
          echo "🚀 Starting deployment..."
          
          # Navigate to project directory (create if doesn't exist)
          if [ ! -d "~/ec2-poc" ]; then
            echo "📁 Creating project directory..."
            mkdir -p ~/ec2-poc
            cd ~/ec2-poc
            # Use REPO_URL secret if available, otherwise construct from GitHub context
            REPO_URL="${{ secrets.REPO_URL }}"
            if [ -z "$REPO_URL" ]; then
              REPO_URL="https://github.com/${{ github.repository }}.git"
            fi
            git clone "$REPO_URL" . || true
          else
            cd ~/ec2-poc
          fi
          
          echo "📥 Pulling latest code..."
          git fetch origin
          git reset --hard origin/main || git reset --hard origin/master
          git clean -fd
          
          echo "🔨 Building Docker image..."
          docker build -t ${{ env.DOCKER_IMAGE }}:${{ github.sha }} -t ${{ env.DOCKER_IMAGE }}:latest .
          
          echo "🛑 Stopping old containers..."
          docker-compose down || true
          
          echo "📦 Installing Docker Buildx..."
          # Download and install buildx
          BUILDX_VERSION="v0.17.1"
          mkdir -p ~/.docker/cli-plugins/
          curl -sSL "https://github.com/docker/buildx/releases/download/${BUILDX_VERSION}/buildx-${BUILDX_VERSION}.linux-amd64" -o ~/.docker/cli-plugins/docker-buildx
          chmod +x ~/.docker/cli-plugins/docker-buildx
          docker buildx version || echo "Buildx installed"
          
          echo "🚀 Starting new containers..."
          docker-compose up -d --build
          
          echo "🧹 Cleaning up unused Docker resources..."
          docker system prune -f
          
          echo "⏳ Waiting for services to be ready..."
          sleep 10
          
          echo "✅ Checking container status..."
          docker ps
          
          echo "🏥 Testing health endpoint..."
          max_attempts=5
          attempt=1
          while [ $attempt -le $max_attempts ]; do
            if curl -f http://localhost/health > /dev/null 2>&1; then
              echo "✅ Health check passed!"
              break
            else
              echo "⏳ Health check attempt $attempt/$max_attempts failed, retrying..."
              sleep 5
              attempt=$((attempt + 1))
            fi
          done
          
          if [ $attempt -gt $max_attempts ]; then
            echo "❌ Health check failed after $max_attempts attempts"
            echo "📋 Container logs:"
            docker-compose logs --tail=50
            exit 1
          fi
          
          echo "🎉 Deployment successful!"
          echo "📊 Final container status:"
          docker ps
          echo "📋 Recent logs:"
          docker-compose logs --tail=20
```

**Why this order is correct:**
1. ✅ **Navigate/Create directory** (line 80) - Setup workspace
2. ✅ **Pull latest code** (line 94) - Get updated code
3. ✅ **Build Docker image** (line 100) - Create new image
4. ✅ **Stop old containers** (line 103) - Free up ports
5. ✅ **Install Buildx** (line 105) - Setup build tool (optional, but before use)
6. ✅ **Start new containers** (line 114) - Deploy new version
7. ✅ **Cleanup** (line 117) - Remove unused resources
8. ✅ **Wait for services** (line 120) - Let containers start
9. ✅ **Health check** (line 125) - Verify deployment worked

---

## Common Mistakes

### ❌ Wrong Order Examples

**Mistake 1: Install before setup**
```yaml
- name: Install dependencies
  run: npm ci

- name: Setup Node.js
  uses: actions/setup-node@v4
```
**Problem:** `npm` doesn't exist yet!

---

**Mistake 2: Deploy before test**
```yaml
jobs:
  deploy:
    steps:
      - name: Deploy to EC2
        ...

  test:
    needs: deploy
    steps:
      - name: Run tests
        ...
```
**Problem:** Deploying untested code!

---

**Mistake 3: Build before dependencies**
```yaml
- name: Build Docker image
  run: docker build -t app .

- name: Install dependencies
  run: npm ci
```
**Problem:** Docker build needs `package.json` and dependencies!

---

## Decision Tree: "What Should Come Next?"

Ask these questions:

1. **Do I have the code?**
   - No → Checkout code first
   - Yes → Continue

2. **Do I have the runtime/tools?**
   - No → Setup Node.js/Docker/etc. first
   - Yes → Continue

3. **Do I have dependencies?**
   - No → Install dependencies first
   - Yes → Continue

4. **Is the code tested?**
   - No → Run tests first
   - Yes → Continue

5. **Is it built?**
   - No → Build first
   - Yes → Continue

6. **Is old version stopped?**
   - No → Stop old containers first
   - Yes → Continue

7. **Ready to deploy?**
   - Yes → Deploy and verify

---

## Quick Reference: Standard CI/CD Flow

```
1. Checkout code
   ↓
2. Setup runtime/tools (Node.js, Docker, etc.)
   ↓
3. Install dependencies
   ↓
4. Run linter (optional)
   ↓
5. Run tests
   ↓
6. Build artifacts (Docker image, compiled code, etc.)
   ↓
7. Test artifacts (optional)
   ↓
8. Deploy:
   a. Pull latest code (if deploying to server)
   b. Build on server (if needed)
   c. Stop old version
   d. Start new version
   e. Health check
   f. Cleanup
```

---

## Job Dependencies

Jobs also have order dependencies:

```yaml
jobs:
  test:
    steps:
      - name: Run tests
        ...

  deploy:
    needs: test  # ← Deploy waits for test to complete
    steps:
      - name: Deploy
        ...
```

**Rules:**
- `needs: [job1, job2]` - Wait for multiple jobs
- Jobs without `needs` run in parallel
- Jobs with `needs` wait for dependencies

---

## Summary

**Remember:**
1. ✅ **Prerequisites first** - Setup before use
2. ✅ **Test before deploy** - Quality gates
3. ✅ **Stop before start** - Avoid conflicts
4. ✅ **Verify after deploy** - Health checks
5. ✅ **Read error messages** - They tell you what's missing!

**When in doubt:**
- Think: "What does this step need to work?"
- Put those prerequisites before it
- Test the pipeline and read errors
- Adjust order based on failures

