#####################################
# EC2 Settings
#####################################

# https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/hosting-wordpress.html

resource "aws_instance" "wordpress_server" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.protected_1a.id

  vpc_security_group_ids = [
    aws_security_group.wordpress_server_sg.id,
  ]

  associate_public_ip_address = false

  iam_instance_profile = aws_iam_instance_profile.wordpress_server_iam_profile.name

  credit_specification {
    cpu_credits = "unlimited"
  }

  root_block_device {
    volume_size = "20"
  }

  user_data = <<EOF
  #!/bin/bash
  echo '=== Start TimeZone Settings ==='
  sudo echo -e "ZONE=\"Asia/Tokyo\"\nUTC=true" > /etc/sysconfig/clock
  sudo chown root:root /etc/sysconfig/clock
  sudo chmod 644 /etc/sysconfig/clock
  sudo ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
  echo '=== End TimeZone Settings ==='

  #echo '=== Start Mount Settings ==='
  #sudo mkfs -t ext4 /dev/xvdh
  #sudo mkdir /data
  #sudo mount /dev/xvdh /data
  #echo '/dev/xvdh /data ext4 defaults,nofail 0 2' >> /etc/fstab
  #echo '=== End Mount Settings ==='

  EOF

  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-wordpress-server" }))
}

#####################################
# EBS Settings
#####################################
/*
resource "aws_ebs_volume" "wordpress_server_ebs" {
  availability_zone = var.az
  type              = "gp2"
  size              = 20

  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-wordpress-server-ebs" }))
}

resource "aws_volume_attachment" "ebs_attach" {
  device_name = "/dev/xvdh"
  volume_id   = aws_ebs_volume.wordpress_server_ebs.id
  instance_id = aws_instance.wordpress_server.id
}*/

#####################################
# Security Group Settings
#####################################

resource "aws_security_group" "wordpress_server_sg" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-wordpress-server-sg" }))
}

resource "aws_security_group_rule" "wordpress_server_sg_egress_rule" {
  security_group_id = aws_security_group.wordpress_server_sg.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "wordpress_server_sg_self_ingress_rule" {
  security_group_id = aws_security_group.wordpress_server_sg.id

  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"
  self      = true
}

resource "aws_security_group_rule" "wordpress_server_sg_ingress_rule" {
  security_group_id = aws_security_group.wordpress_server_sg.id

  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lb_sg.id
}

#####################################
# Data: IAM Policy Document
#####################################
data "aws_iam_policy_document" "wordpress_server_iam_assume_role_policy" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "ec2.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "wordpress_server_iam_policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:*",
      "ssm:*",
      "ssmmessages:*",
    ]

    resources = [
      "*",
    ]
  }
}

#####################################
# IAM Settings
#####################################

resource "aws_iam_role" "wordpress_server_iam_role" {
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.wordpress_server_iam_assume_role_policy.json
  tags               = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-wordpress-server-iam-role" }))
}

resource "aws_iam_role_policy" "wordpress_server_iam_role_policy" {
  role = aws_iam_role.wordpress_server_iam_role.id
  policy = data.aws_iam_policy_document.wordpress_server_iam_policy.json
}

resource "aws_iam_instance_profile" "wordpress_server_iam_profile" {
  role = aws_iam_role.wordpress_server_iam_role.name
}

#####################################
# LB Target Group Settings
#####################################

resource "aws_lb_target_group" "wordpress_lb_tg" {
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.vpc.id

  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-wordpress-lb-tg" }))
}

resource "aws_lb_listener_rule" "wordpress_lb_listener_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress_lb_tg.arn
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_lb_target_group_attachment" "wordpress_lb_tg_attach" {
  target_group_arn = aws_lb_target_group.wordpress_lb_tg.arn
  target_id        = aws_instance.wordpress_server.id
}

#####################################
# Auto Scaling Group
#####################################
/*
resource "aws_autoscaling_group" "bar" {}
*/