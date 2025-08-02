locals {
  environment = "staging"

  # Environment-specific configuration
  env_config = {
    instance_type = "t3.small"
    multi_az = false
    backup_retention = 14
    enable_enhanced_monitoring = true
    
    tags = {
      Environment = local.environment
      Terraform   = "true"
      CostCenter  = "DevOps"
    }
  }
}
