include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  # Load common variables
  common_vars = read_terragrunt_config(find_in_parent_folders("root.hcl"))
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = "vpc-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

terraform {
  source = "tfr://terraform-aws-modules/security-group/aws?version=5.1.0"
}

inputs = {
  name        = "${local.common_vars.locals.name_prefix}-app-sg"
  description = "Security group for application servers"
  vpc_id      = dependency.vpc.outputs.vpc_id

  # Example rules - customize based on your needs
  ingress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow HTTPS from anywhere"
    },
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = dependency.vpc.outputs.vpc_cidr_block
      description = "Allow internal application traffic"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
      description = "Allow all outbound traffic"
    }
  ]

  tags = merge(
    local.common_vars.locals.common_tags,
    {
      Name = "${local.common_vars.locals.name_prefix}-app-sg"
      Type = "Security"
    }
  )
}
