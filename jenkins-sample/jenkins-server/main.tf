#####################################
# EC2 Settings
#####################################

resource "aws_instance" "ec2_jenkins" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = data.terraform_remote_state.network.outputs.subnet.protected_1a_id

  vpc_security_group_ids = [
    aws_security_group.default.id,
  ]

  associate_public_ip_address = false

  iam_instance_profile = aws_iam_instance_profile.default_profile.name

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

  echo '=== Start Mount Settings ==='
  sudo mkfs -t ext4 /dev/xvdh
  sudo mkdir /data
  sudo mount /dev/xvdh /data
  echo '/dev/xvdh /data ext4 defaults,nofail 0 2' >> /etc/fstab
  echo '=== End Mount Settings ==='

  echo '=== Start Java Settings ==='
  sudo yum install java-1.8.0-openjdk -y
  sudo alternatives --set java /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/java
  echo '=== End Java Settings ==='

  echo '=== Start Jenkins Settings ==='
  sudo groupadd -g 1001 jenkins
  sudo useradd -g jenkins -u 1001 jenkins
  sudo wget -P /opt https://get.jenkins.io/war-stable/2.263.4/jenkins.war
  sudo chown jenkins:jenkins /opt/jenkins.war
  sudo chmod 755 /opt/jenkins.war
  sudo mkdir /data/jenkins
  sudo chown -R jenkins:jenkins /data/jenkins
  sudo mkdir /var/log/jenkins
  sudo chown -R jenkins:jenkins /var/log/jenkins
  sudo echo "[Unit]
Description = Jenkins Daemon
After=network.target

[Service]
User = jenkins
Group = jenkins
ExecStart=/bin/sh -c 'env JENKINS_HOME=/data/jenkins java -jar /opt/jenkins.war --httpPort=8080 --prefix=/jenkins >> /var/log/jenkins/jenkins.log 2>&1'
ExecStop=/bin/kill -SIGTERM $MAINPID
ExecReload=/bin/kill -SIGTERM $MAINPID && /bin/sh -c 'env JENKINS_HOME=/data/jenkins java -jar /opt/jenkins.war --httpPort=8080 --prefix=/jenkins >> /var/log/jenkins/jenkins.log 2>&1'
Restart=always
Type = simple

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/jenkins.service
  sudo chown root:root /etc/systemd/system/jenkins.service
  sudo chmod 644 /etc/systemd/system/jenkins.service
  sudo systemctl daemon-reload
  sudo systemctl enable jenkins
  echo '=== End Jenkins Settings ==='

  EOF

  tags = merge(local.base_tags, map("Name", "${local.base_name}-ec2-jenkins"))
}

#####################################
# EBS Settings
#####################################

resource "aws_ebs_volume" "ebs_jenkins" {
  availability_zone = var.az
  type              = "gp2"
  size              = 20

  tags = merge(local.base_tags, map("Name", "${local.base_name}-ebs-jenkins"))
}

resource "aws_volume_attachment" "ebs_attach" {
  device_name = "/dev/xvdh"
  volume_id   = aws_ebs_volume.ebs_jenkins.id
  instance_id = aws_instance.ec2_jenkins.id
}

#####################################
# Security Group Settings
#####################################

resource "aws_security_group" "default" {
  vpc_id = data.terraform_remote_state.network.outputs.vpc.id
  tags   = merge(local.base_tags, map("Name", "${local.base_name}-sg-ec2-jenkins"))
}

resource "aws_security_group_rule" "egress_rule" {
  security_group_id = aws_security_group.default.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "self_ingress_rule" {
  security_group_id = aws_security_group.default.id

  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"
  self      = true
}

resource "aws_security_group_rule" "http_ingress_rule" {
  security_group_id = aws_security_group.default.id

  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.lb.outputs.sg.id
}

#####################################
# Data: IAM Policy Document
#####################################

data "aws_iam_policy_document" "ec2_role" {
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

data "aws_iam_policy_document" "ec2_role_policy" {
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

resource "aws_iam_role" "default_role" {
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ec2_role.json
  tags               = merge(local.base_tags, map("Name", "${local.base_name}-role-jenkins"))
}

resource "aws_iam_role_policy" "defaut_policy" {
  role   = aws_iam_role.default_role.id
  policy = data.aws_iam_policy_document.ec2_role_policy.json
}

resource "aws_iam_instance_profile" "default_profile" {
  role = aws_iam_role.default_role.name
}

#####################################
# LB Target Group Settings
#####################################

resource "aws_lb_target_group" "tg_jenkins" {
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc.id

  tags = merge(local.base_tags, map("Name", "${local.base_name}-tg-jenkins"))
}

resource "aws_lb_listener_rule" "rule_jenkins" {
  listener_arn = data.terraform_remote_state.lb.outputs.lb.listener_arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_jenkins.arn
  }
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_lb_target_group_attachment" "tg_jenkins_attach" {
  target_group_arn = aws_lb_target_group.tg_jenkins.arn
  target_id        = aws_instance.ec2_jenkins.id
}