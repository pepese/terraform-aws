terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.virginia]
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "pepese_com_virginia_acm_days_to_expiry_warn" {
  provider            = aws.virginia
  alarm_name          = "${var.common_param["base_name"]}-pepese-com-virginia-acm-DaysToExpiry"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "DaysToExpiry"
  namespace           = "AWS/CertificateManager"
  period              = "86400"
  statistic           = "Minimum"
  threshold           = 30

  dimensions = {
    CertificateArn = data.aws_acm_certificate.pepese_com_virginia.arn
  }

  alarm_actions = [var.sns_topic.arn]
  ok_actions    = [var.sns_topic.arn]

  tags = {
    Service = "common",
    Name    = "${var.common_param["base_name"]}-pepese-com-virginia-acm-days-to-expiry-warn",
  }
}

data "aws_acm_certificate" "pepese_com_virginia" {
  provider    = aws.virginia
  domain      = "*.pepese.com"
  statuses    = ["ISSUED"]
  most_recent = true
}
