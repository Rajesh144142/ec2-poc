# CI/CD Setup Instructions

## Quick Setup Guide

### 1. GitHub Secrets Configuration

Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Add the following secrets:

#### Required Secrets:

- **`EC2_HOST`**: Your EC2 instance public IP address
  - Example: `44.223.6.71`

- **`EC2_USER`**: SSH username for EC2
  - Example: `ec2-user` (for Amazon Linux)
  - Example: `ubuntu` (for Ubuntu)

- **`EC2_SSH_KEY`**: Your private SSH key content
  - Copy the entire content of your `.pem` file
  - Include `-----BEGIN RSA PRIVATE KEY-----` and `-----END RSA PRIVATE KEY-----`
  - On Windows: `type your-key.pem` or open in Notepad
  - On Mac/Linux: `cat ~/.ssh/your-key.pem`

#### Optional Secrets:

- **`REPO_URL`**: Your GitHub repository URL (optional)
  - Example: `https://github.com/username/repo.git`
  - Only needed if using a private repo or custom URL
  - If not set, workflow will use the current repository URL automatically

---

### 2. EC2 Prerequisites

Make sure your EC2 instance has:

- ✅ Docker installed
- ✅ Docker Compose installed
- ✅ Git installed
- ✅ Port 22 (SSH) open in Security Group
- ✅ Port 80 (HTTP) open in Security Group (for API access)

**Quick setup script (run on EC2):**
```bash
# Install Docker
sudo yum update -y
sudo yum install docker git -y
sudo service docker start
sudo usermod -a -G docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Log out and log back in for group changes to take effect
```

---

### 3. Project Directory on EC2

The workflow expects the project to be in `~/ec2-poc` on your EC2 instance.

**First-time setup on EC2:**
```bash
cd ~
git clone <your-repo-url> ec2-poc
cd ec2-poc
```

Or the workflow will create it automatically on first deployment.

---

### 4. Security Group Configuration

Ensure your EC2 Security Group allows:

- **Inbound SSH (Port 22)**: From GitHub Actions IP ranges or your IP
  - GitHub Actions IPs: https://api.github.com/meta (use `actions` key)
  - Or temporarily allow from `0.0.0.0/0` for testing (not recommended for production)

- **Inbound HTTP (Port 80)**: From `0.0.0.0/0` or specific IPs

---

### 5. Test the Workflow

1. **Push to main branch:**
   ```bash
   git add .
   git commit -m "Test CI/CD pipeline"
   git push origin main
   ```

2. **Check GitHub Actions:**
   - Go to your repository → **Actions** tab
   - Watch the workflow run
   - Check logs if it fails

3. **Manual trigger (optional):**
   - Go to **Actions** → **CI/CD Pipeline** → **Run workflow**

---

## Workflow Files

- **`.github/workflows/deploy.yml`**: Full CI/CD pipeline (test + deploy)
  - Runs on push to main/master
  - Tests code, builds Docker image, deploys to EC2

- **`.github/workflows/ci.yml`**: CI only (no deployment)
  - Runs on pull requests
  - Only tests and builds, doesn't deploy

---

## Troubleshooting

### SSH Connection Failed

**Error:** `Permission denied (publickey)` or `Connection refused`

**Solutions:**
1. Verify `EC2_SSH_KEY` secret contains the complete private key
2. Check Security Group allows port 22 from GitHub Actions
3. Verify `EC2_HOST` and `EC2_USER` are correct
4. Test SSH manually: `ssh -i key.pem ec2-user@YOUR_IP`

### Deployment Fails

**Error:** `Health check failed`

**Solutions:**
1. Check container logs: `docker-compose logs` on EC2
2. Verify docker-compose.yml is correct
3. Check if port 80 is open in Security Group
4. SSH to EC2 and run: `curl http://localhost/health`

### Git Pull Fails

**Error:** `fatal: not a git repository`

**Solutions:**
1. Ensure `REPO_URL` secret is set
2. Or manually clone the repo on EC2 first
3. Check directory permissions: `chmod 755 ~/ec2-poc`

---

## Advanced Configuration

### Custom Project Directory

If you want to use a different directory on EC2, edit `.github/workflows/deploy.yml`:

```yaml
cd ~/your-custom-directory
```

### Environment-Specific Deployments

Create separate workflows for staging/production:

- `.github/workflows/deploy-staging.yml`
- `.github/workflows/deploy-production.yml`

Use different secrets:
- `EC2_HOST_STAGING`
- `EC2_HOST_PRODUCTION`

### Add Notifications

Add Slack/Email notifications in the workflow:

```yaml
- name: Notify Slack
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

---

## Next Steps

1. ✅ Set up GitHub Secrets
2. ✅ Configure EC2 Security Group
3. ✅ Push code to trigger workflow
4. ✅ Monitor first deployment
5. ✅ Add tests and linting (optional)
6. ✅ Set up notifications (optional)

---

## Security Best Practices

1. **Never commit secrets** to the repository
2. **Use GitHub Secrets** for all sensitive data
3. **Rotate SSH keys** regularly
4. **Limit Security Group access** to specific IPs when possible
5. **Use IAM roles** instead of access keys when possible
6. **Enable 2FA** on GitHub account

---

## Support

If you encounter issues:
1. Check GitHub Actions logs
2. SSH to EC2 and check logs: `docker-compose logs`
3. Verify all secrets are set correctly
4. Test commands manually on EC2

