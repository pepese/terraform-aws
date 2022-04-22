#####################################
# Terraform Settings
#####################################
terraform {
  required_version = "~> 1.1.0" // Terraform のバージョン
  required_providers {          // Provider の設定
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"        // AWS Provider のバージョン
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
  vpc_cidr_block = "10.0.0.0/16"
}

#####################################
# Outputs
#####################################
output "sample_vpc" {
  value = aws_vpc.sample
}