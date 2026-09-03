variable "name_prefix" {
  type        = string
  description = "Resource name prefix (app_name-environment)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the ASG security group is created"
}

variable "allowed_cidr" {
  type        = string
  description = "CIDR allowed for SSH and HTTP ingress (e.g. your public IP/32)"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the security group"
  default     = {}
}
