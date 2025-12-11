# How to Find Your EC2 Username

## Quick Answer

The EC2 username depends on your **AMI (Amazon Machine Image)** type. Here's how to find it:

## Method 1: Check AWS Console (Easiest)

1. Go to **AWS Console** → **EC2** → **Instances**
2. Select your instance (IP: 44.223.6.71)
3. Look at the **Details** tab → **AMI ID** or **Platform details**
4. Match it to the table below:

| AMI Type | Username |
|----------|----------|
| Amazon Linux 2 / Amazon Linux 2023 | `ec2-user` |
| Ubuntu | `ubuntu` |
| Debian | `admin` |
| RHEL (Red Hat) | `ec2-user` |
| CentOS | `centos` or `ec2-user` |
| SUSE | `ec2-user` |
| Fedora | `fedora` or `ec2-user` |

## Method 2: Try Common Usernames

Since you have the IP (44.223.6.71) and SSH key, try these in order:

### Step 1: Prepare Your SSH Key

**You already have your SSH private key.** Save it to a file named `ec2-key.pem` in a secure location.

**Set correct permissions:**
```powershell
# On Windows PowerShell
icacls "ec2-key.pem" /inheritance:r
icacls "ec2-key.pem" /grant "${env:USERNAME}:R"
```

**Important:** Never share or commit your private key!

### Step 2: Test Connection with Different Usernames

**Try `ec2-user` first (most common):**
```powershell
ssh -i ec2-key.pem ec2-user@44.223.6.71
```

**If that fails, try `ubuntu`:**
```powershell
ssh -i ec2-key.pem ubuntu@44.223.6.71
```

**If that fails, try `admin`:**
```powershell
ssh -i ec2-key.pem admin@44.223.6.71
```

**If that fails, try `centos`:**
```powershell
ssh -i ec2-key.pem centos@44.223.6.71
```

## Method 3: Check EC2 Instance Connect (AWS Console)

1. Go to **EC2** → **Instances**
2. Select your instance
3. Click **Connect** button
4. Choose **EC2 Instance Connect** tab
5. Click **Connect** - this opens a browser-based terminal
6. Once connected, run:
   ```bash
   whoami
   ```
   This shows the current username!

## Method 4: Check AMI Details

1. Go to **EC2** → **Instances**
2. Select your instance
3. In the **Details** tab, find **AMI ID** (starts with `ami-`)
4. Click on the AMI ID link
5. In the AMI details, check **Description** or **Platform details**
6. It will usually mention the default username

## Most Likely Username

Based on your setup, **`ec2-user`** is most likely (90% chance) because:
- Amazon Linux is the most common AMI
- Your documentation mentions Amazon Linux 2023
- Most AWS tutorials use `ec2-user`

## Once You Find It

After you successfully connect, note the username and use it in GitHub Secrets:

- **EC2_HOST**: `44.223.6.71`
- **EC2_USER**: `ec2-user` (or whatever worked)
- **EC2_SSH_KEY**: (the entire private key content you have)

## Troubleshooting

### "Permission denied (publickey)"
- Wrong username - try another one
- Wrong key file - make sure it's the correct `.pem` file
- Key permissions wrong - on Linux/Mac: `chmod 400 ec2-key.pem`

### "Connection refused" or "Connection timed out"
- Security Group doesn't allow port 22 from your IP
- Instance might be stopped
- Check Security Group inbound rules

### "Host key verification failed"
- Add `-o StrictHostKeyChecking=no` to SSH command:
  ```bash
  ssh -i ec2-key.pem -o StrictHostKeyChecking=no ec2-user@44.223.6.71
  ```

## Quick Test Script

Save this as `test-ssh.ps1` and run it:

```powershell
$IP = "44.223.6.71"
$KEY = "ec2-key.pem"
$USERS = @("ec2-user", "ubuntu", "admin", "centos", "fedora")

foreach ($user in $USERS) {
    Write-Host "Trying $user@$IP..." -ForegroundColor Yellow
    $result = ssh -i $KEY -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$user@$IP" "whoami" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ SUCCESS! Username is: $user" -ForegroundColor Green
        Write-Host "Output: $result" -ForegroundColor Green
        break
    } else {
        Write-Host "❌ Failed with $user" -ForegroundColor Red
    }
}
```

