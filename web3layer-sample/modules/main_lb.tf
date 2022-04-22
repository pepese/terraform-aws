#####################################
# LB
#####################################

resource "aws_lb" "lb" {
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

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.lb.arn
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
}

#####################################
# Security Group Settings
#####################################

resource "aws_security_group" "lb_sg" {
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

resource "aws_security_group_rule" "lb_sg_ingress_rule" {
  security_group_id = aws_security_group.lb_sg.id

  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}