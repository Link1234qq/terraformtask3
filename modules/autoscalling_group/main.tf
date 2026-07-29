locals {
  permissions_boundary_arn = "arn:aws:iam::${var.account_id}:policy/eo_role_boundary"
  name                     = "${var.name_prefix}-asg"
}

data "aws_region" "current" {}


resource "aws_iam_role" "asg" {
  name                 = local.name
  path                 = "/ec2/"
  description          = "IAM role for ${local.name}"
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
    Name = local.name
  }
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.asg.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "asg" {
  name = local.name
  path = "/ec2/"
  role = aws_iam_role.asg.name

  tags = {
    Name = local.name
  }
}

resource "aws_launch_template" "this" {
  name_prefix   = "${local.name}-"
  description   = "Launch template for ${local.name}"
  image_id      = data.aws_ami.this.id
  instance_type = var.instance_type

  vpc_security_group_ids = [var.asg_sg_id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.asg.arn
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tftpl", {
    app_name      = var.app_name
    docker_image  = var.docker_image
    db_url        = var.db_url
    db_secret_arn = var.db_secret_arn
    aws_region    = data.aws_region.current.id
  }))

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  monitoring {
    enabled = true
  }

  update_default_version = true

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = local.name
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = local.name
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = local.name
  }
}

resource "aws_autoscaling_group" "this" {
  name                      = local.name
  vpc_zone_identifier       = var.public_subnets
  target_group_arns         = [var.target_group_arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = local.name
    propagate_at_launch = false
  }

  dynamic "tag" {
    for_each = {
      Name = local.name
    }

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
