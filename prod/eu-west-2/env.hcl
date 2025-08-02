locals {
  environment = "prod"

  # Environment-specific configuration
  env_config = {
    instance_type = "t3.medium"
    multi_az = true
    backup_retention = 30
    enable_enhanced_monitoring = true
    
    tags = {
      Environment = local.environment
      Terraform   = "true"
      CostCenter  = "DevOps"
    }
  }
}
