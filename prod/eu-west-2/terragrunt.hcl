locals {
  environment = "dev"
  
  # Environment-specific variables
  env_config = {
    instance_type = "t3.micro"
    multi_az = false
    backup_retention = 7
    enable_enhanced_monitoring = true
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
