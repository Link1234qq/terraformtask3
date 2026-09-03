locals {
  name = "${var.name_prefix}-asg"
}

resource "aws_autoscaling_group" "this" {
  name                = local.name
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = var.target_group_arn != null ? [var.target_group_arn] : []

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period

  launch_template {
    id      = var.launch_template_id
    version = var.launch_template_version
  }

  tag {
    key                 = "Name"
    value               = local.name
    propagate_at_launch = false
  }

  tag {
    key                 = "Name"
    value               = "${local.name}-instance"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags

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

resource "aws_autoscaling_policy" "scale_out" {
  count = var.scaling_mode == "cloudwatch_alarms" ? 1 : 0

  name                   = "${local.name}-scale-out"
  autoscaling_group_name = aws_autoscaling_group.this.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
  policy_type            = "SimpleScaling"
}

resource "aws_autoscaling_policy" "scale_in" {
  count = var.scaling_mode == "cloudwatch_alarms" ? 1 : 0

  name                   = "${local.name}-scale-in"
  autoscaling_group_name = aws_autoscaling_group.this.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
  policy_type            = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count = var.scaling_mode == "cloudwatch_alarms" ? 1 : 0

  alarm_name          = "${local.name}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  treat_missing_data  = "notBreaching"
  alarm_description   = "Scale out when average CPU exceeds 70% for 5 minutes"
  alarm_actions       = [aws_autoscaling_policy.scale_out[0].arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }

  tags = merge(var.tags, {
    Name = "${local.name}-cpu-high"
  })
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  count = var.scaling_mode == "cloudwatch_alarms" ? 1 : 0

  alarm_name          = "${local.name}-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 30
  treat_missing_data  = "notBreaching"
  alarm_description   = "Scale in when average CPU is below 30% for 5 minutes"
  alarm_actions       = [aws_autoscaling_policy.scale_in[0].arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }

  tags = merge(var.tags, {
    Name = "${local.name}-cpu-low"
  })
}

resource "aws_autoscaling_policy" "cpu_target_tracking" {
  count = var.scaling_mode == "target_tracking" ? 1 : 0

  name                   = "${local.name}-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.this.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value     = 50.0
    disable_scale_in = false
  }
}
