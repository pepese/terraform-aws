#####################################
# CloudWatch Log Group
#####################################
resource "aws_cloudwatch_log_group" "log_group_ec2_messages" {
  name = "${var.system}_${var.env}_ec2_messages"
  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-log-group-ec2-messages" }))
}

resource "aws_cloudwatch_log_group" "log_group_ec2_apache_access_log" {
  name = "${var.system}_${var.env}_ec2_apache_access_log"
  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-log-group-ec2-apache-access-log" }))
}

resource "aws_cloudwatch_log_group" "log_group_ec2_apache_error_log" {
  name = "${var.system}_${var.env}_ec2_apache_error_log"
  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-log-group-ec2-apache-error-log" }))
}

#####################################
# CloudWatch Alarm
#####################################
# https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html

#####################################
# CloudWatch Alarm / ec2
#####################################
# https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/viewing_metrics_with_cloudwatch.html
resource "aws_cloudwatch_metric_alarm" "ec2_cpu_utilization" {
  alarm_name          = "asg-${aws_autoscaling_group.ec2_asg.name}-CPUUtilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "ASG ${aws_autoscaling_group.ec2_asg.name} CPUUtilization: High"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ec2_asg.name
  }

  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-ec2-cpu-utilization" }))
}

# メモリの使用率、ディスクスワップの使用率、ディスクスペースの使用状況、ページファイルの使用状況、ログ収集にはCloudWatch エージェントの導入が必要
# https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/monitoring_ec2.html
resource "aws_cloudwatch_metric_alarm" "ec2_mem_used_percent" {
  alarm_name          = "asg-${aws_autoscaling_group.ec2_asg.name}-mem_used_percent"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "ASG ${aws_autoscaling_group.ec2_asg.name} mem_used_percent: High"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ec2_asg.name
  }

  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-ec2-mem-used-percent" }))
}

resource "aws_cloudwatch_metric_alarm" "ec2_disk_used_percent" {
  alarm_name          = "asg-${aws_autoscaling_group.ec2_asg.name}-disk_used_percent"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "ASG ${aws_autoscaling_group.ec2_asg.name} disk_used_percent: High"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ec2_asg.name
    path                 = "/"
  }

  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-ec2-disk-used-percent" }))
}

#####################################
# CloudWatch Alarm / rds
#####################################
# https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/monitoring-cloudwatch.html
resource "aws_cloudwatch_metric_alarm" "rds_cpu_utilization" {
  alarm_name          = "rds-${aws_db_instance.rds.id}-CPUUtilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "RDS ${aws_db_instance.rds.id} CPUUtilization: High"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.rds.id
  }

  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-rds-cpu-utilization" }))
}

resource "aws_cloudwatch_metric_alarm" "freeable_memory" {
  alarm_name          = "rds-${aws_db_instance.rds.id}-FreeableMemory"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "500000000" # Byte
  alarm_description   = "RDS ${aws_db_instance.rds.id} Freeable Memory"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.rds.id
  }

  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-rds-freeable-memory" }))
}

resource "aws_cloudwatch_metric_alarm" "free_storage_space" {
  alarm_name          = "rds-${aws_db_instance.rds.id}-FreeLocalStorage"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "5000000000" # Byte
  alarm_description   = "RDS ${aws_db_instance.rds.id} Free Local Storage"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.rds.id
  }

  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-rds-free-storage-space" }))
}

resource "aws_cloudwatch_metric_alarm" "rds_database_connections" {
  alarm_name          = "rds-${aws_db_instance.rds.id}-DatabaseConnections"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "100"
  alarm_description   = "RDS ${aws_db_instance.rds.id} DatabaseConnections: too many connections"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.rds.id
  }

  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-rds-database-connections" }))
}

#####################################
# CloudWatch Alarm / lb
#####################################
# https://docs.aws.amazon.com/ja_jp/elasticloadbalancing/latest/application/load-balancer-cloudwatch-metrics.html
resource "aws_cloudwatch_metric_alarm" "lb_500_count" {
  alarm_name          = "lb-${aws_lb.lb.name}-HTTPCode_ELB_500_Count"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "HTTPCode_ELB_500_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "LB ${aws_lb.lb.name} HTTPCode_ELB_500_Count."
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    LoadBalancer = aws_lb.lb.arn_suffix
  }

  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-lb-500-count" }))
}

resource "aws_cloudwatch_metric_alarm" "lb_503_count" {
  alarm_name          = "lb-${aws_lb.lb.name}-HTTPCode_ELB_503_Count"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "HTTPCode_ELB_503_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "LB ${aws_lb.lb.name} HTTPCode_ELB_503_Count."
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    LoadBalancer = aws_lb.lb.arn_suffix
  }

  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-lb-503-count" }))
}

resource "aws_cloudwatch_metric_alarm" "lb_5xx_count" {
  alarm_name          = "lb-${aws_lb.lb.name}-HTTPCode_ELB_5XX_Count"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  datapoints_to_alarm = "2"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "LB ${aws_lb.lb.name} HTTPCode_ELB_5XX_Count."
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    LoadBalancer = aws_lb.lb.arn_suffix
  }

  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-lb-5xx-count" }))
}

#####################################
# CloudWatch Alarm / lb-target-group
#####################################
resource "aws_cloudwatch_metric_alarm" "lb_tg_healthyhostcount" {
  alarm_name          = "lb-tg-${aws_lb_target_group.lb_tg.name}-HealthyHostCount"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Minimum"
  threshold           = "0"
  alarm_description   = "LB TG ${aws_lb_target_group.lb_tg.name} HealthyHostCount."
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    TargetGroup  = aws_lb_target_group.lb_tg.arn_suffix
    LoadBalancer = aws_lb.lb.arn_suffix
  }

  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-lb-tg-healthyhostcount" }))
}

resource "aws_cloudwatch_metric_alarm" "lb_tg_targetresponsetime" {
  alarm_name          = "lb-tg-${aws_lb_target_group.lb_tg.name}-TargetResponseTime"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  datapoints_to_alarm = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  extended_statistic  = "p95.00"
  threshold           = "3"
  alarm_description   = "LB TG ${aws_lb_target_group.lb_tg.name} TargetResponseTime."
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alarm_topic.arn]

  dimensions = {
    TargetGroup  = aws_lb_target_group.lb_tg.arn_suffix
    LoadBalancer = aws_lb.lb.arn_suffix
  }

  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-lb-tg-targetresponsetime" }))
}

#####################################
# CloudWatch Alarm / ログ監視（Apache）
#####################################
resource "aws_cloudwatch_log_metric_filter" "apache_log_error" {
  name           = "${var.base_name}-log-group-ec2-apache-log-error"
  pattern        = "Error"
  log_group_name = aws_cloudwatch_log_group.log_group_ec2_apache_error_log.name

  metric_transformation {
    name          = "${var.base_name}-log-group-ec2-apache-log-error-count"
    namespace     = "${var.base_name}-log-group-ec2-apache-log"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "apache_log_error" {
  alarm_name                = "${var.base_name}-log-group-ec2-apache-log-error"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "15"
  datapoints_to_alarm       = "1"
  metric_name               = "${var.base_name}-log-group-ec2-apache-log-error-count"
  namespace                 = "${var.base_name}-log-group-ec2-apache-log"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "0"
  insufficient_data_actions = []
  alarm_description         = "${aws_cloudwatch_log_group.log_group_ec2_apache_log.name} ロググループで Exception を検知しました"
  treat_missing_data        = "notBreaching"
  alarm_actions             = [aws_sns_topic.alarm_topic.arn]

  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-log-group-ec2-apache-log-error" }))
}