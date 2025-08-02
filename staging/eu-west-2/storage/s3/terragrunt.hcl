include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  # Load common variables
  common_vars = read_terragrunt_config(find_in_parent_folders("root.hcl"))
}

terraform {
  source = "tfr://terraform-aws-modules/s3-bucket/aws?version=3.14.0"
}

inputs = {
  bucket = "${local.common_vars.locals.name_prefix}-app-storage"
  
  # Versioning
  versioning = {
    enabled = true
  }

  # Server-side encryption
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "aws:kms"
        kms_master_key_id = "alias/aws/s3"
      }
    }
  }

  # Public access blocking
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # Lifecycle rules
  lifecycle_rule = [
    {
      id      = "log"
      enabled = true

      transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]

      expiration = {
        days = 365
      }
    }
  ]

  # Access logging
  logging = {
    target_bucket = "${local.common_vars.locals.name_prefix}-logs"
    target_prefix = "s3-logs/"
  }

  # Object locking
  object_lock_enabled = true
  object_lock_configuration = {
    rule = {
      default_retention = {
        mode = "COMPLIANCE"
        days = 5
      }
    }
  }

  tags = merge(
    local.common_vars.locals.common_tags,
    {
      Name = "${local.common_vars.locals.name_prefix}-app-storage"
      Type = "Storage"
    }
  )
}
