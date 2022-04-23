#####################################
# ECS Service Security Group
#####################################
resource "aws_security_group" "sample" {
  name   = "${local.base_name}-sample"
  vpc_id = aws_vpc.sample.id
  tags   = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample" }))
}

resource "aws_security_group_rule" "sample_egress" {
  security_group_id = aws_security_group.sample.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sample_self" {
  security_group_id = aws_security_group.sample.id

  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"
  self      = true
}

resource "aws_security_group_rule" "sample_ingress" {
  security_group_id = aws_security_group.sample.id

  type      = "ingress"
  from_port = local.sample_param["app_port"]
  to_port   = local.sample_param["app_port"]
  protocol  = "tcp"
  cidr_blocks = [
    aws_subnet.sample_protected_1a.cidr_block,
    aws_subnet.sample_protected_1c.cidr_block,
  ]
}