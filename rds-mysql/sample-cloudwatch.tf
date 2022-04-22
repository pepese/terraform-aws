#####################################
# CloudWatch Alarm
#####################################
# https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html

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
  alarm_actions       = [aws_sns_topic.alarm.arn]

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
  alarm_actions       = [aws_sns_topic.alarm.arn]

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
  alarm_actions       = [aws_sns_topic.alarm.arn]

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
  alarm_actions       = [aws_sns_topic.alarm.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.rds.id
  }

  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-rds-database-connections" }))
}