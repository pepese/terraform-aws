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
  region  = var.region
  profile = var.profile
  default_tags {
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