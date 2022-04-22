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
  default = ""
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