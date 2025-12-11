# Test SSH Connection to Find EC2 Username
# Run this script to automatically find the correct username

$IP = "44.223.6.71"
$KEY = "ec2-key.pem"
$USERS = @("ec2-user", "ubuntu", "admin", "centos", "fedora")

Write-Host "Testing SSH connection to $IP..." -ForegroundColor Cyan
Write-Host ""

# Check if key file exists
if (-not (Test-Path $KEY)) {
    Write-Host "❌ Key file '$KEY' not found!" -ForegroundColor Red
    Write-Host "Please create the key file first (see FIND_EC2_USERNAME.md)" -ForegroundColor Yellow
    exit 1
}

foreach ($user in $USERS) {
    Write-Host "Trying $user@$IP..." -ForegroundColor Yellow
    
    # Try to connect and run a simple command
    $result = ssh -i $KEY -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$user@$IP" "whoami" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✅ SUCCESS! Username is: $user" -ForegroundColor Green
        Write-Host "Connected user: $result" -ForegroundColor Green
        Write-Host ""
        Write-Host "Use this in GitHub Secrets:" -ForegroundColor Cyan
        Write-Host "  EC2_HOST: $IP" -ForegroundColor White
        Write-Host "  EC2_USER: $user" -ForegroundColor White
        Write-Host ""
        exit 0
    } else {
        Write-Host "  ❌ Failed" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "❌ Could not connect with any common username" -ForegroundColor Red
Write-Host ""
Write-Host "Please check:" -ForegroundColor Yellow
Write-Host "  1. Security Group allows port 22 from your IP" -ForegroundColor White
Write-Host "  2. EC2 instance is running" -ForegroundColor White
Write-Host "  3. You're using the correct SSH key" -ForegroundColor White
Write-Host "  4. Check AWS Console for AMI type and username" -ForegroundColor White

