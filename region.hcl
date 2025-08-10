/**
 * Region-specific configuration
 * Primary region settings for EU data residency requirements
 */

locals {
  aws_region = "eu-west-2"  # London region for GDPR compliance

  # Regional network and availability zone settings
  region_config = {
    eu-west-2 = {
      primary = true                                         # Primary region flag
      azs = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]     # All available AZs
      vpc_cidr = "10.0.0.0/16"                              # Non-overlapping CIDR for peering
    }
  }
}
