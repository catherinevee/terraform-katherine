include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  # Load common variables
  common_vars = read_terragrunt_config(find_in_parent_folders("root.hcl"))
}

dependency "vpc" {
  config_path = "../../network/vpc"
  mock_outputs = {
    vpc_id = "vpc-mock"
    database_subnet_group_name = "subnet-group-mock"
    vpc_cidr_block = "10.0.0.0/16"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "security_group" {
  config_path = "../../network/security_groups"
  mock_outputs = {
    security_group_id = "sg-mock"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

terraform {
  source = "tfr://terraform-aws-modules/rds/aws?version=6.1.0"
}

inputs = {
  identifier = "${local.common_vars.locals.name_prefix}-db"

  engine               = "postgres"
  engine_version      = "14"
  instance_class      = "db.t3.medium"
  allocated_storage   = 20
  storage_encrypted   = true

  db_name  = "appdb"
  username = "dbadmin"
  port     = 5432

  multi_az               = local.common_vars.locals.environment == "prod"
  db_subnet_group_name   = dependency.vpc.outputs.database_subnet_group_name
  vpc_security_group_ids = [dependency.security_group.outputs.security_group_id]

  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window          = "03:00-06:00"
  backup_retention_period = local.common_vars.locals.environment == "prod" ? 30 : 7

  # Enhanced monitoring
  monitoring_interval = 30
  monitoring_role_name = "${local.common_vars.locals.name_prefix}-rds-monitoring-role"
  create_monitoring_role = true

  # Performance insights
  performance_insights_enabled = true
  performance_insights_retention_period = 7

  # Database deletion protection
  deletion_protection = local.common_vars.locals.environment == "prod"

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]

  tags = merge(
    local.common_vars.locals.common_tags,
    {
      Name = "${local.common_vars.locals.name_prefix}-db"
      Type = "Database"
    }
  )
}
