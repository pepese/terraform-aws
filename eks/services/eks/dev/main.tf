terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket = "tfstate-pepese"
    key    = "eks_dev.tfstate"
    region = "ap-northeast-1"
  }
}

variable "access_key" {} # terraform.tfvars から読み込む
variable "secret_key" {}
variable "region" {
  default = "ap-northeast-1"
}

module "eks" {
  source     = "../../../modules/eks"
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
  // 以降、 modules の variables.tf 内の変数へ値を代入
  project     = "pepese"
  environment = "dev"
}

// モジュール内の output は main.tf から読み出さないと state に記録されない
output "kubeconfig" {
  value = "${module.eks.kubeconfig}"
}

output "configmap" {
  value = "${module.eks.configmap}"
}

// data "template_file" "cluster" {
//   template = "${file("${path.module}/../../../modules/eks/template/eks_cluster.tpl")}"
//   vars = {
//     project          = "${module.eks.project}"
//     environment      = "${module.eks.environment}"
//     cluster_name     = "${module.eks.cluster_name}"
//     cluster_version  = "${module.eks.cluster_version}"
//     instance_type    = "${module.eks.instance_type}"
//     vpc              = "${module.eks.vpc_id}"
//     public_subnet_a  = "${module.eks.public_subnet_a}"
//     public_subnet_c  = "${module.eks.public_subnet_c}"
//     public_subnet_d  = "${module.eks.public_subnet_d}"
//     cluster_subnet_a = "${module.eks.cluster_subnet_a}"
//     cluster_subnet_c = "${module.eks.cluster_subnet_c}"
//     cluster_subnet_d = "${module.eks.cluster_subnet_d}"
//     security_group   = "${module.eks.eks_worker_sg_id}"
//   }
// }

// resource "null_resource" "cluster" {
//   provisioner "local-exec" {
//     command = "echo '${data.template_file.cluster.rendered}' > eks_cluster.yaml"
//   }
//   triggers = {
//     template = "${data.template_file.cluster.rendered}"
//   }
// }