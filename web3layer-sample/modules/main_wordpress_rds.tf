#####################################
# RDS
#####################################
resource "aws_db_instance" "wordpress_rds" {
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
  name                 = "${var.base_name}-wordpress-rds"
  allocated_storage    = var.wordpress_rds_settings["allocated_storage"]
  engine               = var.wordpress_rds_settings["engine"]
  engine_version       = var.wordpress_rds_settings["engine_version"]
  instance_class       = var.wordpress_rds_settings["instance_class"]
  username             = var.wordpress_rds_settings["username"]
  password             = var.wordpress_rds_settings["password"]
  db_subnet_group_name = aws_db_subnet_group.wordpress_rds_dbsg.name
  parameter_group_name  = aws_db_parameter_group.wordpress_rds_dbpg.name
  vpc_security_group_ids = [
    aws_security_group.wordpress_rds_sg.id,
  ]
  skip_final_snapshot = true
  # multi_az            = true
  monitoring_interval = 30
  monitoring_role_arn = aws_iam_role.wordpress_rds_iam_role.arn
  tags                = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-wordpress-rds" }))
}

#####################################
# DB Subnet Group
#####################################
resource "aws_db_subnet_group" "wordpress_rds_dbsg" {
  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id,
  ]

  tags = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-wordpress-rds-dbsg" }))
}

#####################################
# Security Group
#####################################
resource "aws_security_group" "wordpress_rds_sg" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-wordpress-rds-sg" }))
}

resource "aws_security_group_rule" "wordpress_rds_sg_ingress_rule" {
  security_group_id = aws_security_group.wordpress_rds_sg.id

  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.wordpress_server_sg.id
}

#####################################
# Parameter Group
#####################################
resource "aws_db_parameter_group" "wordpress_rds_dbpg" {
  family = "mysql5.7"

  parameter {
    name         = "time_zone"
    value        = "Asia/Tokyo"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "slow_query_log"
    value        = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "long_query_time"
    value        = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "log_output"
    value        = "TABLE"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "performance_schema"
    value        = "1"
    apply_method = "pending-reboot"
  }

  tags = merge(var.base_tags, tomap({"Name" = "${var.base_name}-db-parameter-group"}))
}

#####################################
# Data: IAM Policy Document
#####################################
data "aws_iam_policy_document" "wordpress_rds_iam_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

#####################################
# IAM Settings
#####################################

resource "aws_iam_role" "wordpress_rds_iam_role" {
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.wordpress_rds_iam_policy.json
  tags               = merge(var.base_tags, tomap({ "Name" = "${var.base_name}-wordpress-rds-iam-role" }))
}

resource "aws_iam_role_policy_attachment" "wordpress_rds_enhanced_monitoring" {
  role       = aws_iam_role.wordpress_rds_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}