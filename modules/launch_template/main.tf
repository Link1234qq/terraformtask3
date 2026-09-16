locals {
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
  name                 = var.name_prefix
  path                 = "/ec2/"
  description          = "IAM role for ${var.name_prefix}"
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

  tags = {
    Name = var.name_prefix
  }
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = var.name_prefix
  path = "/ec2/"
  role = aws_iam_role.ec2.name

  tags = {
    Name = var.name_prefix
  }
}

resource "aws_launch_template" "this" {
  name_prefix   = "${var.name_prefix}-"
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
    tags = {
      Name = var.name_prefix
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = var.name_prefix
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = var.name_prefix
  }
}
