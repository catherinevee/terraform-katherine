include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  # Load common variables
  common_vars = read_terragrunt_config(find_in_parent_folders("root.hcl"))
}

terraform {
  source = "tfr://terraform-aws-modules/vpc/aws?version=5.1.0"
}

inputs = {
  name = "${local.common_vars.locals.name_prefix}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets = ["10.0.151.0/24", "10.0.152.0/24", "10.0.153.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = local.common_vars.locals.environment != "prod"  # Use multiple NAT gateways in prod
  enable_vpn_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  # Database subnet configuration
  create_database_subnet_group = true
  create_database_subnet_route_table = true

  # Flow logs for security and compliance
  enable_flow_log = true
  flow_log_destination_type = "cloud-watch-logs"
  flow_log_destination_arn = "arn:aws:logs:${local.common_vars.locals.aws_region}:${local.common_vars.locals.aws_account_id}:log-group:/aws/vpc-flow-log/${local.common_vars.locals.name_prefix}-vpc"

  # Tags
  tags = merge(
    local.common_vars.locals.common_tags,
    {
      Name = "${local.common_vars.locals.name_prefix}-vpc"
      Type = "Network"
    }
  )
}
