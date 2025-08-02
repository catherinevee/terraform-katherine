output "instance_id" {
  description = "ID of the EC2 instance"
  value       = try(aws_instance.this[0].id, null)
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = try(aws_instance.this[0].private_ip, null)
}

output "security_group_id" {
  description = "ID of the security group"
  value       = try(aws_security_group.this[0].id, null)
}
