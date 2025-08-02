locals {
  account_name = "dev"  # Can be "dev", "staging", or "prod"
  aws_account_id = get_env("TF_VAR_AWS_ACCOUNT_ID", "")
  
  # Account-specific variables
  account_config = {
    dev = {
      allowed_regions = ["eu-west-2"]
      enable_guard_duty = true
    }
    staging = {
      allowed_regions = ["eu-west-2"]
      enable_guard_duty = true
    }
    prod = {
      allowed_regions = ["eu-west-2", "eu-west-1"]  # Prod can use multiple regions
      enable_guard_duty = true
    }
  }
}
