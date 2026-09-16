data "aws_caller_identity" "current" {}

locals {
  account_id  = data.aws_caller_identity.current.account_id
  name_prefix = "${var.app_name}-${var.environment}"

  vpc_id     = var.vpc_id != null ? var.vpc_id : module.vpc[0].vpc_id
  subnet_ids = length(var.subnet_ids) > 0 ? var.subnet_ids : module.vpc[0].public_subnets
}

module "vpc" {
  count  = var.vpc_id == null ? 1 : 0
  source = "terraform-aws-modules/vpc/aws"

  name = local.name_prefix
  cidr = var.vpc_cidr_block

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  manage_default_network_acl    = false
  manage_default_security_group = false
  manage_default_route_table    = false
  map_public_ip_on_launch       = true
}

module "launch_template" {
  source = "./modules/launch_template"

  name_prefix        = local.name_prefix
  app_name           = var.app_name
  key_name           = var.key_pair_name
  account_id         = local.account_id
  security_group_ids = [aws_security_group.asg.id]
  instance_type      = var.asg_instance_type

  depends_on = [aws_security_group_rule.all_egress]
}

module "autoscaling_group" {
  source = "./modules/autoscaling_group"

  name_prefix             = local.name_prefix
  subnet_ids              = local.subnet_ids
  launch_template_id      = module.launch_template.launch_template_id
  launch_template_version = module.launch_template.launch_template_latest_version
  min_size                = var.asg_min_size
  max_size                = var.asg_max_size
  desired_capacity        = var.asg_desired_capacity
  health_check_type       = "EC2"
  scaling_mode            = var.asg_scaling_mode

  depends_on = [module.launch_template]
}

data "aws_instances" "asg" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [module.autoscaling_group.autoscaling_group_name]
  }

  instance_state_names = ["pending", "running"]

  depends_on = [module.autoscaling_group]
}
