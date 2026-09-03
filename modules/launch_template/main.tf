locals {
  name                     = "${var.name_prefix}-lt"
  iam_name                 = "${var.name_prefix}-ec2"
  permissions_boundary_arn = "arn:aws:iam::${var.account_id}:policy/eo_role_boundary"
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_iam_role" "ec2" {
  name                 = local.iam_name
  path                 = "/ec2/"
  description          = "IAM role for ${local.iam_name}"
  permissions_boundary = local.permissions_boundary_arn

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = merge(var.tags, { Name = local.iam_name })
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = local.iam_name
  path = "/ec2/"
  role = aws_iam_role.ec2.name

  tags = merge(var.tags, { Name = local.iam_name })
}

resource "aws_launch_template" "this" {
  name_prefix   = "${local.name}-"
  description   = "Launch template for ${var.name_prefix}"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = var.security_group_ids

  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2.arn
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tftpl", {
    app_name = var.app_name
  }))

  update_default_version = true

  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, { Name = local.name })
  }

  tag_specifications {
    resource_type = "volume"
    tags          = merge(var.tags, { Name = local.name })
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, { Name = local.name })
}
