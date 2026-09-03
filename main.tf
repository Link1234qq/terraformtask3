data "aws_caller_identity" "current" {}

locals {
  account_id  = data.aws_caller_identity.current.account_id
  name_prefix = "${var.app_name}-${var.environment}"

  common_tags = {
    Environment = var.environment
    ManagedBy   = var.managed_by
    Project     = var.app_name
  }

  vpc_id     = var.vpc_id != null ? var.vpc_id : module.network[0].vpc_id
  subnet_ids = length(var.subnet_ids) > 0 ? var.subnet_ids : module.network[0].public_subnets
}

module "network" {
  count  = var.vpc_id == null ? 1 : 0
  source = "./modules/vpc"

  app_name        = var.app_name
  environment     = var.environment
  vpc_cidr_block  = var.vpc_cidr_block
  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "security" {
  source = "./modules/security"

  name_prefix  = local.name_prefix
  vpc_id       = local.vpc_id
  allowed_cidr = var.allowed_cidr
  tags         = local.common_tags
}

module "launch_template" {
  source = "./modules/launch_template"

  name_prefix        = local.name_prefix
  app_name           = var.app_name
  key_name           = var.key_pair_name
  account_id         = local.account_id
  security_group_ids = [module.security.asg_security_group_id]
  instance_type      = var.asg_instance_type
  tags               = local.common_tags

  depends_on = [module.security]
}

module "autoscaling_group" {
  source = "./modules/autoscalling_group"

  name_prefix             = local.name_prefix
  subnet_ids              = local.subnet_ids
  launch_template_id      = module.launch_template.launch_template_id
  launch_template_version = module.launch_template.launch_template_latest_version
  min_size                = var.asg_min_size
  max_size                = var.asg_max_size
  desired_capacity        = var.asg_desired_capacity
  health_check_type       = "EC2"
  tags                    = local.common_tags
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
