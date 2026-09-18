output "vpc_id" {
  value       = local.vpc_id
  description = "VPC ID used by ASG and security groups"
}

output "subnet_ids" {
  value       = local.subnet_ids
  description = "Subnet IDs used by the Auto Scaling Group"
}

output "asg_name" {
  value       = module.autoscaling_group.autoscaling_group_name
  description = "Name of the Auto Scaling Group"
}

output "instance_ids" {
  value       = data.aws_instances.asg.ids
  description = "EC2 instance IDs in the Auto Scaling Group"
}
