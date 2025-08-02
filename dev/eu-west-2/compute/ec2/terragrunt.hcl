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
    private_subnets = ["subnet-mock-1", "subnet-mock-2"]
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
  source = "tfr://terraform-aws-modules/ec2-instance/aws?version=5.2.0"
}

inputs = {
  name = "${local.common_vars.locals.name_prefix}-app"

  ami                    = "ami-0e5f882be1900e43b"  # Amazon Linux 2023
  instance_type         = "t3.micro"
  monitoring            = true
  vpc_security_group_ids = [dependency.security_group.outputs.security_group_id]
  subnet_id             = dependency.vpc.outputs.private_subnets[0]

  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      volume_size = 20
    }
  ]

  # Enable detailed monitoring
  create_cloudwatch_metric_alarm = true
  alarm_actions = ["arn:aws:sns:${local.common_vars.locals.aws_region}:${local.common_vars.locals.aws_account_id}:alerts"]

  # IAM role and instance profile
  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  # User data script
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y amazon-cloudwatch-agent
              /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c ssm:/AmazonCloudWatch-Config
              EOF

  tags = merge(
    local.common_vars.locals.common_tags,
    {
      Name = "${local.common_vars.locals.name_prefix}-app"
      Type = "Compute"
    }
  )
}
