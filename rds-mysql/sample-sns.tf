#####################################
# SNS Topic
#####################################
resource "aws_sns_topic" "alarm" {
  name = "${local.base_name}-alarm"
  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-alarm" }))
}

resource "aws_sns_topic_policy" "alarm" {
  arn    = aws_sns_topic.alarm.arn
  policy = data.aws_iam_policy_document.sns_topic.json
}

data "aws_iam_policy_document" "sns_topic" {
  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:Receive",
      "SNS:Publish",
    ]
    # condition {
    #   test     = "StringEquals"
    #   variable = "AWS:SourceOwner"
    #   values = [
    #     local.account_id,
    #   ]
    # }
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "cloudwatch.amazonaws.com",
      ]
    }
    resources = [
      aws_sns_topic.alarm.arn,
    ]
  }
}

#####################################
# SNS Topic Subscription
#####################################
resource "aws_sns_topic_subscription" "alarm_mail" {
  topic_arn = aws_sns_topic.alarm.arn
  protocol  = "email"
  endpoint  = local.cloudwatch_settings["alarm_mail"]
}