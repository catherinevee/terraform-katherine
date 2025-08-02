variable "instance_config" {
  description = "Configuration for EC2 instances"
  type = object({
    instance_type = string
    disk_size     = number
    monitoring    = bool
  })
  
  validation {
    condition = can(regex("^(t3|m5|c5)", var.instance_config.instance_type))
    error_message = "Instance type must be from approved families (t3, m5, c5)."
  }
  
  validation {
    condition = var.instance_config.disk_size >= 20 && var.instance_config.disk_size <= 1000
    error_message = "Disk size must be between 20 and 1000 GB."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}}
