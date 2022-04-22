variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "ap-northeast-1"
}
variable "project" {
  default = "pepese"
}
variable "environment" {
  default = "dev"
}
variable "cluster_version" {
  default = "1.14"
}
variable "instance_type" {
  default = "t3.micro"
}
variable "instance_volume_size" {
  default = "20"
}
variable "asg_desired_capacity" {
  default = 2
}
variable "asg_max_size" {
  default = 2
}
variable "asg_min_size" {
  default = 2
}

locals {
  base_tags = {
    Project     = var.project
    Terraform   = "true"
    Environment = var.environment
  }
  base_name       = "${var.project}-${var.environment}"
  cluster_name    = "${local.base_name}-cluster"
  eks_nw_tags     = merge(local.base_tags, map("kubernetes.io/cluster/${local.cluster_name}", "shared"))
  cluster_version = var.cluster_version
}