#####################################
# Terraform Settings
#####################################
terraform {
  required_version = "~> 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket = "tfstate-pepese"
    key    = "prd/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

#####################################
# Provider Settings
#####################################
provider "aws" {
  region  = local.region
  profile = var.profile
  default_tags {
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