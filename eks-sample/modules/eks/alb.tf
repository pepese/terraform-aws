#####################################
# ALB Base Setting
#####################################

resource "aws_alb" "eks_alb" {
  name               = "${local.base_name}-eks-alb"
  load_balancer_type = "application"
  internal           = false
  idle_timeout       = 60
  subnets = [
    "${aws_subnet.public_subnet_a.id}",
    "${aws_subnet.public_subnet_c.id}",
    "${aws_subnet.public_subnet_d.id}",
  ]
  security_groups = [
    "${aws_security_group.eks_alb_sg.id}",
  ]
  tags = merge(local.eks_nw_tags, map("Name", "${local.base_name}-eks-alb"))
}

#####################################
# Security Group Settings
#####################################

resource "aws_security_group" "eks_alb_sg" {
  name   = "${local.base_name}-eks-alb-sg"
  vpc_id = "${aws_vpc.vpc.id}"
  tags   = merge(local.base_tags, map("Name", "${local.base_name}-eks-alb-sg"))
}