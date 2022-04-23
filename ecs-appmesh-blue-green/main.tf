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

  // ECS
  sample_param = {
    // service def
    desired_count    = 1
    platform_version = "1.4.0"
    // task def
    task_cpu    = 512  # 0.5 vCPU
    task_memory = 1024 # 1 GB
    // app container def
    app_name         = "sample"
    app_memory       = 256 # ハード制限（上限確保量）
    app_port         = "8080"
    healthcheck_path = "/health"
    // app container def blue
    blue_weight    = 1
    blue_is_active = true
    app_image_blue = "xxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/sample:0.0.1"
    // app container def green
    green_weight    = 0
    green_is_active = false
    app_image_green = "xxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/sample:0.0.2"
    // envoy container def
    envoy_image      = "840364872350.dkr.ecr.ap-northeast-1.amazonaws.com/aws-appmesh-envoy:v1.20.0.1-prod"
    envoy_cpu        = 32
    envoy_memory_rsv = 256 # ソフト制限（通常確保量）
    // xray container def
    xray_image      = "amazon/aws-xray-daemon"
    xray_cpu        = 32
    xray_memory_rsv = 256 # ソフト制限（通常確保量）
  }
}

#####################################
# Outputs
#####################################
output "sample_vpc" {
  value = aws_vpc.sample
}