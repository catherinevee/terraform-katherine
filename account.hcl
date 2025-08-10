/**
 * Account-level configuration
 * Define account-specific settings and security controls per environment
 */

locals {
  account_name = "dev"  # Update based on deployment target
  aws_account_id = get_env("TF_VAR_AWS_ACCOUNT_ID", "")
  
  # Per-environment security and regional restrictions
  account_config = {
    dev = {
      allowed_regions = ["eu-west-2"]                      # Single region for cost control
      enable_guard_duty = true                             # Security monitoring in all envs
    }
    staging = {
      allowed_regions = ["eu-west-2"]                      # Match production region
      enable_guard_duty = true
    }
    prod = {
      allowed_regions = ["eu-west-2", "eu-west-1"]         # Multi-region for DR
      enable_guard_duty = true
    }
  }
}
