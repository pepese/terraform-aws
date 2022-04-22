#####################################
# Terraform Settings
#####################################
terraform {
  required_version = "~> 1.1.0" // Terraform のバージョン
  required_providers {          // Provider の設定
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0" // AWS Provider のバージョン
    }
  }
  backend "s3" {                     // この設定で State ファイルが S3 に保存されます
    bucket = "tfstate-pepese"        // State ファイルを配置するバケット
    key    = "prd/terraform.tfstate" // State ファイルを配置するパス・ファイル名
    region = "ap-northeast-1"        // S3のリージョン
  }
}

#####################################
# Provider Settings
#####################################
provider "aws" {
  region  = local.region
  profile = var.profile
  default_tags { // AWS リソースへのデフォルトタグの設定
    tags = {
      System    = local.system
      Env       = local.env
      Terraform = "true"
    }
  }
}

#####################################
# Variables
#####################################
variable "profile" {}
locals {
  // Common
  region    = "ap-northeast-1"
  system    = "system"
  env       = "prd"
  base_name = "${local.system}-${local.env}"

  // VPC
  vpc_settings = {
    vpc_cidr_block           = "10.0.0.0/16"
    public_1a_cidr_block     = "10.0.0.0/24"
    public_1c_cidr_block     = "10.0.1.0/24"
    protected_1a_cidr_block  = "10.0.64.0/24"
    protected_1c_cidr_block  = "10.0.65.0/24"
    private_1a_cidr_block    = "10.0.128.0/24"
    private_1c_cidr_block    = "10.0.129.0/24"
    management_1a_cidr_block = "10.0.192.0/24"
    management_1c_cidr_block = "10.0.193.0/24"
  }

  // EC2
  ec2_settings = {
    ami           = "ami-09ebacdc178ae23b7" # Amazon Linux 2 AMI (HVM), SSD Volume Type
    instance_type = "m5a.xlarge"
    az            = local.region
    volume_size   = "20"
    asg_max_size  = "1"
    asg_min_size  = "1"
  }

  // ALB
  ip_allow_list = [
    "0.0.0.0/0",
  ]

  // Cloud Watch
  cloudwatch_settings = {
    alarm_mail = "alart@sample.com"
  }

  // Route53
  route53_settings = {
    root_domain              = "sample.com" // ドメインは Terraform ではなく手動作成
    hostname                 = "hostname"
    private_hosted_zone_name = "sample.local"
  }

  // ACM
  acm_settings = {
    // 証明書は Terraform ではなく手動作成。なお手動でアラーム certificate-expire も作成している。
    cert_arn = "arn:aws:acm:ap-northeast-1:xxxxxxxxxxxx:certificate/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  }
}

#####################################
# Outputs
#####################################
output "sample_alb" {
  value = {
    dns_name     = aws_lb.sample.dns_name
    # listener_arn = aws_lb_listener.sample_https.arn
    listener_arn = aws_lb_listener.sample_http.arn
  }
}

output "sample_alb_sg" {
  value = {
    id = aws_security_group.sample_alb.id
  }
}

output "sample_vpc" {
  value = {
    id = aws_vpc.sample.id
  }
}

output "sample_subnet" {
  value = {
    public_1a_id    = aws_subnet.sample_public_1a.id
    public_1c_id    = aws_subnet.sample_public_1c.id
    protected_1a_id = aws_subnet.sample_protected_1a.id
    protected_1c_id = aws_subnet.sample_protected_1c.id
    private_1a_id   = aws_subnet.sample_private_1a.id
    private_1c_id   = aws_subnet.sample_private_1c.id
  }
}