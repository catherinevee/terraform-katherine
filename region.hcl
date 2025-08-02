locals {
  aws_region = "eu-west-2"

  # Region-specific variables
  region_config = {
    eu-west-2 = {
      primary = true
      azs = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
      vpc_cidr = "10.0.0.0/16"
    }
  }
}
