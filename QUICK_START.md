# Quick Start - CI/CD Setup with Your EC2 Instance

## Your EC2 Details
- **IP Address**: `44.223.6.71`
- **SSH Key**: You need to create `ec2-key.pem` file (see below)

## Step 0: Create SSH Key File

**On Windows PowerShell**, create the key file:

```powershell
@"
-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAov6RXNE6q60+5+FwPvTuckq6WfFThlaw2q2kIlY540xLPoSI
OcBeiAJvOVcz+BvVDMhUpDNvEUgwPPzc1qeuGMAV/0KJdoTVVkjcQMzeBgI7mAHo
y8pjAjfW3X2vbEfgLrsaJgdoS1TgFY04GSquIdUUdSmJrquNy/wtdihRa1yLiJJs
no/hjIwf0eWnG5urgoHWr/2DJobTaYSub2ISEhpPqZrY8I66iOklCOHE9tNhWCTT
v/S+RR57gWG0Oa0N6IOFP9rH8cU1uviZNLXKxDKnsypIYaIjPheLNwwH/9i+HINL
S/SghXa78bUdUosizuecKVpmK3bnBUqCaWlQ3wIDAQABAoIBAAfrNkS8JY2RrSy2
1y032R3UY5lbECPGsnDtXrwMVGOmoUE4TyX/IpiZBa5TfkLfl0o3sWUI2qyMRUux
PUlwfBTXwDnWkbcgXP0ELS84xNCl6x9HeHfuLUE+VUINiShJlaqvjGWslnSSexCQ
+9i9KhiasZO/oODLlOgEKHFFJC+DC6Ufrhr+DgiXog0k0gs967LcJ73zYuhIjunG
5r1aowa3Hq6p/FmUSHkN/Y0DF5jZsqNPS5dnbUsoyu9/6AyGr39Ic4NAvVHppntz
0ALKvcVkwYeUQqf+nc0IGNCTTwGX6D3T8BCiZy1e4ebPByRZ1mOHJyQkhl7e3mT8
YZclCYECgYEA1npjXOV3WKLpTGpU33fzc94pxh8gFtc8bzhiqOYbmANbelD/LZrS
sCg0AJR6XR13yfwPWq5oRh4FbLB8pYojo8kHVvx3I5vGnArEv90Uo7D8GSIlrGsK
q6H6g8Ap2xGd9/ffORG5C+NFfot86dN6Fcx4yWGuJyj/iYaOdphX6iMCgYEAwoyh
S1PGw43YAAutJYs3vV4+xSPo7pZor+dWuUtqd2BC5uQh2+7E4W0NYAhKu8saWJCs
EubakGMSIrtwq+rQfPCI0fxLJ1a4dUIHMEnmkx/fzy7InEOs3t/R8i8nrS3+zq/h
/UbmDEo6TapTYYlHgQAOxQHpJktfJJUGIWcMNBUCgYA3sYw/wS5ei989ApeLd+B2
BAig89AnXjjJQMENzsL3lFeayZGZzAxNxgLK68NijpZekt+B0qwtGPqboLCdY+Oh
UkBfrCtbycWnG3y/va7wWrL768wQm7MnomYk9C9qPYbhrzH95cZBegC/vYTwSwP2
ySPMV1sbvB+vHIu97A1YNQKBgCDVAtNni/+sjGtVjR7s47c9lHJIoSLCl2A4NlaG
96y1vhShI2WuYeN5N+yg+Zu/pu6TW7bE5tW/ImxiHZ2lvxGWtkBZx4UYCYEgZ34q
upLRqj+YsZpNgXsLYq7wbk23mWzgGc9Yi7I/RJ+ewvuO41ZN4DA3JlWkGqZdz+8L
KPARAoGAVOSm5BZ9c29w95rPjrtpKVuaA5kYEVZNnlWDNwqKppqseTuOqi5Syfb5
4YkDty1lfSSwnx9+idSNqLtFiNflH1WlceZNWlAlFetzDgC4ReziR5OBJrpXS4NM
n8mb0nHCUYJmcyBtVivXgJLts1OKdvl7RM+UlyqjoqP3V8tts1w=
-----END RSA PRIVATE KEY-----
"@ | Out-File -FilePath "ec2-key.pem" -Encoding ASCII

# Set correct permissions
icacls "ec2-key.pem" /inheritance:r
icacls "ec2-key.pem" /grant "${env:USERNAME}:R"
```

**Important:** This key file should NOT be committed to Git (it's already in `.gitignore`).

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
ssh -i ec2-key.pem ec2-user@44.223.6.71

# If that fails, try ubuntu
ssh -i ec2-key.pem ubuntu@44.223.6.71
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
- **Value**: `44.223.6.71`

### Secret 2: EC2_USER
- **Name**: `EC2_USER`
- **Value**: `ec2-user` (or whatever username worked in Step 1)

### Secret 3: EC2_SSH_KEY
- **Name**: `EC2_SSH_KEY`
- **Value**: Copy the entire content of `ec2-key.pem` file:
  ```
  -----BEGIN RSA PRIVATE KEY-----
  MIIEogIBAAKCAQEAov6RXNE6q60+5+FwPvTuckq6WfFThlaw2q2kIlY540xLPoSI
  ... (entire key content) ...
  -----END RSA PRIVATE KEY-----
  ```

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
# Replace 'ec2-user' with your actual username
ssh -i ec2-key.pem ec2-user@44.223.6.71

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
3. ✅ Deploy to EC2 (44.223.6.71)
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
- Your API will be available at: `http://44.223.6.71`
- Test health endpoint: `http://44.223.6.71/health`
- Every push to `main` branch will auto-deploy!

## Need Help?

- See [`.github/SETUP.md`](.github/SETUP.md) for detailed setup
- See [`FIND_EC2_USERNAME.md`](FIND_EC2_USERNAME.md) for finding username
- See [`CI_CD_GUIDE.md`](CI_CD_GUIDE.md) for comprehensive guide

