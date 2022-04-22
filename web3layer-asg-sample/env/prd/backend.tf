terraform {
  backend "s3" {
    bucket = "tfstate-sample"
    key    = "prd/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

variable "account_id" {
  default = "xxxxxxxxxxxx"
}
variable "access_key" {}
variable "secret_key" {}
variable "system" {
  default = "sample"
}
variable "region" {
  default = "ap-northeast-1"
}
variable "env" {
  default = "prd"
}

module "modules" {
  source     = "../../modules"
  account_id = var.account_id
  access_key = var.access_key
  secret_key = var.secret_key

  // 以降、 modules の variables.tf 内の変数へ値を代入

  #####################################
  # Common
  #####################################
  system       = var.system
  region       = var.region
  env          = var.env
  state_bucket = "tfstate-sample"
  state_key    = "prd/terraform.tfstate"

  #####################################
  # Tags
  #####################################
  base_tags = {
    System    = var.system
    Env       = var.env
    Terraform = "true"
  }
  base_name = "${var.system}-${var.env}"

  #####################################
  # vpc
  #####################################
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

  #####################################
  # ec2
  #####################################
  ec2_settings = {
    ami           = "ami-09ebacdc178ae23b7" # Amazon Linux 2 AMI (HVM), SSD Volume Type
    instance_type = "m5a.xlarge"
    az            = var.region
    volume_size   = "20"
    asg_max_size  = "1"
    asg_min_size  = "1"
  }

  #####################################
  # lb
  #####################################
  ip_allow_list = [
    "0.0.0.0/0",
  ]

  #####################################
  # rds
  #####################################
  rds_settings = {
    allocated_storage = 100
    engine            = "mysql"
    engine_version    = "5.7"
    instance_class    = "db.m5.large"
    username          = "admin"
    password          = "password"
  }

  #####################################
  # CloudWatch variable
  #####################################
  cloudwatch_settings = {
    alarm_mail = "alart@sample.com"
  }

  #####################################
  # Route53 variable
  #####################################
  route53_settings = {
    root_domain              = "sample.com" // ドメインは Terraform ではなく手動作成
    hostname                 = "hostname"
    private_hosted_zone_name = "sample.local"
  }

  #####################################
  # ACM variable
  #####################################
  acm_settings = {
    // 証明書は Terraform ではなく手動作成。なお手動でアラーム certificate-expire も作成している。
    cert_arn = "arn:aws:acm:ap-northeast-1:xxxxxxxxxxxx:certificate/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  }
}