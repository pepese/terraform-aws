resource "aws_eks_cluster" "cluster" {
  name     = local.cluster_name
  role_arn = aws_iam_role.eks_master_role.arn
  version  = local.cluster_version
  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true
    security_group_ids      = ["${aws_security_group.eks_master_sg.id}"]
    subnet_ids = [
      "${aws_subnet.public_subnet_a.id}", "${aws_subnet.public_subnet_c.id}", "${aws_subnet.public_subnet_d.id}",
      "${aws_subnet.cluster_subnet_a.id}", "${aws_subnet.cluster_subnet_c.id}", "${aws_subnet.cluster_subnet_d.id}"
    ]
  }
  depends_on = [
    "aws_iam_role_policy_attachment.eks_cluster_policy",
    "aws_iam_role_policy_attachment.eks_service_policy",
  ]
}

locals {
  userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint "${aws_eks_cluster.cluster.endpoint}" --b64-cluster-ca "${aws_eks_cluster.cluster.certificate_authority.0.data}" "${aws_eks_cluster.cluster.name}"
USERDATA
}

data "aws_ami" "eks_worker" {
  most_recent = true
  owners      = ["602401143452"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${local.cluster_version}-v*"]
  }
}

resource "aws_launch_configuration" "eks_lc" {
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.eks_worker_role_profile.id
  image_id                    = data.aws_ami.eks_worker.image_id
  instance_type               = var.instance_type
  name_prefix                 = "eks_worker"
  # key_name                    = "${var.key_name}" # ssh key
  root_block_device {
    volume_type = "gp2"
    volume_size = "20"
  }
  security_groups  = ["${aws_security_group.eks_worker_sg.id}"]
  user_data_base64 = base64encode(local.userdata)
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "eks_asg" {
  name                 = "${local.base_name}-eks-asg"
  desired_capacity     = var.asg_desired_capacity
  launch_configuration = aws_launch_configuration.eks_lc.id
  max_size             = var.asg_max_size
  min_size             = var.asg_min_size
  vpc_zone_identifier  = ["${aws_subnet.cluster_subnet_a.id}", "${aws_subnet.cluster_subnet_c.id}", "${aws_subnet.cluster_subnet_d.id}"]
  tag {
    key                 = "Project"
    value               = var.project
    propagate_at_launch = true
  }
  tag {
    key                 = "Terraform"
    value               = "true"
    propagate_at_launch = true
  }
  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "true"
    propagate_at_launch = true
  }
  tag {
    key                 = "k8s.io/cluster-autoscaler/${local.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
  tag {
    key                 = "kubernetes.io/cluster/${local.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
  tag {
    key                 = "Name"
    value               = "${local.base_name}-eks-asg"
    propagate_at_launch = true
  }
}