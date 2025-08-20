module "acm" {
  providers = {
    aws.virginia = aws.virginia
  }
  source = "../../modules/acm"

  common_param = local.common_param
  sns_topic    = null # ToDo: Implement SNS topic
}