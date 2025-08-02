locals {
  enabled = true
}

resource "aws_instance" "this" {
  count = local.enabled ? 1 : 0

  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_config.instance_type
  subnet_id     = var.subnet_ids[0]
  
  vpc_security_group_ids = [aws_security_group.this[0].id]
  monitoring            = var.instance_config.monitoring

  root_block_device {
    volume_size = var.instance_config.disk_size
    encrypted   = true
  }

  metadata_options {
    http_tokens = "required"  # IMDSv2
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-instance"
      Environment = var.environment
    }
  )
}

resource "aws_security_group" "this" {
  count = local.enabled ? 1 : 0

  name_prefix = "${var.environment}-ec2-sg"
  vpc_id      = var.vpc_id
  
  # Implement least privilege access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-ec2-sg"
      Environment = var.environment
    }
  )
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
