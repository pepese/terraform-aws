#####################################
# LB
#####################################
resource "aws_lb" "ms1_lb" {
  name               = "${var.base_name}-ms1-lb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.ms1_lb_sg.id
  ]

  subnets = [
    aws_subnet.cmn_subnet_public_1a.id,
    aws_subnet.cmn_subnet_public_1c.id,
  ]

  tags = merge(tomap({ "Service" = "ms1" }), tomap({ "Name" = "${var.base_name}-ms1-lb" }))
}

#####################################
# LB Listener
#####################################
resource "aws_lb_listener" "ms1_lb_listener_http" {
  load_balancer_arn = aws_lb.ms1_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ms1_lb_tg.arn
    # type = "fixed-response"
    # fixed_response {
    #   content_type = "text/plain"
    #   message_body = "Hello"
    #   status_code  = "200"
    # }
  }

  tags = merge(tomap({ "Service" = "ms1" }), tomap({ "Name" = "${var.base_name}-ms1-lb-listener-http" }))
}

#####################################
# Security Group Settings
#####################################
resource "aws_security_group" "ms1_lb_sg" {
  name   = "${var.base_name}-ms1-lb-sg"
  vpc_id = aws_vpc.cmn_vpc.id
  tags   = merge(tomap({ "Service" = "ms1" }), tomap({ "Name" = "${var.base_name}-ms1-lb-sg" }))
}

resource "aws_security_group_rule" "lb_sg_egress_rule" {
  security_group_id = aws_security_group.ms1_lb_sg.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "lb_sg_ingress_rule_https" {
  security_group_id = aws_security_group.ms1_lb_sg.id

  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = var.ip_allow_list
}

resource "aws_security_group_rule" "lb_sg_ingress_rule_http" {
  security_group_id = aws_security_group.ms1_lb_sg.id

  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = var.ip_allow_list
}