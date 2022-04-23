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
    ami           = "ami-03d79d440297083e3" # Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type
    instance_type = "t3.nano"
    az            = "ap-northeast-1a"
  }

  // RDS
  rds_settings = {
    allocated_storage = 100
    engine            = "mysql"
    engine_version    = "5.7"
    instance_class    = "db.m5.large"
    username          = "admin"
    password          = "password"
  }

  // CloudWatch
  cloudwatch_settings = {
    alarm_mail = "alart@sample.com"
  }

  // Route53
  route53_settings = {
    root_domain              = "sample.com" // ドメインは Terraform ではなく手動作成
    hostname                 = "hostname"
    private_hosted_zone_name = "sample.local"
  }
}

#####################################
# Outputs
#####################################
output "sample_vpc" {
  value = aws_vpc.sample
}