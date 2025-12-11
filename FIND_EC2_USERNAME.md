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

### Step 1: Save your SSH key to a file

**On Windows (PowerShell):**
```powershell
# Create the key file
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

# Set correct permissions (important!)
icacls "ec2-key.pem" /inheritance:r
icacls "ec2-key.pem" /grant:r "$env:USERNAME:R"
```

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

