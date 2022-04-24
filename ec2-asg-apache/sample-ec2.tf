#####################################
# Autoscaling Group
#####################################
resource "aws_launch_template" "sample" {
  name          = "${local.base_name}-sample"
  image_id      = local.ec2_settings["ami"]
  instance_type = local.ec2_settings["instance_type"]
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.sample_ec2.id]
    delete_on_termination       = true
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.sample.name
  }
  credit_specification {
    cpu_credits = "unlimited"
  }
  ebs_optimized = true
  user_data     = base64encode(data.template_file.sample_ec2_user_date.rendered)
  tag_specifications {
    resource_type = "instance"
    tags          = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample" }))
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample" }))
}

resource "aws_placement_group" "sample" {
  name     = "${local.base_name}-sample"
  strategy = "cluster"
  tags     = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample" }))
}

resource "aws_autoscaling_group" "sample" {
  name            = "${local.base_name}-sample"
  max_size        = local.ec2_settings["asg_max_size"]
  min_size        = local.ec2_settings["asg_min_size"]
  placement_group = aws_placement_group.sample.id
  vpc_zone_identifier = [
    aws_subnet.sample_protected_1a.id,
    aws_subnet.sample_protected_1c.id
  ]
  launch_template {
    id      = aws_launch_template.sample.id
    version = "$Latest"
  }
  health_check_type = "ELB"
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [load_balancers, target_group_arns]
  }

  tag {
    key                 = "Service"
    value               = "sample"
    propagate_at_launch = true
  }
  tag {
    key                 = "Name"
    value               = "${local.base_name}-sample-v${aws_launch_template.sample.latest_version}"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "sample" {
  autoscaling_group_name = aws_autoscaling_group.sample.id
  lb_target_group_arn    = aws_lb_target_group.sample.arn
}

#####################################
# User Data
#####################################
data "template_file" "sample_ec2_user_date" {
  template = file("${path.module}/tpl/ec2_user_data.sh.tpl")
  vars = {
    env    = "${local.env}"
    system = "${local.system}"
  }
}

#####################################
# Security Group Settings
#####################################
resource "aws_security_group" "sample_ec2" {
  name   = "${local.base_name}-sample-ec2"
  vpc_id = aws_vpc.sample.id
  tags   = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-ec2" }))
}

resource "aws_security_group_rule" "sample_ec2_egress" {
  security_group_id = aws_security_group.sample_ec2.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sample_ec2_sg_self" {
  security_group_id = aws_security_group.sample_ec2.id

  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"
  self      = true
}

resource "aws_security_group_rule" "sample_ec2_ingress" {
  security_group_id = aws_security_group.sample_ec2.id

  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.sample_alb.id
}

#####################################
# Data: IAM Policy Document
#####################################
data "aws_iam_policy_document" "sample_ec2_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "sample_ec2" {
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
resource "aws_iam_role" "sample_ec2" {
  name               = "${local.base_name}-sample-ec2"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.sample_ec2_assume.json
  tags               = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-ec2" }))
}

resource "aws_iam_role_policy" "ec2_iam_role_policy" {
  role   = aws_iam_role.sample_ec2.id
  policy = data.aws_iam_policy_document.sample_ec2.json
}

resource "aws_iam_instance_profile" "sample" {
  name = "${local.base_name}-sample"
  role = aws_iam_role.sample_ec2.name
  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample" }))
}

#####################################
# LB Target Group Settings
#####################################
resource "aws_lb_target_group" "sample" {
  name        = "${local.base_name}-sample"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.sample.id

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample" }))
}

// ↓↓↓閉塞時のみ利用（ここから）↓↓↓
/*
data "template_file" "sorry_page" {
  template = file("${path.module}/tpl/sorry.html.tpl")
}

resource "aws_lb_listener_rule" "sample_blockage_hostname" {
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
      values = ["${local.route53_settings["hostname"]}.${local.route53_settings["root_domain"]}"]
    }
  }
}*/
// ↑↑↑閉塞時のみ利用（ここまで）↑↑↑

resource "aws_lb_listener_rule" "sample_root" {
  # listener_arn = aws_lb_listener.sample_https.arn
  listener_arn = aws_lb_listener.sample_http.arn
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

resource "aws_lb_listener_rule" "sample_forward" {
  # listener_arn = aws_lb_listener.sample_https.arn
  listener_arn = aws_lb_listener.sample_http.arn
  priority     = 300
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sample.arn
  }
  condition {
    path_pattern {
      values = ["/?*"]
    }
  }
}