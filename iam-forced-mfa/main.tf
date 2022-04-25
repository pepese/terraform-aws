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
  vpc_cidr_block = "10.0.0.0/16"

  // IAM Users
  sample_iam_dev_users = [
    "xxxxx",
  ]
}

#####################################
# Outputs
#####################################
output "sample_vpc" {
  value = aws_vpc.sample
}

// IAM Users
output "sample_developers_first_password" {
  value = {
    for k, v in aws_iam_user_login_profile.sample_developers : k => v.password
  }
}