terraform {
  backend "s3" {
    bucket = "tfstate-pepese-sample"
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
  default = "system1"
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
  // provider.tf の default_tags にて全ての AWS リソースに共通するタグを設定
  // System = var.system, Env = var.env, Terraform = "true"
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
  # lb
  #####################################
  ip_allow_list = [
    "0.0.0.0/0",
  ]

  #####################################
  # ms1 ecs service variable
  #####################################
  ms1_ecs_service_settings = {
    desired_count                 = 1
    platform_version              = "1.4.0"
    container_port                = "80"
    task_cpu                      = "256" # 0.25vCPU
    task_memory                   = "512" # 0.5 GB
    task_definition_memory        = "128"
    task_definition_containerPort = "80"
  }

  #####################################
  # rds
  #####################################
  rds_settings = {
    allocated_storage = 100
    engine            = "postgres"
    engine_version    = "13.4"
    instance_class    = "db.m5.large"
    username          = "testuser"
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