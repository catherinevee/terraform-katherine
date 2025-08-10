# GitHub Actions Workflows for Terraform-Katherine

This directory contains GitHub Actions workflows designed for secure, compliant infrastructure deployment with SOC2 Type II and PCI-DSS Level 1 controls for financial services workloads.

## Workflow Overview

### 🔒 Security and Compliance Scan (`security-scan.yml`)
**Purpose**: Comprehensive security scanning and compliance validation
**Triggers**: Push/PR to main/develop, daily scheduled scans, manual dispatch
**Security Features**:
- Multiple security scanners (TFSec, Checkov, Trivy, OWASP Dependency Check)
- SOC2 and PCI-DSS compliance validation
- SARIF report generation for GitHub Security tab
- OIDC-based AWS authentication (no long-lived secrets)
- Script injection protection
- Pinned action versions for security

### ✅ Infrastructure Validation (`validate.yml`)
**Purpose**: Terraform/Terragrunt validation, testing, and cost analysis
**Triggers**: Push/PR to main/develop, manual dispatch
**Features**:
- Terraform format and validation checks
- Terragrunt dependency validation
- Infrastructure testing with Terratest
- Cost estimation with Infracost
- Security policy validation
- Parallel job execution for performance

### 🚀 Infrastructure Deployment (`deploy.yml`)
**Purpose**: Secure infrastructure deployment with approval gates
**Triggers**: Manual dispatch only (security requirement)
**Security Features**:
- Environment protection rules
- Manual approval gates for production
- Rollback capabilities for failed deployments
- Pre-deployment security scans
- OIDC-based AWS authentication
- Deployment notifications

### 📋 Compliance Monitoring (`compliance.yml`)
**Purpose**: Automated compliance validation and reporting
**Triggers**: Weekly scheduled scans, manual dispatch
**Compliance Standards**:
- SOC2 Type II (CC1-CC5 controls)
- PCI-DSS Level 1 (Requirements 1-6)
- Automated compliance reporting
- Audit trail generation

## Security Controls Implemented

### 1. Script Injection Protection
- ✅ No direct use of `${{ github.event.* }}` in run commands
- ✅ User-controlled inputs assigned to environment variables
- ✅ No dynamic command execution without sanitization
- ✅ PR code not checked out in security-sensitive jobs

### 2. Token and Permissions Security
- ✅ Explicit `permissions` blocks with minimal required access
- ✅ GITHUB_TOKEN has read-only permissions by default
- ✅ Job-specific permissions where appropriate
- ✅ OIDC implementation for AWS authentication
- ✅ No long-lived secrets for cloud providers

### 3. Third-Party Action Security
- ✅ All actions pinned to specific versions
- ✅ Actions from verified publishers (GitHub, HashiCorp, AWS)
- ✅ No actions using 'main' or 'master' branches
- ✅ Security-focused action selection

### 4. Secrets Management
- ✅ No hardcoded secrets or credentials
- ✅ Environment-specific secrets properly scoped
- ✅ Secrets never printed in logs or outputs
- ✅ GitHub Environments with protection rules
- ✅ OIDC for AWS/Azure/GCP authentication

### 5. Dangerous Trigger Events
- ✅ No use of `pull_request_target` that checks out PR code
- ✅ Manual `workflow_dispatch` with input validation
- ✅ Branch protection integration
- ✅ Environment protection rules

## Performance Optimizations

### 6. Caching Strategy
- ✅ Latest actions/cache@v4 for dependency caching
- ✅ Appropriate cache keys using hashFiles()
- ✅ Cross-OS cache sharing where applicable
- ✅ Docker layer caching opportunities identified

### 7. Job Parallelization
- ✅ Jobs run in parallel where possible
- ✅ Matrix strategy for multi-platform builds
- ✅ Concurrency controls to prevent duplicate runs
- ✅ Appropriate timeout-minutes at job and step levels

### 8. Artifact Management
- ✅ Reasonable artifact retention periods (7-90 days)
- ✅ Compression for large artifacts
- ✅ Artifact size optimization

## Compliance Features

### SOC2 Type II Controls
- **CC1 - Control Environment**: IAM roles, security groups, KMS encryption
- **CC2 - Communication and Information**: CloudWatch logging, VPC Flow Logs, audit logs
- **CC3 - Risk Assessment**: Encryption, backup policies, monitoring
- **CC4 - Monitoring Activities**: CloudWatch alarms, SNS notifications, Lambda automation
- **CC5 - Control Activities**: Auto-scaling, backup automation, patch management

### PCI-DSS Level 1 Requirements
- **Req 1 - Firewall Configuration**: VPC, security groups, network ACLs
- **Req 2 - Secure Configuration**: Encryption, SSL certificates, secure protocols
- **Req 3 - Cardholder Data Protection**: Encryption at rest/in transit, key management
- **Req 4 - Secure Transmission**: TLS, HTTPS, VPN connections
- **Req 5 - Vulnerability Management**: Patch management, security updates, vulnerability scanning
- **Req 6 - Access Control**: IAM roles, user management, privileged access control

## Required Secrets

Configure the following secrets in your GitHub repository:

```bash
# AWS OIDC Role ARN for authentication
AWS_ROLE_ARN=arn:aws:iam::123456789012:role/github-actions-role

# Infracost API key for cost analysis
INFRACOST_API_KEY=ico_xxxxxxxxxxxxxxxxxxxxxxxx

# Slack webhook URL for notifications (optional)
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/xxx/yyy/zzz
```

## Environment Configuration

### GitHub Environments
Configure the following environments in your repository:

1. **dev**: Development environment
2. **staging**: Staging environment  
3. **prod**: Production environment (with protection rules)

### Environment Protection Rules
For production environment:
- ✅ Required reviewers (minimum 2)
- ✅ Wait timer (5 minutes)
- ✅ Deployment branches (main only)
- ✅ Environment-specific secrets

## Usage Instructions

### Running Security Scans
```bash
# Manual security scan for all environments
gh workflow run security-scan.yml -f environment=all

# Security scan for specific environment
gh workflow run security-scan.yml -f environment=prod
```

### Validating Infrastructure
```bash
# Validate infrastructure for development
gh workflow run validate.yml -f environment=dev

# Validate with cost analysis
gh workflow run validate.yml -f environment=staging
```

### Deploying Infrastructure
```bash
# Generate deployment plan
gh workflow run deploy.yml -f environment=staging -f action=plan

# Apply deployment (requires approval)
gh workflow run deploy.yml -f environment=prod -f action=apply
```

### Running Compliance Checks
```bash
# Full compliance check
gh workflow run compliance.yml -f compliance_standard=all

# SOC2 compliance only
gh workflow run compliance.yml -f compliance_standard=soc2
```

## Monitoring and Observability

### Structured Logging
- ✅ `::notice::` for informational messages
- ✅ `::warning::` for non-critical issues
- ✅ `::error::` for critical failures

### Deployment Notifications
- ✅ Slack/Teams integration
- ✅ Email notifications (via webhooks)
- ✅ GitHub deployment status updates

### Metrics Collection
- ✅ Deployment frequency tracking
- ✅ Lead time for changes
- ✅ Mean time to recovery (MTTR)
- ✅ Change failure rate

## Troubleshooting

### Common Issues

1. **AWS Authentication Failures**
   - Verify OIDC role ARN is correct
   - Check role trust policy includes GitHub Actions
   - Ensure role has required permissions

2. **Compliance Check Failures**
   - Review infrastructure configurations
   - Check for missing security controls
   - Verify environment-specific settings

3. **Deployment Failures**
   - Check environment protection rules
   - Verify approval requirements
   - Review rollback procedures

### Debug Mode
Enable debug logging by setting the secret:
```bash
ACTIONS_STEP_DEBUG=true
```

## Security Best Practices

1. **Regular Updates**: Keep workflow actions updated to latest versions
2. **Access Reviews**: Regularly review GitHub repository permissions
3. **Secret Rotation**: Rotate secrets and API keys periodically
4. **Audit Logs**: Monitor GitHub audit logs for suspicious activity
5. **Environment Isolation**: Maintain strict separation between environments

## Compliance Documentation

### Audit Trail
- All workflow runs are logged in GitHub Actions
- Compliance reports are generated and stored as artifacts
- SARIF files are uploaded to GitHub Security tab
- Deployment approvals are tracked in environment logs

### Reporting
- Weekly compliance reports generated automatically
- Monthly compliance summaries available
- Quarterly audit reports for external auditors
- Annual SOC2 and PCI-DSS compliance assessments

## Support and Maintenance

### Regular Maintenance Tasks
- [ ] Update action versions monthly
- [ ] Review and rotate secrets quarterly
- [ ] Update compliance controls annually
- [ ] Review and optimize performance quarterly

### Contact Information
- **Security Issues**: security@company.com
- **Compliance Questions**: compliance@company.com
- **Infrastructure Support**: devops@company.com

## References

- [GitHub Actions Security Best Practices](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
- [SOC2 Trust Service Criteria](https://www.aicpa.org/interestareas/frc/assuranceadvisoryservices/aicpasoc2report.html)
- [PCI-DSS Requirements](https://www.pcisecuritystandards.org/document_library)
- [AWS OIDC for GitHub Actions](https://docs.aws.amazon.com/iam/latest/UserGuide/id_roles_providers_create_oidc.html)
- [Terraform Security Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/security.html) 