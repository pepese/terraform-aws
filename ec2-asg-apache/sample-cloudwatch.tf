#####################################
# CloudWatch Log Group
#####################################
resource "aws_cloudwatch_log_group" "sample_ec2_messages" {
  name = "${local.system}/${local.env}/sample/ec2/messages"
  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-ec2-messages" }))
}

resource "aws_cloudwatch_log_group" "sample_ec2_apache_access_log" {
  name = "${local.system}/${local.env}/sample/ec2/apache_access_log"
  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-ec2-apache-access-log" }))
}

resource "aws_cloudwatch_log_group" "sample_ec2_apache_error_log" {
  name = "${local.system}/${local.env}/sample/ec2/apache_error_log"
  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-ec2-apache-error-log" }))
}

#####################################
# CloudWatch Alarm
#####################################
# https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html

#####################################
# CloudWatch Alarm / ec2
#####################################
# https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/viewing_metrics_with_cloudwatch.html
resource "aws_cloudwatch_metric_alarm" "sample_ec2_cpu_utilization" {
  alarm_name          = "asg-${aws_autoscaling_group.sample.name}-CPUUtilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "ASG ${aws_autoscaling_group.sample.name} CPUUtilization: High"
  alarm_actions       = [aws_sns_topic.alarm.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.sample.name
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-ec2-cpu-utilization" }))
}

# メモリの使用率、ディスクスワップの使用率、ディスクスペースの使用状況、ページファイルの使用状況、ログ収集にはCloudWatch エージェントの導入が必要
# https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/monitoring_ec2.html
resource "aws_cloudwatch_metric_alarm" "sample_ec2_mem_used_percent" {
  alarm_name          = "asg-${aws_autoscaling_group.sample.name}-mem_used_percent"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "ASG ${aws_autoscaling_group.sample.name} mem_used_percent: High"
  alarm_actions       = [aws_sns_topic.alarm.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.sample.name
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-ec2-mem-used-percent" }))
}

resource "aws_cloudwatch_metric_alarm" "sample_ec2_disk_used_percent" {
  alarm_name          = "asg-${aws_autoscaling_group.sample.name}-disk_used_percent"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "ASG ${aws_autoscaling_group.sample.name} disk_used_percent: High"
  alarm_actions       = [aws_sns_topic.alarm.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.sample.name
    path                 = "/"
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-ec2-disk-used-percent" }))
}

#####################################
# CloudWatch Alarm / lb
#####################################
# https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/application/load-balancer-cloudwatch-metrics.html
resource "aws_cloudwatch_metric_alarm" "sample_alb_500_count" {
  alarm_name          = "lb-${aws_lb.sample.name}-HTTPCode_ELB_500_Count"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "HTTPCode_ELB_500_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "LB ${aws_lb.sample.name} HTTPCode_ELB_500_Count."
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alarm.arn]

  dimensions = {
    LoadBalancer = aws_lb.sample.arn_suffix
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-alb-500-count" }))
}

resource "aws_cloudwatch_metric_alarm" "sample_alb_503_count" {
  alarm_name          = "lb-${aws_lb.sample.name}-HTTPCode_ELB_503_Count"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "HTTPCode_ELB_503_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "LB ${aws_lb.sample.name} HTTPCode_ELB_503_Count."
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alarm.arn]

  dimensions = {
    LoadBalancer = aws_lb.sample.arn_suffix
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-alb-503-count" }))
}

resource "aws_cloudwatch_metric_alarm" "sample_alb_5xx_count" {
  alarm_name          = "lb-${aws_lb.sample.name}-HTTPCode_ELB_5XX_Count"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  datapoints_to_alarm = "2"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "LB ${aws_lb.sample.name} HTTPCode_ELB_5XX_Count."
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alarm.arn]

  dimensions = {
    LoadBalancer = aws_lb.sample.arn_suffix
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-alb-5xx-count" }))
}

#####################################
# CloudWatch Alarm / lb-target-group
#####################################
resource "aws_cloudwatch_metric_alarm" "sample_alb_tg_healthyhostcount" {
  alarm_name          = "${aws_lb_target_group.sample.name}-alb-tg-HealthyHostCount"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "0"
  alarm_description   = "LB TG ${aws_lb_target_group.sample.name} HealthyHostCount."
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alarm.arn]

  dimensions = {
    TargetGroup  = aws_lb_target_group.sample.arn_suffix
    LoadBalancer = aws_lb.sample.arn_suffix
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-alb-tg-healthyhostcount" }))
}

resource "aws_cloudwatch_metric_alarm" "sample_alb_tg_targetresponsetime" {
  alarm_name          = "${aws_lb_target_group.sample.name}-alb-tg-TargetResponseTime"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  datapoints_to_alarm = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  extended_statistic  = "p95.00"
  threshold           = "3"
  alarm_description   = "LB TG ${aws_lb_target_group.sample.name} TargetResponseTime."
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alarm.arn]

  dimensions = {
    TargetGroup  = aws_lb_target_group.sample.arn_suffix
    LoadBalancer = aws_lb.sample.arn_suffix
  }

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-alb-tg-targetresponsetime" }))
}

#####################################
# CloudWatch Alarm / ログ監視（Apache）
#####################################
resource "aws_cloudwatch_log_metric_filter" "sample_ec2_apache_log_error" {
  name           = "${local.base_name}-sample-ec2-apache-log-error"
  pattern        = "Error"
  log_group_name = aws_cloudwatch_log_group.sample_ec2_apache_error_log.name

  metric_transformation {
    name          = "${local.base_name}-sample-ec2-apache-log-error-count"
    namespace     = "${local.base_name}-sample-ec2-apache-log"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "sample_ec2_apache_log_error" {
  alarm_name                = "${local.base_name}-sample-ec2-apache-log-error"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "15"
  datapoints_to_alarm       = "1"
  metric_name               = "${local.base_name}-sample-ec2-apache-log-error-count"
  namespace                 = "${local.base_name}-sample-ec2-apache-log"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "0"
  insufficient_data_actions = []
  alarm_description         = "${aws_cloudwatch_log_group.sample_ec2_apache_error_log.name} ロググループで Exception を検知しました"
  treat_missing_data        = "notBreaching"
  alarm_actions             = [aws_sns_topic.alarm.arn]

  tags = merge(tomap({ "Service" = "sample" }), tomap({ "Name" = "${local.base_name}-sample-ec2-apache-log-error" }))
}