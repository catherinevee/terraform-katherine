# AWS Infrastructure with Terragrunt

This repository contains Infrastructure as Code (IaC) using Terragrunt for managing AWS resources following enterprise-grade best practices, including SOC2 and PCI-DSS compliance requirements.

## 🎯 Key Features

- **Multi-Environment Support**: Separate configurations for development, staging, and production
- **Security-First Design**: Built-in compliance with SOC2 and PCI-DSS requirements
- **Infrastructure as Code**: Version-controlled infrastructure using Terragrunt and Terraform
- **Modular Architecture**: Reusable components across environments
- **Automated Compliance**: Built-in security controls and monitoring
- **Cost Optimization**: Environment-specific resource sizing
- **High Availability**: Multi-AZ deployments for production workloads
- **Disaster Recovery**: Automated backups and cross-region replication
- **Infrastructure Testing**: Built-in test suite for infrastructure validation

## 🗺️ Resource Map

```mermaid
graph TB
    subgraph Multi-Environment Infrastructure
        DEV[Development]
        STAGING[Staging]
        PROD[Production]
    end

    subgraph Network Layer
        VPC[VPC] --> SUBNETS[Public & Private Subnets]
        SUBNETS --> NGW[NAT Gateways]
        SUBNETS --> IGW[Internet Gateway]
        VPC --> FLOW[VPC Flow Logs]
        SG[Security Groups] --> SUBNETS
    end

    subgraph Application Layer
        EC2[EC2 Instances]
        EBS[EBS Volumes]
        ASG[Auto Scaling Groups]
        SSM[Systems Manager]
        
        ASG --> EC2
        EC2 --> EBS
        SSM --> EC2
    end

    subgraph Data Layer
        RDS[RDS PostgreSQL]
        S3[S3 Buckets]
        S3LOGS[S3 Logs]
        
        RDS --> S3LOGS
        S3 --> S3LOGS
    end

    subgraph Security & Compliance
        KMS[KMS Keys]
        IAM[IAM Roles]
        CW[CloudWatch]
        BACKUP[AWS Backup]
        
        KMS --> RDS
        KMS --> S3
        KMS --> EBS
        IAM --> EC2
        CW --> EC2
        CW --> RDS
        BACKUP --> RDS
        BACKUP --> EBS
    end

    DEV --> Network Layer
    STAGING --> Network Layer
    PROD --> Network Layer
```

## 📊 Environment Configuration Matrix

| Component | Development | Staging | Production |
|-----------|------------|----------|------------|
| **Network** |
| VPC CIDR | 10.0.0.0/16 | 172.16.0.0/16 | 192.168.0.0/16 |
| Availability Zones | 2 | 2 | 3 |
| NAT Gateways | 1 | 2 | 3 |
| VPC Flow Logs | Basic | Enhanced | Full |
| **Compute** |
| EC2 Instance Type | t3.micro | t3.medium | t3.large |
| Auto Scaling Min | 1 | 2 | 3 |
| Auto Scaling Max | 3 | 6 | 10 |
| EBS Volume Type | gp3 | gp3 | io2 |
| **Database** |
| RDS Instance Class | db.t3.small | db.t3.large | db.r6g.xlarge |
| Multi-AZ | No | Yes | Yes |
| Backup Retention | 7 days | 14 days | 35 days |
| Performance Insights | 7 days | 14 days | 731 days |
| **Storage** |
| S3 Versioning | Enabled | Enabled | Enabled |
| S3 Lifecycle Rules | 30 days | 60 days | 90 days |
| S3 Replication | No | No | Yes |
| **Security** |
| KMS Key Rotation | 365 days | 365 days | 90 days |
| IAM Role Review | 90 days | 60 days | 30 days |
| CloudWatch Retention | 30 days | 90 days | 365 days |
| Backup Frequency | Daily | 12 hours | 6 hours |

## 📁 Project Structure

```
terraform-katherine/
├── account.hcl                # Account-level configurations
├── env.hcl                    # Environment variables
├── region.hcl                 # Region-specific settings
├── terragrunt.hcl            # Root Terragrunt configuration
└── eu-west-2/                # Resources for eu-west-2 region
    ├── root.hcl              # Region-specific root configuration
    ├── _envcommon/           # Common environment configurations
    ├── network/              # Network resources
    │   ├── vpc/             # VPC configurations
    │   │   └── terragrunt.hcl
    │   └── security_groups/ # Security group configurations
    │       └── terragrunt.hcl
    ├── database/            # Database resources
    │   └── rds/            # RDS configurations
    │       └── terragrunt.hcl
    ├── compute/            # Compute resources
    │   └── ec2/           # EC2 configurations
    │       └── terragrunt.hcl
    └── storage/           # Storage resources
        └── s3/           # S3 configurations
            └── terragrunt.hcl
```

## Prerequisites

- Terraform v1.13.0
- Terragrunt v0.84.0
- AWS CLI configured with appropriate credentials
- AWS Account ID exported as environment variable

## Version Requirements

- Terraform: 1.13.0
- AWS Provider: 6.2.0
- Terragrunt: 0.84.0

## Quick Start

1. **Set up AWS credentials:**
   ```powershell
   aws configure
   ```

2. **Export your AWS Account ID:**
   ```powershell
   $env:TF_VAR_aws_account_id="your-account-id"
   ```

3. **Deploy the infrastructure:**
   ```powershell
   # Deploy VPC first
   cd eu-west-2/network/vpc
   terragrunt init
   terragrunt plan
   terragrunt apply

   # Deploy security groups
   cd ../security_groups
   terragrunt init && terragrunt apply

   # Continue with other components in order:
   # - database/rds
   # - compute/ec2
   # - storage/s3
   ```

## Infrastructure Components

### Network Layer
- **VPC Module**
  - CIDR: 10.0.0.0/16
  - 3 Availability Zones
  - Public, Private, and Database subnets
  - NAT Gateway (single in dev, multi in prod)
  - VPC Flow Logs enabled

### Security
- **Security Groups**
  - Least privilege access controls
  - Inbound rules for HTTPS and application traffic
  - Outbound rules restricted to necessary services

### Database
- **RDS PostgreSQL**
  - Encrypted storage
  - Multi-AZ in production
  - Automated backups
  - Enhanced monitoring
  - Performance insights enabled

### Compute
- **EC2 Instances**
  - Amazon Linux 2023
  - Encrypted EBS volumes
  - CloudWatch monitoring
  - SSM access
  - IAM roles with least privilege

### Storage
- **S3 Buckets**
  - Server-side encryption (KMS)
  - Versioning enabled
  - Lifecycle policies
  - Public access blocked
  - Object locking for compliance

## Security Features

- Encryption at rest for all data
- TLS for data in transit
- VPC Flow Logs for network monitoring
- IAM roles with least privilege
- Security groups with minimal access
- CloudWatch monitoring and alerts
- AWS Systems Manager for secure access

## Compliance

This infrastructure implements controls for:
- SOC2 compliance
- PCI-DSS requirements
- Data protection regulations

## Cost Optimization

- Resource tagging for cost allocation
- Lifecycle policies for S3
- Right-sized instances
- Auto-scaling capabilities
- Multi-AZ only in production

## Monitoring and Observability

- CloudWatch metrics and alarms
- VPC Flow Logs
- RDS Enhanced Monitoring
- Performance Insights
- AWS Systems Manager integration

## Best Practices

- Infrastructure as Code using Terragrunt
- Remote state with encryption
- State locking via DynamoDB
- Modular design
- Clear dependency management
- Comprehensive tagging strategy
- Security by default

## Testing

```bash
cd test
go test -v ./...
```
```

## Contributing

1. Create a feature branch
2. Make your changes
3. Test your changes
4. Submit a pull request

## License

MIT

## Author

Catherine Vee (catherinevee)