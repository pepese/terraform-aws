#####################################
# rds variable
#####################################
variable "rds_settings" {
  description = "RDS Settings"
  type        = map(string)
  default = {
    allocated_storage = 100
    engine            = "mysql"
    engine_version    = "5.7"
    instance_class    = "db.m5.large"
    username          = "admin"
    password          = "password"
  }
}

#####################################
# CloudWatch variable
#####################################
variable "cloudwatch_settings" {
  description = "CloudWatch Settings"
  type        = map(string)
  default = {
    alarm_mail = "alart@sample.com"
  }
}

#####################################
# Route53 variable
#####################################
variable "route53_settings" {
  description = "Route53 Settings"
  type        = map(string)
  default = {
    root_domain              = "sample.com" // ドメインは Terraform ではなく手動作成
    hostname                 = "hostname"
    private_hosted_zone_name = "sample.local"
  }
}