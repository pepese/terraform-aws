#####################################
# constant
#####################################

locals {
  base_tags = {
    System    = var.system
    Env       = var.env
    Terraform = "true"
  }
  base_name = "${var.system}-${var.env}"
}

#####################################
# variable
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

variable "state_key_self" {
  default = ""
}

variable "state_key_network" {
  default = ""
}

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