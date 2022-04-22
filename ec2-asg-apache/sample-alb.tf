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
# LB Listener
#####################################
# resource "aws_lb_listener" "sample_https" {
#   load_balancer_arn = aws_lb.sample.arn
#   port              = "443"
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = local.acm_settings["cert_arn"]

#   default_action {
#     type = "fixed-response"
#     fixed_response {
#       content_type = "text/plain"
#       message_body = "Hello"
#       status_code  = "200"
#     }
#   }

#   tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-https" }))
# }

# // http to https リダイレクトの設定
# resource "aws_lb_listener" "sample_http_redirect" {
#   load_balancer_arn = aws_lb.sample.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type = "redirect"
#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }

#   tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-http-redirect" }))
# }

resource "aws_lb_listener" "sample_http" {
  load_balancer_arn = aws_lb.sample.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Hello"
      status_code  = "200"
    }
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-http" }))
}

#####################################
# Security Group Settings
#####################################
resource "aws_security_group" "sample_alb" {
  name   = "${local.base_name}-sg-lb"
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

resource "aws_security_group_rule" "sample_alb_ingress_https" {
  security_group_id = aws_security_group.sample_alb.id

  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = local.ip_allow_list
}

resource "aws_security_group_rule" "sample_alb_ingress_http" {
  security_group_id = aws_security_group.sample_alb.id

  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = local.ip_allow_list
}