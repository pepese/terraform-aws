#####################################
# SNS Topic
#####################################
resource "aws_sns_topic" "alarm_topic" {
  name = "${var.base_name}-alarm-topic"
  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-alarm-topic" }))
}

resource "aws_sns_topic_policy" "alarm_topic_policy" {
  arn    = aws_sns_topic.alarm_topic.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "__default_policy_ID"
  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:Receive",
      "SNS:Publish",
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values = [
        var.account_id,
      ]
    }
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "cloudwatch.amazonaws.com",
      ]
    }
    resources = [
      aws_sns_topic.alarm_topic.arn,
    ]
    sid = "__default_statement_ID"
  }
}

#####################################
# SNS Topic Subscription
#####################################
resource "aws_sns_topic_subscription" "alarm_topic_subscription_mail" {
  topic_arn = aws_sns_topic.alarm_topic.arn
  protocol  = "email"
  endpoint  = var.cloudwatch_settings["alarm_mail"]
}