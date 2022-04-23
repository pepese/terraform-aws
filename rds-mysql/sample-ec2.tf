#####################################
# EC2
#####################################
resource "aws_instance" "sample_ec2" {
  ami           = local.ec2_settings["ami"]
  instance_type = local.ec2_settings["instance_type"]
  subnet_id     = aws_subnet.sample_management_1a.id

  vpc_security_group_ids = [
    aws_security_group.sample_ec2.id,
  ]

  associate_public_ip_address = false

  iam_instance_profile = aws_iam_instance_profile.sample_ec2.name

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
  EOF

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-ec2" }))
}

#####################################
# Security Group Settings
#####################################
resource "aws_security_group" "sample_ec2" {
  vpc_id = aws_vpc.sample.id
  tags   = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-ec2" }))
}

resource "aws_security_group_rule" "sample_ec2_egress" {
  security_group_id = aws_security_group.sample_ec2.id

  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "sample_ec2_self" {
  security_group_id = aws_security_group.sample_ec2.id

  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"
  self      = true
}

#####################################
# IAM Settings
#####################################
resource "aws_iam_role" "sample_ec2" {
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.sample_ec2_assume.json
  tags               = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-ec2" }))
}

data "aws_iam_policy_document" "sample_ec2_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "sample_ec2" {
  statement {
    effect = "Allow"
    actions = [
      "kms:*",
    ]
    resources = [
      "*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
    resources = [
      "*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:*",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy" "sample_ec2" {
  role   = aws_iam_role.sample_ec2.id
  policy = data.aws_iam_policy_document.sample_ec2.json
}

resource "aws_iam_role_policy_attachment" "sample_ec2" {
  role       = aws_iam_role.sample_ec2.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "sample_ec2" {
  role = aws_iam_role.sample_ec2.name
}