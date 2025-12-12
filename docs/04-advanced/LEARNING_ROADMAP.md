# Learning Roadmap - EC2 POC to Production

## Current Status ✅
- Single EC2 instance (t2.micro)
- Docker containers (Node.js API + Nginx)
- Basic deployment
- Understanding of VPC, Security Groups

---

## Phase 1: CI/CD Pipeline (Cost: $0 - Free Tier)

### Goal: Automate deployments

### Option A: GitHub Actions (Recommended - Free)
- **What:** Automated build and deploy on git push
- **How:** 
  - Push code → GitHub Actions builds → Deploys to EC2
  - No additional AWS costs
- **Learn:**
  - GitHub Actions workflows
  - SSH deployment to EC2
  - Automated testing
  - Environment variables management

### Option B: AWS CodePipeline (Free Tier: 1 pipeline/month)
- **What:** AWS-native CI/CD service
- **How:**
  - CodePipeline → CodeBuild → Deploy to EC2
- **Learn:**
  - AWS CI/CD services
  - IAM roles for services
  - Build artifacts

**Why First:** Automates deployments, saves time, no infrastructure cost

---

## Phase 2: VPC Architecture (Cost: ~$32/month for NAT Gateway)

### Goal: Production-ready network architecture

### Setup:
- **Custom VPC** (instead of default)
- **Public Subnets** (ALB, NAT Gateway)
- **Private Subnets** (EC2, RDS)
- **Internet Gateway** (public internet access)
- **NAT Gateway** (private subnet outbound access)
- **Security Groups** (proper network segmentation)

### Learn:
- VPC CIDR planning
- Subnet design (public/private)
- Route tables configuration
- Security Groups best practices
- Network ACLs (optional)
- VPC Flow Logs
- Multi-AZ architecture

**Why Second:** Foundation for secure, production-ready infrastructure

---

## Phase 3: RDS Integration (Cost: ~$15/month - Free Tier eligible)

### Goal: Add persistent database

### Setup:
- **RDS PostgreSQL** (db.t3.micro - Free Tier eligible)
- Connect Node.js API to RDS
- Update docker-compose.yml with database connection

### Learn:
- RDS instance creation
- Security Groups for database access
- Connection strings and environment variables
- Database migrations
- Connection pooling

**Why Third:** Foundation for data persistence, needed before replication

---

## Phase 4: Database Replication (Cost: ~$15/month additional)

### Goal: High availability and read scaling

### Setup:
- **Primary RDS** (write operations)
- **Read Replica** (read operations)
- Configure read/write splitting in application

### Learn:
- RDS Read Replicas
- Read vs Write operations
- Connection routing (write to primary, read from replica)
- Failover scenarios
- Replication lag understanding

**Why Fourth:** Improves availability and read performance

---

## Phase 5: Multiple EC2 Instances + ALB (Cost: ~$20-30/month)

### Goal: High availability and load distribution

### Setup:
- **2-3 EC2 instances** (t2.micro or t3.micro)
- **Application Load Balancer (ALB)**
- **Target Group** (register EC2 instances)
- **Auto Scaling Group** (optional)

### Learn:
- ALB configuration
- Target Groups and health checks
- Multiple EC2 instances setup
- Session management (stateless apps)
- Load balancing algorithms
- Health check configuration

**Why Fifth:** Distributes load, improves availability

---

## Phase 6: Distributed Systems Concepts

### Goal: Understand distributed architecture

### Learn:
- **Stateless vs Stateful applications**
- **Session management** (Redis, database)
- **Caching strategies** (Redis/ElastiCache)
- **Message queues** (SQS for async processing)
- **Service discovery**
- **Circuit breakers**
- **Distributed tracing**

### Practical Implementation:
- Add Redis for session storage
- Implement caching layer
- Use SQS for background jobs
- Monitor distributed system health

**Why Sixth:** Production-ready distributed architecture

---

## Cost Summary

| Phase | Service | Monthly Cost | Free Tier |
|-------|----------|---------------|-----------|
| Phase 1 | CI/CD | $0 | ✅ GitHub Actions free |
| Phase 2 | VPC + NAT Gateway | ~$32 | ❌ Additional cost |
| Phase 3 | RDS | ~$15 | ✅ db.t3.micro eligible |
| Phase 4 | RDS Replica | ~$15 | ❌ Additional cost |
| Phase 5 | ALB + 2 EC2 | ~$20-30 | ❌ Additional cost |
| Phase 6 | Redis/SQS | ~$10-15 | ❌ Additional cost |
| **Total** | | **~$92-107/month** | |

**Note:** Can use Free Tier for Phase 1-2, then add others gradually.

---

## Learning Order Summary

1. **CI/CD** → Automate deployments (no cost)
2. **VPC Architecture** → Custom VPC, subnets, security (minimal cost)
3. **RDS Integration** → Add database (Free Tier)
4. **Database Replication** → Read replicas (availability)
5. **Multiple EC2 + ALB** → High availability (distributed)
6. **Distributed Concepts** → Production patterns

---

## Key Concepts to Master

### CI/CD:
- Workflow automation
- Environment management
- Deployment strategies (blue/green, rolling)

### Database:
- Primary/Replica architecture
- Read/Write splitting
- Connection pooling
- Failover handling

### Load Balancing:
- ALB routing rules
- Health checks
- Target groups
- Auto scaling integration

### Distributed Systems:
- Stateless design
- Caching strategies
- Message queues
- Service communication

---

## Next Step

**Start with Phase 1: CI/CD**
- Choose GitHub Actions (free, easier)
- Set up automated deployment
- Learn workflow YAML syntax

Ready to start Phase 1?

