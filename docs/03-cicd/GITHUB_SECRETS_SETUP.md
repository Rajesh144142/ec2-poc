# GitHub Secrets Setup - Ready to Configure

## ✅ Your EC2 Details (Confirmed)

- **EC2_HOST**: `44.223.6.71`
- **EC2_USER**: `ec2-user` ✅ (Confirmed via SSH)
- **EC2_SSH_KEY**: (See below)

---

## Step-by-Step: Add GitHub Secrets

### 1. Go to Your GitHub Repository

1. Open your repository on GitHub
2. Click **Settings** (top menu)
3. In the left sidebar, click **Secrets and variables** → **Actions**
4. Click **New repository secret** button

### 2. Add Secret 1: EC2_HOST

- **Name**: `EC2_HOST`
- **Value**: `44.223.6.71`
- Click **Add secret**

### 3. Add Secret 2: EC2_USER

- **Name**: `EC2_USER`
- **Value**: `ec2-user`
- Click **Add secret**

### 4. Add Secret 3: EC2_SSH_KEY

- **Name**: `EC2_SSH_KEY`
- **Value**: Copy the ENTIRE content of your `ec2-key.pem` file

**How to get the key content:**

**Option 1: Using PowerShell (Recommended)**
```powershell
# Run this in your local Windows PowerShell (NOT on EC2):
# Replace 'path\to\your\key.pem' with your actual key file path
Get-Content path\to\your\ec2-key.pem
```

**Option 2: Using Notepad**
1. Open File Explorer
2. Navigate to the folder containing your `ec2-key.pem` file
3. Right-click `ec2-key.pem` → Open with → Notepad
4. Select All (Ctrl+A) and Copy (Ctrl+C)

**Important**: 
- Include the `-----BEGIN RSA PRIVATE KEY-----` line
- Include the `-----END RSA PRIVATE KEY-----` line
- Include ALL the content in between
- Paste the entire content into the GitHub Secret value field
- Click **Add secret**

---

---

## Verify Your Secrets

After adding all 3 secrets, you should see:

- ✅ `EC2_HOST`
- ✅ `EC2_USER`
- ✅ `EC2_SSH_KEY`

---

## Next Steps

Once all secrets are configured:

1. **Push your code to GitHub:**
   ```bash
   git add .
   git commit -m "Add CI/CD pipeline"
   git push origin main
   ```

2. **Watch the deployment:**
   - Go to your GitHub repository
   - Click **Actions** tab
   - Watch the workflow run automatically!

3. **Test your API:**
   - After successful deployment, test: `http://44.223.6.71/health`

---

## Security Reminder

✅ **DO**: Store secrets in GitHub Secrets (secure)  
❌ **DON'T**: Commit the `ec2-key.pem` file to Git (already in `.gitignore`)

---

## Troubleshooting

### If deployment fails:

1. **Check Security Group**: Ensure port 22 (SSH) is open
2. **Check GitHub Actions logs**: Go to Actions → Click on failed workflow → Check logs
3. **Verify secrets**: Make sure all 3 secrets are set correctly
4. **Test SSH manually**: `ssh -i ec2-key.pem ec2-user@44.223.6.71`

---

## Summary Checklist

- [x] EC2 username confirmed: `ec2-user`
- [x] SSH connection working
- [ ] GitHub Secret `EC2_HOST` added: `44.223.6.71`
- [ ] GitHub Secret `EC2_USER` added: `ec2-user`
- [ ] GitHub Secret `EC2_SSH_KEY` added: (full key content)
- [ ] Code pushed to GitHub
- [ ] First deployment successful

You're almost there! 🚀

