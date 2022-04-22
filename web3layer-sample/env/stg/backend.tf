terraform {
  backend "s3" {
    bucket = "tfstate-pepese"
    key    = "web3layer-sample/stg/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

variable "access_key" {}
variable "secret_key" {}
variable "system" {
  default = "web3layer-sample"
}
variable "region" {
  default = "ap-northeast-1"
}
variable "env" {
  default = "stg"
}

module "my_module" {
  source     = "../../modules"
  access_key = var.access_key
  secret_key = var.secret_key

  // 以降、 modules の variables.tf 内の変数へ値を代入

  #####################################
  # Common
  #####################################
  system       = var.system
  region       = var.region
  env          = var.env
  state_bucket = "tfstate-pepese"
  state_key    = "web3layer-sample/stg/terraform.tfstate"

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
  # wordpress-server
  #####################################
  ami           = "ami-09ebacdc178ae23b7" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t3.nano"
  az            = "ap-northeast-1a"

  #####################################
  # wordpress_rds
  #####################################

  wordpress_rds_settings = {
    allocated_storage = 100
    engine = "mysql"
    engine_version = "5.7"
    instance_class = "db.t3.micro"
    username = "foo"
    password = "foobarbaz"
  }

  #####################################
  # vpc
  #####################################

  vpc_settings = {
    vpc_cidr_block          = "10.1.0.0/16"
    public_1a_cidr_block    = "10.1.0.0/24"
    public_1c_cidr_block    = "10.1.1.0/24"
    protected_1a_cidr_block = "10.1.64.0/24"
    protected_1c_cidr_block = "10.1.65.0/24"
    private_1a_cidr_block   = "10.1.128.0/24"
    private_1c_cidr_block   = "10.1.129.0/24"
  }
}