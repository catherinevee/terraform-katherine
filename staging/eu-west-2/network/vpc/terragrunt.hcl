include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

locals {
  # Load configurations
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  env_vars     = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  
  # Extract commonly used variables
  environment = local.env_vars.locals.environment
  region     = local.region_vars.locals.aws_region
  
  # VPC Configuration
  vpc_config = local.region_vars.locals.region_config[local.region]
}

terraform {
  source = "tfr://terraform-aws-modules/vpc/aws?version=5.1.0"
}

inputs = {
  name = "${local.environment}-vpc"
  cidr = local.vpc_config.vpc_cidr

  azs             = local.vpc_config.azs
  private_subnets = [for i, az in local.vpc_config.azs : cidrsubnet(local.vpc_config.vpc_cidr, 4, i)]
  public_subnets  = [for i, az in local.vpc_config.azs : cidrsubnet(local.vpc_config.vpc_cidr, 4, i + 3)]
  database_subnets = [for i, az in local.vpc_config.azs : cidrsubnet(local.vpc_config.vpc_cidr, 4, i + 6)]

  enable_nat_gateway = true
  single_nat_gateway = local.environment != "prod"  # Use multiple NAT gateways in prod
  enable_vpn_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  # Database subnet configuration
  create_database_subnet_group = true
  create_database_subnet_route_table = true

  # Flow logs for security and compliance
  enable_flow_log = true
  flow_log_destination_type = "cloud-watch-logs"
  flow_log_destination_arn = "arn:aws:logs:${local.region}:${local.account_vars.locals.aws_account_id}:log-group:/aws/vpc-flow-log/${local.environment}-vpc"

  # Tags
  tags = merge(
    local.env_vars.locals.env_config.tags,
    {
      Name = "${local.environment}-vpc"
      Type = "Network"
    }
  )
}
