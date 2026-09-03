output "launch_template_id" {
  value       = aws_launch_template.this.id
  description = "ID of the launch template"
}

output "launch_template_latest_version" {
  value       = aws_launch_template.this.latest_version
  description = "Latest version of the launch template"
}

output "iam_role_arn" {
  value       = aws_iam_role.ec2.arn
  description = "ARN of the IAM role attached to instances"
}
