#####################################
# Autoscaling Group
#####################################
resource "aws_launch_template" "ec2_launch_template" {
  name          = "${var.base_name}-ec2-launch-template"
  image_id      = var.ec2_settings["ami"]
  instance_type = var.ec2_settings["instance_type"]
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.ec2_sg.id]
    delete_on_termination       = true
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_iam_profile.name
  }
  credit_specification {
    cpu_credits = "unlimited"
  }
  ebs_optimized = true
  user_data     = base64encode(data.template_file.ec2_user_date.rendered)
  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-ec2" }))
  }

  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-ec2-launch-template" }))
}

resource "aws_placement_group" "ec2_placement_group" {
  name     = "${var.base_name}-ec2-placement-group"
  strategy = "cluster"
  tags     = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-ec2-placement-group" }))
}

resource "aws_autoscaling_group" "ec2_asg" {
  name            = "${var.base_name}-ec2-asg"
  max_size        = var.ec2_settings["asg_max_size"]
  min_size        = var.ec2_settings["asg_min_size"]
  placement_group = aws_placement_group.ec2_placement_group.id
  vpc_zone_identifier = [
    aws_subnet.protected_1a.id,
    aws_subnet.protected_1c.id
  ]
  launch_template {
    id      = aws_launch_template.ec2_launch_template.id
    version = "$Latest"
  }
  health_check_type = "ELB"
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [load_balancers, target_group_arns]
  }

  tags = [
    {
      "key"                 = "System"
      "value"               = var.system
      "propagate_at_launch" = true
    },
    {
      "key"                 = "Env"
      "value"               = var.env
      "propagate_at_launch" = true
    },
    {
      "key"                 = "Terraform"
      "value"               = "true"
      "propagate_at_launch" = true
    },
    {
      "key"                 = "Name"
      "value"               = "${var.base_name}-ec2-asg-v${aws_launch_template.ec2_launch_template.latest_version}"
      "propagate_at_launch" = true
    }
  ]
}

resource "aws_autoscaling_attachment" "ec2_asg_attach" {
  autoscaling_group_name = aws_autoscaling_group.ec2_asg.id
  alb_target_group_arn   = aws_lb_target_group.lb_tg.arn
}

#####################################
# User Data
#####################################
data "template_file" "ec2_user_date" {
  template = file("${path.module}/tpl/ec2_user_data.sh.tpl")
  vars = {
    env    = "${var.env}"
    system = "${var.system}"
  }
}

#####################################
# Security Group Settings
#####################################
resource "aws_security_group" "ec2_sg" {
  name   = "${var.base_name}-ec2-sg"
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-ec2-sg" }))
}

resource "aws_security_group_rule" "ec2_sg_egress_rule" {
  security_group_id = aws_security_group.ec2_sg.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ec2_sg_self_ingress_rule" {
  security_group_id = aws_security_group.ec2_sg.id

  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"
  self      = true
}

resource "aws_security_group_rule" "ec2_sg_ingress_rule" {
  security_group_id = aws_security_group.ec2_sg.id

  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lb_sg.id
}

#####################################
# Data: IAM Policy Document
#####################################
data "aws_iam_policy_document" "ec2_iam_assume_role_policy" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "ec2_iam_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:*",
      "ssm:*",
      "ssmmessages:*",
    ]

    resources = [
      "*",
    ]
  }
  statement {
    effect = "Allow"

    actions = [
      "cloudwatch:PutMetricData",
      "ec2:DescribeVolumes",
      "ec2:DescribeTags",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups",
      "logs:CreateLogStream",
      "logs:CreateLogGroup"
    ]

    resources = [
      "*",
    ]
  }
}

#####################################
# IAM Settings
#####################################
resource "aws_iam_role" "ec2_iam_role" {
  name               = "${var.base_name}-ec2-iam-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ec2_iam_assume_role_policy.json
  tags               = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-ec2-iam-role" }))
}

resource "aws_iam_role_policy" "ec2_iam_role_policy" {
  role   = aws_iam_role.ec2_iam_role.id
  policy = data.aws_iam_policy_document.ec2_iam_policy.json
}

resource "aws_iam_instance_profile" "ec2_iam_profile" {
  name = "${var.base_name}-ec2-iam-profile"
  role = aws_iam_role.ec2_iam_role.name
  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-ec2-iam-profile" }))
}

#####################################
# LB Target Group Settings
#####################################
resource "aws_lb_target_group" "lb_tg" {
  name        = "${var.base_name}-lb-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.vpc.id

  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-lb-tg" }))
}

// ↓↓↓閉塞時のみ利用（ここから）↓↓↓
/*
data "template_file" "sorry_page" {
  template = file("${path.module}/tpl/sorry.html.tpl")
}

resource "aws_lb_listener_rule" "listenerrule_blockage_hostname" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 100
  action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/html"
      message_body = data.template_file.sorry_page.rendered // 利用時は tpl/sorry.html.tpl の中身を確認すること
      status_code  = "200"
    }
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
  condition {
    host_header {
      values = ["${var.route53_settings["hostname"]}.${var.route53_settings["root_domain"]}"]
    }
  }
}*/
// ↑↑↑閉塞時のみ利用（ここまで）↑↑↑

resource "aws_lb_listener_rule" "listenerrule_root" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 200
  action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "404"
    }
  }
  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

resource "aws_lb_listener_rule" "listenerrule_forward" {
  listener_arn = aws_lb_listener.https_listener.arn
  priority     = 300
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
  condition {
    path_pattern {
      values = ["/?*"]
    }
  }
}