# EC2 Cost Management Guide

## Understanding EC2 Costs

### t2.micro Free Tier:
- **750 hours/month FREE** (for first 12 months)
- **1 instance running 24/7 = 730 hours/month**
- **You have ~20 hours buffer** (750 - 730 = 20 hours)

### After Free Tier (12 months):
- **t2.micro cost:** ~$8-10/month if running 24/7
- **Data transfer:** Additional charges apply
- **EBS storage:** ~$0.10/GB/month

---

## Cost Scenarios

### Scenario 1: Keep Running 24/7
- **Free Tier:** ✅ Free for 12 months
- **After Free Tier:** ~$8-10/month
- **Best for:** Active development/testing

### Scenario 2: Stop When Not Using
- **Stopped instance:** $0/hour (compute)
- **EBS storage:** Still charged (~$0.10/GB/month)
- **Elastic IP:** Free if attached to running instance, $0.005/hour if unattached
- **Best for:** Learning, POC when not actively working

### Scenario 3: Terminate (Delete)
- **No charges** (everything deleted)
- **Data lost** (need to redeploy)
- **Best for:** Finished POC, starting fresh

---

## What Gets Charged When Stopped?

### ✅ FREE (No Charge):
- EC2 compute (instance not running)
- Elastic IP (if attached to stopped instance)

### ❌ STILL CHARGED:
- **EBS Storage:** ~$0.10/GB/month (8GB = ~$0.80/month)
- **Elastic IP:** $0.005/hour if unattached to instance

### Example Cost (Stopped Instance):
- 8GB EBS volume: ~$0.80/month
- Elastic IP (if unattached): ~$3.60/month
- **Total:** ~$4.40/month (much cheaper than running)

---

## Recommendations

### For Learning/POC:

**Option 1: Stop When Not Using** (Recommended)
```
✅ Pros:
- Saves compute costs
- Data preserved (EBS volume)
- Quick to restart (2-3 minutes)
- Only pay for storage (~$0.80/month)

❌ Cons:
- Public IP changes (unless using Elastic IP)
- Need to restart manually
```

**Option 2: Keep Running During Active Learning**
```
✅ Pros:
- Always available
- No restart time
- Consistent IP address

❌ Cons:
- Uses free tier hours
- Costs after free tier expires
```

**Option 3: Terminate When Done**
```
✅ Pros:
- Zero cost
- Clean slate

❌ Cons:
- Need to redeploy everything
- Lose all data
```

---

## How to Stop EC2 Instance

### Via AWS Console:
1. Go to **EC2 Dashboard** → **Instances**
2. Select your instance
3. Click **Instance state** → **Stop instance**
4. Confirm

### Via Command Line:
```bash
aws ec2 stop-instances --instance-ids i-03d32a2392a12d09f
```

### What Happens:
- Instance stops (no compute charges)
- EBS volume remains (still charged)
- Public IP released (unless Elastic IP)
- Data preserved

---

## How to Start EC2 Instance

### Via AWS Console:
1. Go to **EC2 Dashboard** → **Instances**
2. Select stopped instance
3. Click **Instance state** → **Start instance**
4. Wait 2-3 minutes

### Via Command Line:
```bash
aws ec2 start-instances --instance-ids i-03d32a2392a12d09f
```

### What Happens:
- Instance starts (compute charges resume)
- New public IP assigned (unless Elastic IP)
- All data intact
- Containers need to be restarted

---

## How to Terminate EC2 Instance

### ⚠️ WARNING: This DELETES everything!

### Via AWS Console:
1. Go to **EC2 Dashboard** → **Instances**
2. Select instance
3. Click **Instance state** → **Terminate instance**
4. Confirm (type "delete")

### What Gets Deleted:
- EC2 instance
- EBS volume (unless configured to keep)
- All data on instance
- Need to redeploy from scratch

---

## Best Practices for Learning

### 1. Use Elastic IP (Free)
- **Attach Elastic IP** to your instance
- **Free** when attached to running/stopped instance
- **$0.005/hour** if unattached
- **Benefit:** Same IP after restart

**How to Create:**
1. EC2 → **Elastic IPs** → **Allocate Elastic IP**
2. **Associate** with your instance
3. Now IP won't change on restart

### 2. Stop When Not Learning
- Stop instance when not actively working
- Start when needed (2-3 minutes)
- Save compute costs

### 3. Monitor Usage
- Check **AWS Billing Dashboard**
- Set up **Billing Alerts** ($5, $10 thresholds)
- Track free tier usage

### 4. Clean Up Resources
- Terminate when POC is complete
- Delete unused EBS volumes
- Release unattached Elastic IPs

---

## Cost Comparison

| Scenario | Monthly Cost | Best For |
|----------|--------------|----------|
| Running 24/7 (Free Tier) | $0 | Active development |
| Running 24/7 (After Free Tier) | ~$8-10 | Production |
| Stopped (Storage only) | ~$0.80 | Learning/POC |
| Terminated | $0 | Finished POC |

---

## Setting Up Billing Alerts

### Step 1: Enable Billing Alerts
1. Go to **AWS Billing Dashboard**
2. **Preferences** → Enable **Receive Billing Alerts**

### Step 2: Create CloudWatch Alarm
1. **CloudWatch** → **Alarms** → **Create alarm**
2. Select **Billing** metric
3. Set threshold (e.g., $5)
4. Configure SNS notification (email)

### Step 3: Test
- You'll receive email when threshold reached

---

## Quick Reference

### Check Current Costs:
```
AWS Console → Billing Dashboard → Cost Explorer
```

### Stop Instance:
```
EC2 → Instances → Select → Instance state → Stop
```

### Start Instance:
```
EC2 → Instances → Select → Instance state → Start
```

### Check Free Tier Usage:
```
AWS Console → Billing → Free Tier
```

---

## My Recommendation for You:

### During Active Learning:
✅ **Keep running** (you're within free tier)
- Always available for testing
- No restart delays
- Free for 12 months

### When Not Learning (Weekends/Nights):
✅ **Stop the instance**
- Saves free tier hours
- Only pay for storage (~$0.80/month)
- Quick to restart (2-3 minutes)

### When POC Complete:
✅ **Terminate instance**
- Zero cost
- Clean up resources
- Start fresh for next project

---

## Action Items:

1. **Set up Billing Alert** ($5 threshold)
2. **Create Elastic IP** (optional, for consistent IP)
3. **Stop instance** when not actively learning
4. **Monitor usage** in Billing Dashboard

**Current Status:** You're safe to keep running during active learning (free tier covers it)

Want help setting up billing alerts or Elastic IP?

