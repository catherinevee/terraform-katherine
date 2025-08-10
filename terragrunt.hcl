/**
 * Root Terragrunt configuration
 * Handles provider generation, remote state, and common settings for all environments
 * Automatically detects environment from directory path structure
 */

locals {
  # Read account and region configs from parent directories
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract commonly used variables
  account_name = local.account_vars.locals.account_name
  account_id   = local.account_vars.locals.aws_account_id
  aws_region   = local.region_vars.locals.aws_region
  
  # Parse environment from directory path (e.g., eu-west-2/dev/network/vpc -> dev)
  environment = path_relative_to_include() =~ ".*/(dev|staging|prod)/.*" ? regex(".*/(dev|staging|prod)/.*", path_relative_to_include())[0] : "dev"

  # Tags applied to all resources for cost tracking and management
  common_tags = {
    Environment = local.environment
    ManagedBy   = "Terragrunt"
    Owner       = "DevOps"
    Terraform   = "true"
  }
}

# Generate AWS provider configuration with conditional role assumption
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
  
  # Use IAM role for non-dev environments (production security requirement)
  %{ if local.account_name != "dev" }
  assume_role {
    role_arn = "arn:aws:iam::${local.account_id}:role/terragrunt"
  }
  %{ endif }
  
  default_tags {
    tags = ${jsonencode(local.common_tags)}
  }
}
EOF
}

# S3 backend configuration with encryption and locking
remote_state {
  backend = "s3"
  config = {
    encrypt         = true
    bucket         = "terraform-${local.account_name}-${local.aws_region}-tfstate"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = "terraform-${local.account_name}-${local.aws_region}-locks"

    # Customer-managed KMS key for state file encryption
    kms_key_id     = "alias/terraform-${local.account_name}"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Global terraform settings and hooks
terraform {
  # Retry lock acquisition for up to 20 minutes when state is locked
  extra_arguments "retry_lock" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=20m"]
  }

  # Auto-format code before apply/plan for consistency
  before_hook "before_hook" {
    commands = ["apply", "plan"]
    execute  = ["terraform", "fmt"]
  }

  # Increase parallelism for faster applies (default is 10)
  extra_arguments "parallelism" {
    commands  = get_terraform_commands_that_need_parallelism()
    arguments = ["-parallelism=10"]
  }
}
