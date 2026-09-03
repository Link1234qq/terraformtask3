variable "aws_region" {
  type        = string
  description = "AWS region where resources are deployed"
}

variable "key_pair_name" {
  type        = string
  description = "EC2 key pair name for SSH access"
}

variable "vpc_id" {
  type        = string
  description = "Optional existing VPC ID; leave null to create VPC via modules/vpc"
  default     = null
}

variable "subnet_ids" {
  type        = list(string)
  description = "Optional existing subnet IDs for ASG; leave empty to use public subnets from created VPC"
  default     = []
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC (used when vpc_id is null)"
}

variable "azs" {
  type        = list(string)
  description = "Availability zones for VPC subnets (used when vpc_id is null)"

  validation {
    condition = alltrue([
      for az in var.azs : contains([
        "us-east-1a",
        "us-east-1b",
        "us-east-1c",
        "us-east-1d",
        "us-east-1e",
        "us-east-1f"
      ], az)
    ])
    error_message = "Supported AZs are us-east-1a through us-east-1f."
  }
}

variable "public_subnets" {
  type        = list(string)
  description = "CIDR blocks for public subnets (used when vpc_id is null)"
}

variable "private_subnets" {
  type        = list(string)
  description = "CIDR blocks for private subnets (used when vpc_id is null)"
}

variable "allowed_cidr" {
  type        = string
  description = "CIDR allowed for SSH and HTTP ingress (your public IP/32)"
}

variable "app_name" {
  type        = string
  description = "Application name used in resource naming and tags"
}

variable "environment" {
  type        = string
  description = "Deployment environment (e.g. dev, prod)"
}

variable "managed_by" {
  type        = string
  description = "Owner or team responsible for resources"
}

variable "asg_min_size" {
  type        = number
  description = "Minimum number of instances in the Auto Scaling Group"
  default     = 1
}

variable "asg_max_size" {
  type        = number
  description = "Maximum number of instances in the Auto Scaling Group"
  default     = 4
}

variable "asg_desired_capacity" {
  type        = number
  description = "Desired number of instances in the Auto Scaling Group"
  default     = 2
}

variable "asg_instance_type" {
  type        = string
  description = "EC2 instance type for ASG instances"
  default     = "t3.micro"
}

variable "asg_scaling_mode" {
  type        = string
  description = "cloudwatch_alarms for 70%/30% CPU alarms, or target_tracking if CloudWatch PutMetricAlarm is denied"
  default     = "target_tracking"

  validation {
    condition     = contains(["cloudwatch_alarms", "target_tracking"], var.asg_scaling_mode)
    error_message = "asg_scaling_mode must be cloudwatch_alarms or target_tracking."
  }
}
