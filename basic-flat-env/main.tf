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
  region  = var.region
  profile = var.profile
  default_tags { // AWS リソースへのデフォルトタグの設定
    tags = {
      System    = var.system
      Env       = var.env
      Terraform = "true"
    }
  }
}

#####################################
# Variables
#####################################
// Common
variable "profile" {}
variable "region" {}
variable "system" {}
variable "env" {}
variable "base_name" {}

// VPC
variable "vpc_cidr_block" {}

#####################################
# Outputs
#####################################
output "sample_vpc" {
  value = aws_vpc.sample
}