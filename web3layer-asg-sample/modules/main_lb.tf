#####################################
# LB
#####################################
resource "aws_lb" "lb" {
  name               = "${var.base_name}-lb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.lb_sg.id
  ]

  subnets = [
    aws_subnet.public_1a.id,
    aws_subnet.public_1c.id,
  ]

  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-lb" }))
}

#####################################
# LB Listener
#####################################
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_settings["cert_arn"]

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Hello"
      status_code  = "200"
    }
  }

  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-lb-https-listener" }))
}

# 以降、http to https リダイレクトの設定
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-lb-http-listener" }))
}

#####################################
# Security Group Settings
#####################################
resource "aws_security_group" "lb_sg" {
  name   = "${var.base_name}-sg-lb"
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-sg-lb" }))
}

resource "aws_security_group_rule" "lb_sg_egress_rule" {
  security_group_id = aws_security_group.lb_sg.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "lb_sg_ingress_rule_https" {
  security_group_id = aws_security_group.lb_sg.id

  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = var.ip_allow_list
}

resource "aws_security_group_rule" "lb_sg_ingress_rule_http" {
  security_group_id = aws_security_group.lb_sg.id

  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = var.ip_allow_list
}