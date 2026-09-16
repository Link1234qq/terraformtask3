output "autoscaling_group_name" {
  value       = aws_autoscaling_group.this.name
  description = "Name of the Auto Scaling Group"
}

output "autoscaling_group_arn" {
  value       = aws_autoscaling_group.this.arn
  description = "ARN of the Auto Scaling Group"
}
