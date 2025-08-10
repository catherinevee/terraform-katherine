/**
 * Development environment configuration for eu-west-2
 * Cost-optimized settings: single AZ, smaller instances, reduced backup retention
 */

locals {
  environment = "dev"
  
  # Development-specific settings optimized for cost over availability
  env_config = {
    instance_type = "t3.micro"         # Smallest instance for cost savings
    multi_az = false                   # Single AZ reduces RDS costs by 50%
    backup_retention = 7               # Minimum retention for dev environment
    enable_enhanced_monitoring = true  # Keep monitoring for development debugging
  }
}

terraform {
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()

    required_var_files = [
      "${get_parent_terragrunt_dir()}/env.tfvars"
    ]
  }
}
