#####################################
# Variables Outputs
#####################################

output "base_name" {
  value = "${local.base_name}"
}

output "cluster_name" {
  value = "${local.cluster_name}"
}

output "cluster_version" {
  value = "${var.cluster_version}"
}

output "instance_type" {
  value = "${var.instance_type}"
}

output "base_tags" {
  value = "${local.base_tags}"
}

#####################################
# VPC Outputs
#####################################

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "public_subnet_a" {
  value = "${aws_subnet.public_subnet_a.id}"
}

output "public_subnet_c" {
  value = "${aws_subnet.public_subnet_c.id}"
}

output "public_subnet_d" {
  value = "${aws_subnet.public_subnet_d.id}"
}

output "cluster_subnet_a" {
  value = "${aws_subnet.cluster_subnet_a.id}"
}

output "cluster_subnet_c" {
  value = "${aws_subnet.cluster_subnet_c.id}"
}

output "cluster_subnet_d" {
  value = "${aws_subnet.cluster_subnet_d.id}"
}

output "private_subnet_a" {
  value = "${aws_subnet.private_subnet_a.id}"
}

output "private_subnet_c" {
  value = "${aws_subnet.private_subnet_c.id}"
}

output "private_subnet_d" {
  value = "${aws_subnet.private_subnet_d.id}"
}

#####################################
# SecurityGroup Outputs
#####################################

output "eks_master_sg_id" {
  value = "${aws_security_group.eks_master_sg.id}"
}

output "eks_worker_sg_id" {
  value = "${aws_security_group.eks_worker_sg.id}"
}

#####################################
# AutoscalingGroup Outputs
#####################################

output "eks_asg_id" {
  value = "${aws_autoscaling_group.eks_asg.id}"
}

#####################################
# ALB Outputs
#####################################

output "eks_alb_arn" {
  value = "${aws_alb.eks_alb.arn}"
}

output "eks_alb_sg_id" {
  value = "${aws_security_group.eks_alb_sg.id}"
}

#####################################
# IAM Outputs
#####################################

output "eks_master_role_id" {
  value = "${aws_iam_role.eks_master_role.id}"
}
output "eks_master_role_name" {
  value = "${aws_iam_role.eks_master_role.name}"
}

output "eks_worker_role_id" {
  value = "${aws_iam_role.eks_worker_role.id}"
}

output "eks_worker_role_name" {
  value = "${aws_iam_role.eks_worker_role.name}"
}

#####################################
# Kubernetes Config Outputs
#####################################

locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.cluster.endpoint}
    certificate-authority-data: ${aws_eks_cluster.cluster.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws
      args:
        - "eks"
        - "get-token"
        - "--cluster-name"
        - "${local.cluster_name}"
KUBECONFIG

  eks_configmap = <<CONFIGMAPAWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.eks_worker_role.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}

output "kubeconfig" {
  value = "${local.kubeconfig}"
}

output "configmap" {
  value = "${local.eks_configmap}"
}