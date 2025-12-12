# CI/CD Documentation

This section contains guides for setting up and understanding Continuous Integration and Continuous Deployment pipelines.

## Files in This Section

### 1. [CI/CD Guide](CI_CD_GUIDE.md)
**Purpose:** Comprehensive guide to CI/CD setup and automation

**What you'll learn:**
- What is CI/CD and why it matters
- GitHub Actions setup
- AWS CodePipeline setup
- Deployment strategies
- Best practices

**When to read:** When setting up automated deployment.

---

### 2. [CI/CD Step Ordering Guide](CI_CD_STEP_ORDERING_GUIDE.md)
**Purpose:** Understanding how to order steps in CI/CD pipelines

**What you'll learn:**
- Step dependency principles
- Common pipeline patterns
- How to determine correct step order
- Decision trees for pipeline design

**When to read:** When creating or modifying CI/CD workflows.

---

### 3. [GitHub Secrets Setup](GITHUB_SECRETS_SETUP.md)
**Purpose:** Configuring secrets for GitHub Actions

**What you'll learn:**
- What secrets are needed
- How to create and manage secrets
- Security best practices
- Troubleshooting secret issues

**When to read:** Before setting up GitHub Actions workflows.

---

## Reading Order

1. **First:** Read [CI/CD Guide](CI_CD_GUIDE.md) for overview
2. **Then:** Follow [GitHub Secrets Setup](GITHUB_SECRETS_SETUP.md) for configuration
3. **Reference:** Use [CI/CD Step Ordering Guide](CI_CD_STEP_ORDERING_GUIDE.md) when building pipelines

---

## Related Documentation

- [EC2 Connection Guide](../02-ec2-setup/EC2_CONNECTION_GUIDE.md) - Manual deployment
- [Deployment Fix](../02-ec2-setup/DEPLOYMENT_FIX.md) - Troubleshooting

