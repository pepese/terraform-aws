#####################################
# LB
#####################################

resource "aws_lb" "lb" {
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.sg_lb.id
  ]

  subnets = [
    data.terraform_remote_state.network.outputs.subnet.public_1a_id,
    data.terraform_remote_state.network.outputs.subnet.public_1c_id,
    data.terraform_remote_state.network.outputs.subnet.public_1d_id
  ]

  tags = merge(local.base_tags, map("Name", "${local.base_name}-lb"))
}

resource "aws_lb_listener" "listener" {
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

resource "aws_security_group" "sg_lb" {
  vpc_id = data.terraform_remote_state.network.outputs.vpc.id
  tags   = merge(local.base_tags, map("Name", "${local.base_name}-sg-lb"))
}

resource "aws_security_group_rule" "egress_rule" {
  security_group_id = aws_security_group.sg_lb.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ingress_rule" {
  security_group_id = aws_security_group.sg_lb.id

  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  self        = false
}