# EC2 Connection Guide - Using PuTTY

## Prerequisites

1. **PuTTY** - Download from [putty.org](https://www.putty.org/)
2. **PuTTYgen** - Usually included with PuTTY installation
3. **EC2 Key Pair** - Your `.pem` file from AWS

## Step 1: Convert .pem to .ppk Format

PuTTY requires `.ppk` format, not `.pem`. Convert your key:

1. Open **PuTTYgen** (search in Start menu)
2. Click **Load**
3. Change file type filter to **"All Files (*.*)"**
4. Select your `.pem` key file
5. Click **Save private key**
6. Save as `.ppk` file (e.g., `demo-keypair.ppk`)
7. Click **Yes** if prompted about saving without passphrase

## Step 2: Get Your EC2 Connection Details

From AWS Console:
1. Go to **EC2 Dashboard** → **Instances**
2. Select your instance
3. Click **Connect**
4. Copy the **Public IPv4 address** or **Public IPv4 DNS**

Example formats:
- IP: `44.223.6.71`
- DNS: `ec2-44-223-6-71.compute-1.amazonaws.com`

## Step 3: Configure PuTTY Connection

1. **Open PuTTY**

2. **Session Settings:**
   - **Host Name (or IP address):** 
     - Format: `ec2-user@YOUR_IP_OR_DNS`
     - Example: `ec2-user@ec2-44-223-6-71.compute-1.amazonaws.com`
     - Or: `ec2-user@44.223.6.71`
   - **Port:** `22` (default SSH port)
   - **Connection type:** `SSH`

3. **Configure Authentication:**
   - In the **left panel**, click on **"Connection"** (you'll see it expand)
   - Under Connection, click on **"SSH"** (it may already be expanded, or click to expand it)
   - Under SSH, click on **"Auth"** (this is where authentication settings are)
   - In the right panel, you'll now see "Authentication options"
   - Look for **"Private key file for authentication"** section
   - Click the **"Browse..."** button
   - Navigate to and select your `.ppk` file
   - Click **Open** to select it

4. **Save Session (Optional):**
   - Go back to **Session** in left panel
   - Enter a name in "Saved Sessions" (e.g., "EC2-Instance")
   - Click **Save**

5. **Connect:**
   - Click **Open** button at bottom
   - First connection: Click **Yes** to accept the host key

## Step 4: Login

After connecting, you'll see a terminal prompt:
```
login as: ec2-user
```

Press Enter (username is already set). You should now be connected!

## Common EC2 User Names by AMI

- **Amazon Linux / Amazon Linux 2:** `ec2-user`
- **Ubuntu:** `ubuntu`
- **Debian:** `admin`
- **RHEL / CentOS:** `ec2-user` or `root`
- **SUSE:** `ec2-user`
- **Fedora:** `ec2-user`

## Troubleshooting

### Connection Timeout
- Check **Security Group** allows inbound SSH (port 22) from your IP
- Verify instance is **running**
- Check **Public IP** is correct

### Authentication Failed
- Ensure `.ppk` file is correct (re-convert if needed)
- Verify username matches your AMI type
- Check key pair matches the instance

### Permission Denied
- Verify key file permissions (should be readable)
- Ensure using correct key pair assigned to instance

## Next Steps After Connection

Once connected, you can deploy your API with Nginx:

### Option 1: Quick Deploy (Using deploy script)

1. **Upload your project files to EC2:**
   - Use SCP, SFTP, or Git to transfer files
   - Or clone from your repository:
   ```bash
   git clone <your-repo-url>
   cd EC2_POC
   ```

2. **Run deployment script:**
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

### Option 2: Manual Deploy

1. **Update system:**
```bash
echo "# ec2-poc" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/Rajesh144142/ec2-poc.git
git push -u origin main```

2. **Install Docker:**
```bash
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
```

3. **Install Docker Compose:**
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

5. **Verify deployment:**
```bash
docker ps
```

6. **Configure Security Group:**
   - Add inbound rule: Port `80` (HTTP), Source: `0.0.0.0/0` (or your IP)
   - Your API will be accessible at: `http://YOUR_EC2_IP`

### Access Your API

After deployment, access your API endpoints:
- `http://YOUR_EC2_IP/health`
- `http://YOUR_EC2_IP/api/status`
- `http://YOUR_EC2_IP/api/data`

