# AWS Infrastructure with Terragrunt

This repository contains Infrastructure as Code (IaC) using Terragrunt for managing AWS resources following enterprise-grade best practices, including SOC2 and PCI-DSS compliance requirements.

## Infrastructure Overview

The infrastructure is organized by region and component type, following a modular approach:

```
eu-west-2/
├── _envcommon/          # Common environment configurations
├── network/
│   ├── vpc/            # VPC with public, private, and database subnets
│   └── security_groups/ # Security groups with least privilege access
├── compute/
│   └── ec2/           # EC2 instances with monitoring and security
├── database/
│   └── rds/           # RDS PostgreSQL with encryption and HA
├── storage/
│   └── s3/            # S3 buckets with versioning and encryption
└── root.hcl           # Root configuration and common settings
```

## Prerequisites

- Terraform v1.13.0
- Terragrunt (latest version)
- AWS CLI configured with appropriate credentials
- AWS Account ID exported as environment variable

## Version Requirements

- Terraform: 1.13.0
- AWS Provider: 6.2.0
- Terragrunt: Latest version

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

## Folder Structure

```
terraform-katherine/
├── README.md
└── eu-west-2/
    ├── root.hcl
    ├── _envcommon/
    ├── network/
    │   ├── vpc/
    │   │   └── terragrunt.hcl
    │   └── security_groups/
    │       └── terragrunt.hcl
    ├── database/
    │   └── rds/
    │       └── terragrunt.hcl
    ├── compute/
    │   └── ec2/
    │       └── terragrunt.hcl
    └── storage/
        └── s3/
            └── terragrunt.hcl
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