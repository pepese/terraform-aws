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
variable "account_id" {}

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
# vpc variable
#####################################
variable "vpc_settings" {
  description = "VPC Settings"
  type        = map(string)
  default = {
    vpc_cidr_block           = ""
    public_1a_cidr_block     = ""
    public_1c_cidr_block     = ""
    protected_1a_cidr_block  = ""
    protected_1c_cidr_block  = ""
    private_1a_cidr_block    = ""
    private_1c_cidr_block    = ""
    management_1a_cidr_block = ""
    management_1c_cidr_block = ""
  }
}

#####################################
# ec2 variable
#####################################
variable "ec2_settings" {
  description = "Server Settings"
  type        = map(string)
  default = {
    ami           = ""
    instance_type = ""
    az            = ""
    volume_size   = ""
    asg_max_size  = ""
    asg_min_size  = ""
  }
}

#####################################
# lb variable
#####################################
variable "ip_allow_list" {
  description = "Access Allow IPs"
  type        = list(string)
}

#####################################
# rds variable
#####################################
variable "rds_settings" {
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
# CloudWatch variable
#####################################
variable "cloudwatch_settings" {
  description = "CloudWatch Settings"
  type        = map(string)
  default = {
    alarm_mail = ""
  }
}

#####################################
# Route53 variable
#####################################
variable "route53_settings" {
  description = "Route53 Settings"
  type        = map(string)
  default = {
    root_domain              = ""
    hostname                 = ""
    private_hosted_zone_name = ""
  }
}

#####################################
# ACM variable
#####################################
variable "acm_settings" {
  description = "ACM Settings"
  type        = map(string)
  default = {
    cert_arn = ""
  }
}