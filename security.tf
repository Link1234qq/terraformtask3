resource "aws_security_group" "asg" {
  name        = local.name_prefix
  description = "Security group for ASG EC2 instances"
  vpc_id      = local.vpc_id

  tags = {
    Name = local.name_prefix
  }
}

resource "aws_security_group_rule" "ssh_ingress" {
  type              = "ingress"
  description       = "SSH from allowed IP"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.allowed_cidr]
  security_group_id = aws_security_group.asg.id
}

resource "aws_security_group_rule" "http_ingress" {
  type              = "ingress"
  description       = "HTTP from allowed IP"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.allowed_cidr]
  security_group_id = aws_security_group.asg.id
}

resource "aws_security_group_rule" "all_egress" {
  type              = "egress"
  description       = "Allow all outbound traffic"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.asg.id
}
