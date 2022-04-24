#####################################
# Terraform Settings
#####################################
terraform {
  required_version = "~> 1.1.0" // Terraform のバージョン
  required_providers {          // Provider の設定
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0" // AWS Provider のバージョン
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
  account_id = "xxxxxxxxxxxx"
  region     = "ap-northeast-1"
  system     = "system"
  env        = "prd"
  base_name  = "${local.system}-${local.env}"

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
  aurora_settings = {
    engine                  = "aurora-postgresql"
    engine_version          = "13.4"
    instance_class          = "db.t3.medium"
    username                = "testuser"
    password                = "password"
    port                    = "5432"
    db_name                 = "testdb"
    maintenance_window      = "sun:16:00-sun:17:00" # UTC
    backup_window           = "15:00-16:00"         # UTC
    backup_retention_period = "7"
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