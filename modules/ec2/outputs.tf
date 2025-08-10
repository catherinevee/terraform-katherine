/**
 * EC2 module outputs
 * Returns null when instance is disabled via locals.enabled flag
 */

output "instance_id" {
  description = "EC2 instance ID for use in other resources or monitoring"
  value       = try(aws_instance.this[0].id, null)
}

output "instance_private_ip" {
  description = "Private IP address for internal service communication"
  value       = try(aws_instance.this[0].private_ip, null)
}

output "security_group_id" {
  description = "Security group ID for attaching to other resources"
  value       = try(aws_security_group.this[0].id, null)
}
