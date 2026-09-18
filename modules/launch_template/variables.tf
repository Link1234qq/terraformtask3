variable "name_prefix" {
  type        = string
  description = "Prefix for launch template resource names"
}

variable "account_id" {
  type        = string
  description = "AWS account ID used to build the IAM permissions boundary ARN"
}

variable "app_name" {
  type        = string
  description = "Application name used in nginx welcome page"
}

variable "key_name" {
  type        = string
  description = "EC2 key pair name for SSH access"
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security group IDs attached to instances"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}
