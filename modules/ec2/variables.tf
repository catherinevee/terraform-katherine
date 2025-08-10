variable "instance_config" {
  description = "EC2 instance configuration object"
  type = object({
    instance_type = string
    disk_size     = number
    monitoring    = bool
  })
  
  validation {
    condition = can(regex("^(t3|m5|c5)", var.instance_config.instance_type))
    error_message = "Only approved instance families allowed for cost control (t3, m5, c5)."
  }
  
  validation {
    condition = var.instance_config.disk_size >= 20 && var.instance_config.disk_size <= 1000
    error_message = "Disk size must be 20-1000 GB to prevent runaway storage costs."
  }
}

variable "environment" {
  description = "Environment name - affects resource naming"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "vpc_id" {
  description = "VPC ID where EC2 instance will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs - instance uses first subnet only"
  type        = list(string)
}

variable "tags" {
  description = "Additional tags for cost allocation and resource management"
  type        = map(string)
  default     = {}
}
