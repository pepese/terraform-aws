#####################################
# WAF
#####################################
resource "aws_wafv2_web_acl" "waf" {
  name  = "${var.base_name}-waf"
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

  rule {
    # https://docs.aws.amazon.com/ja_jp/waf/latest/developerguide/aws-managed-rule-groups-list.html
    priority = 6
    name     = "aws-managed-rule-5"
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesPHPRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "aws-managed-rule-5"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "${var.base_name}-waf"
    sampled_requests_enabled   = false
  }

  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-waf" }))
}

#####################################
# WAF Association
#####################################

resource "aws_wafv2_web_acl_association" "waf_association_lb" {
  resource_arn = aws_lb.lb.arn
  web_acl_arn  = aws_wafv2_web_acl.waf.arn
}