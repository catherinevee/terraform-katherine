/**
 * Terraform and provider version constraints for EC2 module
 * Using specific versions to ensure consistent behavior across environments
 */

terraform {
  required_version = ">= 1.13.0"  # Minimum version for reliable state handling

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.2.0"        # AWS provider 6.2.x for latest resource support
    }
  }
}
