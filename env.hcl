/**
 * Environment-specific configuration template
 * Base settings inherited by all resources in this environment
 */

locals {
  environment = "dev"  # Override in each environment directory

  # Environment defaults - customize per deployment stage
  env_config = {
    instance_type = "t3.micro"             # Cost-effective for development workloads
    multi_az = false                       # Single AZ saves ~50% on RDS costs
    backup_retention = 7                   # Minimum viable retention period
    enable_enhanced_monitoring = true      # Always enabled for debugging support
    
    tags = {
      Environment = local.environment
      Terraform   = "true"
    }
  }
}
