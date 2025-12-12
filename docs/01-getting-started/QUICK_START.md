# Quick Start - CI/CD Setup with Your EC2 Instance

## Your EC2 Details
- **IP Address**: `YOUR_EC2_IP` (e.g., `44.223.6.71`)
- **SSH Key**: You need to create `ec2-key.pem` file (see below)

> **Note:** Replace `YOUR_EC2_IP` with your actual EC2 public IP address throughout this guide.

## Step 0: Get Your SSH Key File

**You already have the SSH key** - it was provided to you separately. 

**To use it:**
1. Save your private key to a file named `ec2-key.pem` (or any name you prefer)
2. Place it in a secure location (NOT in this repository)
3. Set correct permissions:

```powershell
# Set correct permissions (run in PowerShell)
icacls "ec2-key.pem" /inheritance:r
icacls "ec2-key.pem" /grant "${env:USERNAME}:R"
```

**Important:** Never commit SSH private keys to Git! (Already protected by `.gitignore`)

## Step 1: Find Your EC2 Username

### Option A: Use the Test Script (Easiest)
```powershell
# Set correct permissions on the key file
icacls "ec2-key.pem" /inheritance:r
icacls "ec2-key.pem" /grant:r "$env:USERNAME:R"

# Run the test script
.\test-ssh.ps1
```

This will automatically try common usernames and tell you which one works.

### Option B: Try Manually
```powershell
# Try ec2-user (most common)
ssh -i ec2-key.pem ec2-user@YOUR_EC2_IP

# If that fails, try ubuntu
ssh -i ec2-key.pem ubuntu@YOUR_EC2_IP
```

### Option C: Check AWS Console
1. Go to **EC2** → **Instances** → Select your instance
2. Click **Connect** → **EC2 Instance Connect**
3. Once connected, run: `whoami`

## Step 2: Set Up GitHub Secrets

Once you know your username, go to your GitHub repository:

1. **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**

Add these three secrets:

### Secret 1: EC2_HOST
- **Name**: `EC2_HOST`
- **Value**: `YOUR_EC2_IP` (e.g., `44.223.6.71`)

### Secret 2: EC2_USER
- **Name**: `EC2_USER`
- **Value**: `ec2-user` (or whatever username worked in Step 1)

### Secret 3: EC2_SSH_KEY
- **Name**: `EC2_SSH_KEY`
- **Value**: Copy the ENTIRE content of your private SSH key file
  - Include the `-----BEGIN RSA PRIVATE KEY-----` line
  - Include ALL the content between BEGIN and END lines  
  - Include the `-----END RSA PRIVATE KEY-----` line
  - The key should be the one you received separately (kept secure, NOT in this repo)

## Step 3: Verify EC2 Security Group

Make sure your EC2 Security Group allows:

1. **Port 22 (SSH)** - From GitHub Actions IPs or your IP
   - Go to **EC2** → **Security Groups** → Select your instance's security group
   - **Inbound rules** → Add rule:
     - Type: SSH
     - Port: 22
     - Source: `0.0.0.0/0` (for testing) or specific IPs

2. **Port 80 (HTTP)** - From anywhere (for API access)
   - Add rule:
     - Type: HTTP
     - Port: 80
     - Source: `0.0.0.0/0`

## Step 4: Test the Connection

Before setting up CI/CD, test that you can connect:

```powershell
# Replace 'ec2-user' with your actual username and YOUR_EC2_IP with your IP
ssh -i ec2-key.pem ec2-user@YOUR_EC2_IP

# Once connected, test Docker
docker --version
docker-compose --version
```

If Docker is not installed, run on EC2:
```bash
sudo yum update -y
sudo yum install docker git -y
sudo service docker start
sudo usermod -a -G docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

## Step 5: Push to GitHub and Deploy

Once secrets are configured:

```bash
git add .
git commit -m "Add CI/CD pipeline"
git push origin main
```

The workflow will automatically:
1. ✅ Test your code
2. ✅ Build Docker image
3. ✅ Deploy to EC2 (YOUR_EC2_IP)
4. ✅ Run health checks

## Step 6: Monitor Deployment

1. Go to your GitHub repository
2. Click **Actions** tab
3. Watch the workflow run
4. Check logs if anything fails

## Troubleshooting

### "Permission denied" when testing SSH
- Wrong username - try `ec2-user`, `ubuntu`, or `admin`
- Key permissions wrong - run: `icacls "ec2-key.pem" /inheritance:r` then `icacls "ec2-key.pem" /grant "${env:USERNAME}:R"`

### "Connection refused" or "Connection timed out"
- Security Group doesn't allow port 22
- Instance might be stopped - check AWS Console

### GitHub Actions deployment fails
- Check that all 3 secrets are set correctly
- Verify Security Group allows port 22 from GitHub Actions
- Check GitHub Actions logs for specific error

## Next Steps

After successful deployment:
- Your API will be available at: `http://YOUR_EC2_IP`
- Test health endpoint: `http://YOUR_EC2_IP/health`
- Every push to `main` branch will auto-deploy!

## Need Help?

- See [`.github/SETUP.md`](.github/SETUP.md) for detailed setup
- See [`FIND_EC2_USERNAME.md`](FIND_EC2_USERNAME.md) for finding username
- See [`CI_CD_GUIDE.md`](CI_CD_GUIDE.md) for comprehensive guide

