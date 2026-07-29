variable "name_prefix" {
  type        = string
  description = "Resource name prefix (app_name-environment), composed once in the root module"
}

variable "app_name" {
  type        = string
  description = "Application name for the Docker container (not the AWS resource name prefix)"
}

variable "asg_sg_id" {
  type        = string
  description = "Security group ID for EC2 instances launched by the Auto Scaling Group"
}

variable "public_subnets" {
  type        = list(string)
  description = "Subnet IDs where ASG instances are launched"
}

variable "target_group_arn" {
  type        = string
  description = "ARN of the ALB target group to register ASG instances with"
}

variable "docker_image" {
  type        = string
  description = "Docker image reference (registry/repo:tag) for the Petclinic container"
  default     = "sargeras147/petclinic:latest"
}

variable "db_url" {
  type        = string
  description = "Spring Boot JDBC URL for MySQL (e.g. jdbc:mysql://host:3306/dbname)"
}

variable "db_secret_arn" {
  type        = string
  description = "Secrets Manager ARN with RDS credentials (read at instance boot, not stored in Terraform state)"
}

variable "account_id" {
  type        = string
  description = "AWS account ID (from root module caller identity; used to build IAM permissions boundary ARN)"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for ASG instances"
  default     = "t2.micro"
}

variable "min_size" {
  type        = number
  description = "Minimum number of instances in the Auto Scaling Group"
  default     = 1
}

variable "max_size" {
  type        = number
  description = "Maximum number of instances in the Auto Scaling Group"
}

variable "desired_capacity" {
  type        = number
  description = "Desired number of instances in the Auto Scaling Group"
  default     = 1
}
