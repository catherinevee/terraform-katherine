locals {
  # AWS Account configurations
  aws_account_id = get_env("TF_VAR_aws_account_id", "")
  aws_region     = "eu-west-2"
  environment    = "dev"  # Can be overridden in child terragrunt.hcl files

  # Resource naming
  name_prefix    = "${local.environment}-${local.aws_region}"
  
  # Common tags
  common_tags = {
    Environment     = local.environment
    ManagedBy      = "Terragrunt"
    Owner          = "DevOps"
    CostCenter     = "Engineering"
    BusinessUnit   = "Technology"
    DataClass      = "Internal"
  }
}

# Remote state configuration
remote_state {
  backend = "s3"
  config = {
    bucket         = "terraform-katherine-state-${local.aws_account_id}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.aws_region
    encrypt        = true
    dynamodb_table = "terraform-katherine-locks"
    
    tags = merge(local.common_tags, {
      Name = "Terraform State"
    })
  }
  
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# AWS Provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = "= 1.13.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.2.0"
    }
  }
}

provider "aws" {
  region = "${local.aws_region}"
  
  default_tags {
    tags = ${jsonencode(local.common_tags)}
  }
}
EOF
}

# Ensure resources are always created sequentially
terraform {
  extra_arguments "retry_lock" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=20m"]
  }

  extra_arguments "parallelism" {
    commands  = get_terraform_commands_that_need_parallelism()
    arguments = ["-parallelism=10"]
  }
}
