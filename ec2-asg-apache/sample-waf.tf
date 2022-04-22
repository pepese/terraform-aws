#####################################
# WAF
#####################################
resource "aws_wafv2_web_acl" "sample" {
  name  = "${local.base_name}-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    priority = 1
    name     = "white-list-rule-1"
    action {
      allow {}
    }
    statement {
      geo_match_statement {
        country_codes = ["JP"]
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "white-list-rule-1"
      sampled_requests_enabled   = false
    }
  }

  rule {
    # https://docs.aws.amazon.com/ja_jp/waf/latest/developerguide/aws-managed-rule-groups-list.html
    priority = 2
    name     = "aws-managed-rule-1"
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
        excluded_rule {
          name = "NoUserAgent_HEADER"
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "aws-managed-rule-1"
      sampled_requests_enabled   = false
    }
  }

  rule {
    # https://docs.aws.amazon.com/ja_jp/waf/latest/developerguide/aws-managed-rule-groups-list.html
    priority = 3
    name     = "aws-managed-rule-2"
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "aws-managed-rule-2"
      sampled_requests_enabled   = false
    }
  }

  rule {
    # https://docs.aws.amazon.com/ja_jp/waf/latest/developerguide/aws-managed-rule-groups-list.html
    priority = 4
    name     = "aws-managed-rule-3"
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "aws-managed-rule-3"
      sampled_requests_enabled   = false
    }
  }

  rule {
    # https://docs.aws.amazon.com/ja_jp/waf/latest/developerguide/aws-managed-rule-groups-list.html
    priority = 5
    name     = "aws-managed-rule-4"
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesUnixRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "aws-managed-rule-4"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "${local.base_name}-waf"
    sampled_requests_enabled   = false
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample" }))
}

#####################################
# WAF Association
#####################################
resource "aws_wafv2_web_acl_association" "sample" {
  resource_arn = aws_lb.sample.arn
  web_acl_arn  = aws_wafv2_web_acl.sample.arn
}