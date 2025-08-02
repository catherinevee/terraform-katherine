locals {
  environment_vars = {
    dev = {
      instance_type     = "t3.micro"
      multi_az         = false
      backup_retention = 7
      monitoring      = true
    }
    staging = {
      instance_type     = "t3.small"
      multi_az         = false
      backup_retention = 14
      monitoring      = true
    }
    prod = {
      instance_type     = "t3.medium"
      multi_az         = true
      backup_retention = 30
      monitoring      = true
    }
  }

  account_vars = {
    dev = {
      aws_account_id = get_env("TF_VAR_DEV_ACCOUNT_ID", "")
      aws_account_role = "arn:aws:iam::${get_env("TF_VAR_DEV_ACCOUNT_ID", "")}:role/terragrunt"
    }
    staging = {
      aws_account_id = get_env("TF_VAR_STAGING_ACCOUNT_ID", "")
      aws_account_role = "arn:aws:iam::${get_env("TF_VAR_STAGING_ACCOUNT_ID", "")}:role/terragrunt"
    }
    prod = {
      aws_account_id = get_env("TF_VAR_PROD_ACCOUNT_ID", "")
      aws_account_role = "arn:aws:iam::${get_env("TF_VAR_PROD_ACCOUNT_ID", "")}:role/terragrunt"
    }
  }
}
