locals {
  environment = "dev"

  # Environment-specific configuration
  env_config = {
    instance_type = "t3.micro"
    multi_az = false
    backup_retention = 7
    enable_enhanced_monitoring = true
    
    tags = {
      Environment = local.environment
      Terraform   = "true"
      CostCenter  = "DevOps"
    }
  }
}
