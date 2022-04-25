#####################################
# LB
#####################################
resource "aws_lb" "sample" {
  name               = "${local.base_name}-sample"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.sample_alb.id
  ]

  subnets = [
    aws_subnet.sample_public_1a.id,
    aws_subnet.sample_public_1c.id,
  ]

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample" }))
}

#####################################
# LB Listener / Target Group
#####################################
resource "aws_lb_listener" "sample_80" {
  load_balancer_arn = aws_lb.sample.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Hello"
      status_code  = "200"
    }
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-80" }))
}

resource "aws_lb_target_group" "sample_80_to_vgw" {
  name                 = "sample-80-to-vgw"
  port                 = local.sample_param["app_port"]
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = aws_vpc.sample.id
  slow_start           = 30
  deregistration_delay = 60

  health_check {
    enabled = true
    port    = 9901
    path    = "/ready"
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-80-to-vgw" }))
}

resource "aws_lb_listener_rule" "sample_80_to_vgw_ng" {
  listener_arn = aws_lb_listener.sample_80.arn
  priority     = 200
  action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
  condition {
    path_pattern {
      values = local.alb_settings["path_deny_list"]
    }
  }
}

resource "aws_lb_listener_rule" "sample_80_to_vgw" {
  listener_arn = aws_lb_listener.sample_80.arn
  priority     = 300
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sample_80_to_vgw.arn
  }
  condition {
    path_pattern {
      values = ["/?*"]
    }
  }
}

# resource "aws_lb_listener" "sample_9901" {
#   load_balancer_arn = aws_lb.sample.arn
#   port              = 9901
#   protocol          = "HTTP"

#   default_action {
#     type = "fixed-response"
#     fixed_response {
#       content_type = "text/plain"
#       message_body = "Hello"
#       status_code  = "200"
#     }
#   }

#   tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-9901" }))
# }

# resource "aws_lb_target_group" "sample_9901_to_vgw" {
#   name                 = "sample-9901-to-vgw"
#   port                 = 9901
#   protocol             = "HTTP"
#   target_type          = "ip"
#   vpc_id               = aws_vpc.sample.id
#   slow_start           = 30
#   deregistration_delay = 60

#   health_check {
#     enabled = true
#     path    = "/ready"
#   }

#   tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-9901-to-vgw" }))
# }

# resource "aws_lb_listener_rule" "sample_9901_to_vgw" {
#   listener_arn = aws_lb_listener.sample_9901.arn
#   priority     = 300
#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.sample_9901_to_vgw.arn
#   }
#   condition {
#     path_pattern {
#       values = ["/?*"]
#     }
#   }
# }

#####################################
# Security Group Settings
#####################################
resource "aws_security_group" "sample_alb" {
  name   = "${local.base_name}-sample-alb"
  vpc_id = aws_vpc.sample.id
  tags   = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-alb" }))
}

resource "aws_security_group_rule" "sample_alb_egress" {
  security_group_id = aws_security_group.sample_alb.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sample_alb_ingress_443" {
  security_group_id = aws_security_group.sample_alb.id

  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = local.alb_settings["ip_allow_list"]
}

resource "aws_security_group_rule" "sample_alb_ingress_80" {
  security_group_id = aws_security_group.sample_alb.id

  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = local.alb_settings["ip_allow_list"]
}

# resource "aws_security_group_rule" "sample_alb_ingress_9901" {
#   security_group_id = aws_security_group.sample_alb.id

#   type        = "ingress"
#   from_port   = 9901
#   to_port     = 9901
#   protocol    = "tcp"
#   cidr_blocks = local.alb_settings["ip_allow_list"]
# }