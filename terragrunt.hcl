locals {
  # Read the account and region configuration
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract commonly used variables
  account_name = local.account_vars.locals.account_name
  account_id   = local.account_vars.locals.aws_account_id
  aws_region   = local.region_vars.locals.aws_region
  
  # Get environment from path
  environment = path_relative_to_include() =~ ".*/(dev|staging|prod)/.*" ? regex(".*/(dev|staging|prod)/.*", path_relative_to_include())[0] : "dev"

  # Common tags
  common_tags = {
    Environment = local.environment
    ManagedBy   = "Terragrunt"
    Owner       = "DevOps"
    Terraform   = "true"
  }
}

# Generate provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
  
  # Only use assume_role for non-dev accounts
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

# Configure Terragrunt to automatically store tfstate files in S3
remote_state {
  backend = "s3"
  config = {
    encrypt         = true
    bucket         = "terraform-${local.account_name}-${local.aws_region}-tfstate"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    dynamodb_table = "terraform-${local.account_name}-${local.aws_region}-locks"

    # Enable server-side encryption
    kms_key_id     = "alias/terraform-${local.account_name}"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Global terraform block for common settings
terraform {
  # Force Terraform to keep trying to acquire a lock for
  # up to 20 minutes if someone else has the lock
  extra_arguments "retry_lock" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=20m"]
  }

  # Ensure proper formatting and validation
  before_hook "before_hook" {
    commands = ["apply", "plan"]
    execute  = ["terraform", "fmt"]
  }

  # Configure parallelism for better performance
  extra_arguments "parallelism" {
    commands  = get_terraform_commands_that_need_parallelism()
    arguments = ["-parallelism=10"]
  }
}
