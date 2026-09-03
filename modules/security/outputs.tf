output "asg_security_group_id" {
  value       = aws_security_group.asg.id
  description = "Security group ID for ASG instances"
}
