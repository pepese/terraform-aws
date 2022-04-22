#####################################
# tags settings
#####################################

variable "base_tags" {
  type    = map(string)
  default = {}
}

variable "base_name" {
  default = ""
}

#####################################
# common variable
#####################################

variable "access_key" {}

variable "secret_key" {}

variable "system" {
  default = ""
}

variable "region" {
  default = "ap-northeast-1"
}

variable "env" {
  default = ""
}

variable "state_bucket" {
  default = ""
}

variable "state_key" {
  default = ""
}

#####################################
# lb variable
#####################################

# nothing

#####################################
# rds variable
#####################################

variable "wordpress_rds_settings" {
  description = "RDS Settings"
  type        = map(string)
  default = {
    allocated_storage = 100
    engine            = ""
    engine_version    = ""
    instance_class    = ""
    username          = ""
    password          = ""
  }
}

#####################################
# vpc variable
#####################################

variable "vpc_settings" {
  description = "VPC Settings"
  type        = map(string)
  default = {
    vpc_cidr_block          = ""
    public_1a_cidr_block    = ""
    public_1c_cidr_block    = ""
    protected_1a_cidr_block = ""
    protected_1c_cidr_block = ""
    private_1a_cidr_block   = ""
    private_1c_cidr_block   = ""
  }
}

#####################################
# wordpress-server variable
#####################################

variable "state_key_lb" {
  default = ""
}

variable "ami" {
  default = ""
}

variable "instance_type" {
  default = ""
}

variable "az" {
  default = ""
}