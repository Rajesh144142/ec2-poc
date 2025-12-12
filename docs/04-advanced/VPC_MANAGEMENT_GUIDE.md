# VPC Management Guide - Production Architecture

## What is VPC and Why It Matters

### VPC (Virtual Private Cloud)
- **Isolated network** in AWS cloud
- Like your own private data center
- Full control over network configuration
- Security boundaries for your resources

### Why VPC is Critical:
1. **Security:** Isolate resources from internet
2. **Compliance:** Meet regulatory requirements
3. **Network Control:** Define IP ranges, routing
4. **Multi-tier Architecture:** Separate public/private resources
5. **Production Standard:** Industry best practice

---

## VPC Architecture Components

### 1. VPC (Virtual Private Cloud)
- **CIDR Block:** IP address range (e.g., 10.0.0.0/16)
- **Region:** VPC exists in one AWS region
- **Isolation:** Resources in VPC are isolated from other VPCs

### 2. Subnets
- **Public Subnet:** Resources with internet access
  - Has route to Internet Gateway
  - Used for: Load Balancers, NAT Gateways, Bastion hosts
- **Private Subnet:** Resources without direct internet access
  - No direct internet route
  - Used for: Application servers, Databases, Internal services

### 3. Internet Gateway (IGW)
- Connects VPC to internet
- One per VPC
- Attached to public subnets

### 4. NAT Gateway
- Allows private subnet resources to access internet (outbound only)
- No inbound internet access
- Required for: Software updates, API calls from private resources

### 5. Route Tables
- Define network routing rules
- Public subnet: Route to Internet Gateway
- Private subnet: Route to NAT Gateway (for outbound)

### 6. Security Groups
- Virtual firewall for instances
- Inbound/outbound rules
- Stateful (return traffic automatically allowed)

### 7. Network ACLs (NACLs)
- Additional security layer at subnet level
- Stateless (must define both directions)
- Less commonly used (Security Groups preferred)

---

## Standard VPC Architecture

### Production-Ready Setup:

```
Internet
   │
   ├─ Internet Gateway
   │
   ├─ Public Subnet (AZ-1)
   │   ├─ ALB (Application Load Balancer)
   │   └─ NAT Gateway
   │
   ├─ Public Subnet (AZ-2)
   │   └─ NAT Gateway (for high availability)
   │
   ├─ Private Subnet (AZ-1)
   │   ├─ EC2 Instance 1 (Application)
   │   └─ RDS Primary (Database)
   │
   └─ Private Subnet (AZ-2)
       ├─ EC2 Instance 2 (Application)
       └─ RDS Replica (Database)
```

### Key Points:
- **Multi-AZ:** Resources across Availability Zones (high availability)
- **Public Subnets:** Only ALB and NAT Gateway
- **Private Subnets:** Application and Database (more secure)
- **NAT Gateway:** Allows private resources to download updates

---

## How to Build Inside VPC

### Step 1: Create Custom VPC (Instead of Default)

**Why Custom VPC?**
- Better IP address planning
- More control over network design
- Production best practice

**Configuration:**
```
VPC CIDR: 10.0.0.0/16 (65,536 IP addresses)
Region: Choose based on client location
```

### Step 2: Create Subnets

**Public Subnets:**
```
Public Subnet 1 (AZ-1): 10.0.1.0/24
Public Subnet 2 (AZ-2): 10.0.2.0/24
```

**Private Subnets:**
```
Private Subnet 1 (AZ-1): 10.0.11.0/24
Private Subnet 2 (AZ-2): 10.0.12.0/24
```

**Database Subnets (Isolated):**
```
DB Subnet 1 (AZ-1): 10.0.21.0/24
DB Subnet 2 (AZ-2): 10.0.22.0/24
```

### Step 3: Internet Gateway
- Attach to VPC
- Add route in public subnet route table: `0.0.0.0/0 → IGW`

### Step 4: NAT Gateway
- Create in public subnet
- Allocate Elastic IP
- Add route in private subnet route table: `0.0.0.0/0 → NAT Gateway`

### Step 5: Deploy Resources

**Public Subnet:**
- ALB (Application Load Balancer)
- NAT Gateway

**Private Subnet:**
- EC2 instances (Application)
- RDS (Database)

---

## Security Best Practices

### 1. Network Segmentation
- **Public Subnet:** Only load balancers, NAT
- **Private Subnet:** Application servers
- **Database Subnet:** Only databases (most secure)

### 2. Security Groups Rules

**ALB Security Group:**
```
Inbound: Port 80, 443 from 0.0.0.0/0
Outbound: Port 3000 to Application Security Group
```

**Application Security Group:**
```
Inbound: Port 3000 from ALB Security Group
Outbound: Port 5432 to Database Security Group (PostgreSQL)
Outbound: Port 443 to 0.0.0.0/0 (for API calls)
```

**Database Security Group:**
```
Inbound: Port 5432 from Application Security Group ONLY
Outbound: None (or specific if needed)
```

### 3. Principle of Least Privilege
- Only allow necessary ports
- Restrict source IPs where possible
- Use Security Groups, not 0.0.0.0/0 for databases

### 4. No Direct Internet Access for Private Resources
- Use NAT Gateway for outbound
- No public IPs on private instances
- Database in private subnet only

---

## Client Discussion Points

### 1. Network Architecture Requirements

**Questions to Ask:**
- How many environments? (Dev, Staging, Production)
- Expected traffic volume?
- Multi-region requirement?
- Compliance requirements? (HIPAA, PCI-DSS, etc.)

**Recommendations:**
- Separate VPC per environment (or VPC with subnets per environment)
- Multi-AZ for production (high availability)
- Private subnets for sensitive data

### 2. IP Address Planning

**Questions:**
- Current IP requirements?
- Future growth expectations?
- Integration with on-premise networks? (VPN required)

**Recommendations:**
- Use CIDR blocks that don't conflict with client's network
- Common: 10.0.0.0/16, 172.16.0.0/16, 192.168.0.0/16
- Reserve IP space for future expansion

### 3. Security Requirements

**Questions:**
- Data classification? (Public, Internal, Confidential)
- Compliance requirements?
- Access control needs?
- Audit logging requirements?

**Recommendations:**
- Database in private subnet
- Application in private subnet
- Only ALB in public subnet
- Enable VPC Flow Logs for auditing

### 4. High Availability

**Questions:**
- Downtime tolerance?
- RTO (Recovery Time Objective)?
- RPO (Recovery Point Objective)?

**Recommendations:**
- Multi-AZ deployment
- Auto Scaling Groups
- Database Multi-AZ with read replicas
- Load balancer across AZs

### 5. Cost Considerations

**Questions:**
- Budget constraints?
- Cost optimization priorities?

**Cost Breakdown:**
- VPC: Free
- Subnets: Free
- Internet Gateway: Free
- NAT Gateway: ~$32/month + data transfer
- VPC Endpoints (optional): ~$7/month per endpoint
- Data Transfer: Varies

**Cost Optimization:**
- Use NAT Instance instead of NAT Gateway (cheaper, less reliable)
- VPC Endpoints for AWS services (avoid NAT Gateway charges)
- Single NAT Gateway for non-critical environments

### 6. Integration Requirements

**Questions:**
- Connect to on-premise systems?
- AWS service integration? (S3, SQS, etc.)
- Third-party services?

**Options:**
- **VPN:** Site-to-Site VPN for on-premise
- **Direct Connect:** Dedicated connection (high bandwidth)
- **VPC Endpoints:** Private connection to AWS services

### 7. Monitoring and Logging

**Questions:**
- Logging requirements?
- Compliance audit needs?

**Recommendations:**
- Enable VPC Flow Logs
- CloudWatch monitoring
- Security Group change tracking
- Network performance monitoring

---

## VPC Configuration Checklist

### For Client Discussion:

- [ ] **Network Design**
  - [ ] VPC CIDR block selection
  - [ ] Subnet allocation (public/private)
  - [ ] Availability Zone distribution
  - [ ] IP address planning

- [ ] **Security**
  - [ ] Security Group rules
  - [ ] Network ACLs (if needed)
  - [ ] Database subnet isolation
  - [ ] VPC Flow Logs enablement

- [ ] **High Availability**
  - [ ] Multi-AZ deployment
  - [ ] NAT Gateway redundancy
  - [ ] Load balancer configuration
  - [ ] Auto Scaling setup

- [ ] **Cost Optimization**
  - [ ] NAT Gateway vs NAT Instance
  - [ ] VPC Endpoints for AWS services
  - [ ] Data transfer optimization
  - [ ] Resource right-sizing

- [ ] **Integration**
  - [ ] On-premise connectivity (if needed)
  - [ ] AWS service integration
  - [ ] Third-party service access

- [ ] **Compliance**
  - [ ] Regulatory requirements
  - [ ] Data residency
  - [ ] Audit logging
  - [ ] Encryption requirements

---

## Common VPC Scenarios

### Scenario 1: Simple Web Application
```
VPC: 10.0.0.0/16
├─ Public Subnet: ALB
└─ Private Subnet: EC2 + RDS
```
**Use Case:** Small to medium applications
**Cost:** Low (single NAT Gateway)

### Scenario 2: High Availability Production
```
VPC: 10.0.0.0/16
├─ Public Subnet (AZ-1): ALB, NAT Gateway
├─ Public Subnet (AZ-2): NAT Gateway
├─ Private Subnet (AZ-1): EC2, RDS Primary
└─ Private Subnet (AZ-2): EC2, RDS Replica
```
**Use Case:** Production applications
**Cost:** Medium (multiple NAT Gateways)

### Scenario 3: Multi-Environment
```
VPC: 10.0.0.0/16
├─ Dev Subnets (10.0.1.0/24, 10.0.11.0/24)
├─ Staging Subnets (10.0.2.0/24, 10.0.12.0/24)
└─ Prod Subnets (10.0.3.0/24, 10.0.13.0/24)
```
**Use Case:** Separate environments
**Cost:** Higher (multiple NAT Gateways)

---

## Implementation Steps

### 1. Plan VPC Architecture
- Define CIDR blocks
- Plan subnet allocation
- Identify resource placement

### 2. Create VPC
- Create custom VPC
- Configure DNS settings
- Enable DNS hostnames

### 3. Create Subnets
- Public subnets (2 AZs minimum)
- Private subnets (2 AZs minimum)
- Database subnets (optional, for isolation)

### 4. Configure Routing
- Internet Gateway for public subnets
- NAT Gateway for private subnets
- Route tables configuration

### 5. Configure Security
- Security Groups for each tier
- Network ACLs (if needed)
- VPC Flow Logs

### 6. Deploy Resources
- ALB in public subnet
- EC2 in private subnet
- RDS in private/database subnet

---

## Key Takeaways for Clients

1. **Security First:** Private subnets for applications and databases
2. **High Availability:** Multi-AZ deployment
3. **Cost vs Reliability:** NAT Gateway (reliable) vs NAT Instance (cheaper)
4. **Scalability:** Plan IP space for growth
5. **Compliance:** VPC Flow Logs for audit requirements
6. **Best Practice:** Separate public/private subnets

---

## Next Steps

1. **Design VPC architecture** based on client requirements
2. **Create VPC and subnets** in AWS Console
3. **Configure routing** (IGW, NAT Gateway)
4. **Set up Security Groups** with least privilege
5. **Deploy resources** in appropriate subnets
6. **Enable monitoring** (VPC Flow Logs, CloudWatch)

Ready to implement VPC architecture?

