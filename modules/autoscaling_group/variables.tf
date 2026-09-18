variable "name_prefix" {
  type        = string
  description = "Prefix for Auto Scaling Group resource names"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for ASG instances (use multiple AZs for high availability)"

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "Provide at least 2 subnet IDs in different AZs for multi-AZ ASG."
  }
}

variable "launch_template_id" {
  type        = string
  description = "Launch template ID from the launch_template module"
}

variable "launch_template_version" {
  type        = string
  description = "Launch template version to use"
  default     = "$Latest"
}

variable "min_size" {
  type        = number
  description = "Minimum number of instances"
  default     = 1
}

variable "max_size" {
  type        = number
  description = "Maximum number of instances"
  default     = 4
}

variable "desired_capacity" {
  type        = number
  description = "Desired number of instances"
  default     = 2
}

variable "health_check_type" {
  type        = string
  description = "EC2 for instances without a load balancer; ELB when using a target group"
  default     = "EC2"
}

variable "health_check_grace_period" {
  type        = number
  description = "Seconds to wait before running health checks on new instances"
  default     = 300
}

variable "target_group_arn" {
  type        = string
  description = "Optional ALB target group ARN (required when health_check_type is ELB)"
  default     = null
}

variable "scaling_mode" {
  type        = string
  description = "cloudwatch_alarms (70%/30% thresholds) or target_tracking (ASG-managed; use when PutMetricAlarm is denied)"
  default     = "target_tracking"

  validation {
    condition     = contains(["cloudwatch_alarms", "target_tracking"], var.scaling_mode)
    error_message = "scaling_mode must be cloudwatch_alarms or target_tracking."
  }
}
