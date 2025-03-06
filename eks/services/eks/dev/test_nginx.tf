#####################################
# ALB Listener
#####################################

resource "aws_lb_listener" "nginx_listener_http" {
  load_balancer_arn = module.eks-vpc.eks_alb_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.nginx_tg.arn
  }
}

#####################################
# Security Group Settings
#####################################

resource "aws_security_group" "nginx_alb_sg" {
  name   = "${module.eks-vpc.base_name}-nginx-alb-sg"
  vpc_id = module.eks-vpc.vpc_id
  tags   = merge("${module.eks-vpc.base_tags}", map("Name", "${module.eks-vpc.base_name}-nginx-alb-sg"))
}

resource "aws_security_group_rule" "nginx_alb_sg_allow_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.eks-vpc.eks_alb_sg_id
}

resource "aws_security_group_rule" "nginx_alb_sg_allow_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.eks-vpc.eks_alb_sg_id
}

resource "aws_security_group_rule" "eks_worker_sg_allow_ingress_nginx" {
  type                     = "ingress"
  from_port                = 30080
  to_port                  = 30080
  protocol                 = "tcp"
  source_security_group_id = module.eks-vpc.eks_alb_sg_id
  security_group_id        = module.eks-vpc.eks_worker_sg_id
}

#####################################
# Target Group Settings
#####################################

resource "aws_alb_target_group" "nginx_tg" {
  name     = "${module.eks-vpc.base_name}-nginx-tg"
  port     = 30080
  protocol = "HTTP"
  vpc_id   = module.eks-vpc.vpc_id
}

resource "aws_autoscaling_attachment" "nginx_autoscaling_attachment" {
  autoscaling_group_name = module.eks-vpc.eks_asg_id
  alb_target_group_arn   = aws_alb_target_group.nginx_tg.arn
}