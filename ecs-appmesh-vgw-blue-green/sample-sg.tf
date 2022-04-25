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

#####################################
# ECS Service Security Group / Virtual Gateway
#####################################
resource "aws_security_group" "sample_vgw" {
  name   = "${local.base_name}-sample-vgw"
  vpc_id = aws_vpc.sample.id
  tags   = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-vgw" }))
}

resource "aws_security_group_rule" "sample_vgw_sg_egress" {
  security_group_id = aws_security_group.sample_vgw.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sample_vgw_ingress_80" {
  security_group_id = aws_security_group.sample_vgw.id

  type      = "ingress"
  from_port = local.sample_param["app_port"]
  to_port   = local.sample_param["app_port"]
  protocol  = "tcp"
  cidr_blocks = [
    aws_subnet.sample_public_1a.cidr_block,
    aws_subnet.sample_public_1c.cidr_block,
  ]
}

resource "aws_security_group_rule" "sample_vgw_ingress_9901" {
  security_group_id = aws_security_group.sample_vgw.id

  type      = "ingress"
  from_port = 9901
  to_port   = 9901
  protocol  = "tcp"
  cidr_blocks = [
    aws_subnet.sample_public_1a.cidr_block,
    aws_subnet.sample_public_1c.cidr_block,
  ]
}