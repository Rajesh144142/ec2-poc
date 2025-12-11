# Quick SSH Connection Test
# Run this from wherever your ec2-key.pem file is located

$IP = "44.223.6.71"
$KEY = "ec2-key.pem"

Write-Host "Testing SSH connection to $IP..." -ForegroundColor Cyan
Write-Host ""

# Check if key file exists
if (-not (Test-Path $KEY)) {
    Write-Host "❌ Key file '$KEY' not found in current directory!" -ForegroundColor Red
    Write-Host "Current directory: $(Get-Location)" -ForegroundColor Yellow
    Write-Host "Please navigate to the directory containing ec2-key.pem" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Key file found: $KEY" -ForegroundColor Green
Write-Host ""

# Try common usernames
$USERS = @("ec2-user", "ubuntu", "admin", "centos", "fedora")

foreach ($user in $USERS) {
    Write-Host "Trying $user@$IP..." -ForegroundColor Yellow -NoNewline
    
    # Try to connect and run a simple command
    $result = ssh -i $KEY -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$user@$IP" "whoami" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host " ✅ SUCCESS!" -ForegroundColor Green
        Write-Host ""
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
        Write-Host "✅ CONNECTION SUCCESSFUL!" -ForegroundColor Green
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
        Write-Host ""
        Write-Host "Your EC2 Username is: $user" -ForegroundColor Cyan
        Write-Host "Connected as: $result" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "📝 Use these values in GitHub Secrets:" -ForegroundColor Yellow
        Write-Host "   EC2_HOST: $IP" -ForegroundColor White
        Write-Host "   EC2_USER: $user" -ForegroundColor White
        Write-Host "   EC2_SSH_KEY: (copy entire content of ec2-key.pem)" -ForegroundColor White
        Write-Host ""
        exit 0
    } else {
        Write-Host " ❌ Failed" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Red
Write-Host "❌ Could not connect with any common username" -ForegroundColor Red
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Red
Write-Host ""
Write-Host "Please check:" -ForegroundColor Yellow
Write-Host "  1. Security Group allows port 22 from your IP" -ForegroundColor White
Write-Host "  2. EC2 instance is running (check AWS Console)" -ForegroundColor White
Write-Host "  3. You're using the correct SSH key" -ForegroundColor White
Write-Host "  4. Check AWS Console → EC2 → Connect → EC2 Instance Connect" -ForegroundColor White
Write-Host "     Then run 'whoami' to find the username" -ForegroundColor White
Write-Host ""

